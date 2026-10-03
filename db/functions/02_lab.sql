-- =============================================================================
-- PostgreSQL Index Lab - Evaluation helpers
-- =============================================================================
-- The `lab` schema is the *evaluation harness*. It is NOT part of the data
-- model the student optimises. It gives the test files a small vocabulary to
-- inspect query plans (via EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)), record
-- check results and print a per-challenge report.
--
-- The student does not need to use these functions to solve the challenges.
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS lab;

CREATE TABLE IF NOT EXISTS lab.results (
    id         bigint GENERATED ALWAYS AS IDENTITY,
    challenge  text    NOT NULL,
    check_name text    NOT NULL,
    ok         boolean NOT NULL,
    expected   text,
    actual     text,
    detail     text
);

CREATE OR REPLACE FUNCTION lab.reset_results()
RETURNS void
LANGUAGE sql AS $$
    TRUNCATE lab.results;
$$;

CREATE OR REPLACE FUNCTION lab.check(
    p_challenge text,
    p_name      text,
    p_ok        boolean,
    p_expected  text DEFAULT NULL,
    p_actual    text DEFAULT NULL,
    p_detail    text DEFAULT NULL
)
RETURNS void
LANGUAGE sql AS $$
    INSERT INTO lab.results (challenge, check_name, ok, expected, actual, detail)
    VALUES (p_challenge, p_name, p_ok, p_expected, p_actual, p_detail);
$$;

-- Run EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) and return the JSON document.
CREATE OR REPLACE FUNCTION lab.explain(p_sql text)
RETURNS jsonb
LANGUAGE plpgsql AS $$
DECLARE
    v_json json;
BEGIN
    EXECUTE format('EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) %s', p_sql) INTO v_json;
    RETURN v_json::jsonb;
END;
$$;

CREATE OR REPLACE FUNCTION lab.root(p_plan jsonb)
RETURNS jsonb
LANGUAGE sql AS $$
    SELECT p_plan -> 0 -> 'Plan';
$$;

CREATE OR REPLACE FUNCTION lab.exec_ms(p_plan jsonb)
RETURNS numeric
LANGUAGE sql AS $$
    SELECT (p_plan -> 0 ->> 'Execution Time')::numeric;
$$;

-- All plan nodes, depth first.
CREATE OR REPLACE FUNCTION lab.walk(p_plan jsonb)
RETURNS SETOF jsonb
LANGUAGE plpgsql AS $$
DECLARE
    v_child jsonb;
BEGIN
    IF p_plan IS NULL THEN
        RETURN;
    END IF;
    RETURN NEXT p_plan;
    IF p_plan ? 'Plans' THEN
        FOR v_child IN SELECT jsonb_array_elements(p_plan -> 'Plans')
        LOOP
            RETURN QUERY SELECT * FROM lab.walk(v_child);
        END LOOP;
    END IF;
END;
$$;

-- Array of every node type in the whole plan tree.
CREATE OR REPLACE FUNCTION lab.node_types(p_plan jsonb)
RETURNS text[]
LANGUAGE sql AS $$
    SELECT coalesce(array_agg(n ->> 'Node Type'), '{}')
    FROM lab.walk(lab.root(p_plan)) AS n;
$$;

CREATE OR REPLACE FUNCTION lab.has_node(p_plan jsonb, p_type text)
RETURNS boolean
LANGUAGE sql AS $$
    SELECT p_type = ANY (lab.node_types(p_plan));
$$;

-- Tables touched by a sequential scan.
CREATE OR REPLACE FUNCTION lab.seqscan_relations(p_plan jsonb)
RETURNS text[]
LANGUAGE sql AS $$
    SELECT coalesce(array_agg(DISTINCT n ->> 'Relation Name'), '{}')
    FROM lab.walk(lab.root(p_plan)) AS n
    WHERE n ->> 'Node Type' = 'Seq Scan';
$$;

-- Relations touched by an index scan / index only scan / bitmap heap scan.
CREATE OR REPLACE FUNCTION lab.index_relations(p_plan jsonb)
RETURNS text[]
LANGUAGE sql AS $$
    SELECT coalesce(array_agg(DISTINCT n ->> 'Relation Name'), '{}')
    FROM lab.walk(lab.root(p_plan)) AS n
    WHERE n ->> 'Node Type' IN ('Index Scan', 'Index Only Scan', 'Bitmap Heap Scan');
$$;

-- With EXPLAIN (ANALYZE, BUFFERS) the buffer counters reported on the root
-- node already aggregate every node below it, so the root is the total.
CREATE OR REPLACE FUNCTION lab.shared_buffers(p_plan jsonb)
RETURNS bigint
LANGUAGE sql AS $$
    SELECT coalesce((lab.root(p_plan) ->> 'Shared Hit Blocks')::bigint, 0)
         + coalesce((lab.root(p_plan) ->> 'Shared Read Blocks')::bigint, 0);
$$;

-- Human readable single line summary: "Index Scan / Limit / no sort".
CREATE OR REPLACE FUNCTION lab.plan_summary(p_plan jsonb)
RETURNS text
LANGUAGE sql AS $$
    SELECT array_to_string(lab.node_types(p_plan), ' -> ');
$$;

-- Append a result row, keeping every other field free form.
CREATE OR REPLACE FUNCTION lab.note(
    p_challenge text,
    p_name      text,
    p_ok        boolean,
    p_detail    text
)
RETURNS void
LANGUAGE sql AS $$
    INSERT INTO lab.results (challenge, check_name, ok, detail)
    VALUES (p_challenge, p_name, p_ok, p_detail);
$$;

-- ---------------------------------------------------------------------------
-- Reference results
-- ---------------------------------------------------------------------------
-- Materialise the result of a challenge query with index access disabled. The
-- tests use it as the ground truth for correctness, which also catches wrong
-- partial/covering indexes that would silently drop rows.
CREATE OR REPLACE FUNCTION lab.make_ref(p_name text, p_sql text)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('DROP TABLE IF EXISTS %I', p_name);
    EXECUTE format('CREATE TEMP TABLE %I AS %s', p_name, p_sql);
    EXECUTE format('ANALYZE %I', p_name);
END;
$$;

CREATE OR REPLACE FUNCTION lab.matches_ref(p_sql text, p_ref text)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
    v_diff bigint;
BEGIN
    EXECUTE format('SELECT count(*) FROM ((%s) EXCEPT SELECT * FROM %I) x', p_sql, p_ref)
        INTO v_diff;
    IF v_diff <> 0 THEN
        RETURN false;
    END IF;
    EXECUTE format('SELECT count(*) FROM (SELECT * FROM %I EXCEPT (%s)) x', p_ref, p_sql)
        INTO v_diff;
    RETURN v_diff = 0;
END;
$$;

CREATE OR REPLACE FUNCTION lab.check_ref(p_challenge text, p_label text, p_sql text, p_ref text)
RETURNS void
LANGUAGE sql AS $$
    SELECT lab.check(p_challenge, 'Correctness ' || p_label,
        lab.matches_ref(p_sql, p_ref),
        'result matches sequential-scan reference');
$$;

-- ---------------------------------------------------------------------------
-- One reusable case evaluator
-- ---------------------------------------------------------------------------
-- Runs the challenge query, then records one check per objective. All plan
-- checks are behavioural: they never look at index names.
CREATE OR REPLACE FUNCTION lab.eval_case(
    p_challenge        text,
    p_label            text,
    p_sql              text,
    p_max_buffers      bigint,
    p_max_ms           numeric,
    p_forbid_seqscan   text    DEFAULT NULL,
    p_require_no_sort  boolean DEFAULT false,
    p_require_node     text    DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    v_plan jsonb;
    v_buf  bigint;
    v_ms   numeric;
BEGIN
    v_plan := lab.explain(p_sql);
    v_buf  := lab.shared_buffers(v_plan);
    v_ms   := lab.exec_ms(v_plan);

    IF p_forbid_seqscan IS NOT NULL THEN
        PERFORM lab.check(p_challenge, p_label || ' plan',
            NOT (p_forbid_seqscan = ANY (lab.seqscan_relations(v_plan))),
            'no Seq Scan on ' || p_forbid_seqscan,
            lab.plan_summary(v_plan));
    END IF;

    IF p_require_no_sort THEN
        PERFORM lab.check(p_challenge, p_label || ' sort',
            NOT lab.has_node(v_plan, 'Sort'),
            'no Sort node',
            lab.plan_summary(v_plan));
    END IF;

    IF p_require_node IS NOT NULL THEN
        PERFORM lab.check(p_challenge, p_label || ' ' || p_require_node,
            lab.has_node(v_plan, p_require_node),
            p_require_node || ' in plan',
            lab.plan_summary(v_plan));
    END IF;

    PERFORM lab.check(p_challenge, p_label || ' buffers',
        v_buf <= p_max_buffers,
        '<= ' || p_max_buffers || ' buffers',
        v_buf || ' buffers');

    PERFORM lab.check(p_challenge, p_label || ' time',
        v_ms <= p_max_ms,
        '<= ' || p_max_ms || ' ms',
        round(v_ms, 2) || ' ms');
END;
$$;

-- ---------------------------------------------------------------------------
-- Data integrity guard
-- ---------------------------------------------------------------------------
-- Solving the challenges must not require changing the data. Any row count
-- that drifts means the dataset was modified.
CREATE OR REPLACE FUNCTION lab.check_seed(p_challenge text)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    c  bigint; pr bigint; o bigint; oi bigint; pa bigint; e bigint; s bigint;
BEGIN
    SELECT count(*) INTO c  FROM customers;
    SELECT count(*) INTO pr FROM products;
    SELECT count(*) INTO o  FROM orders;
    SELECT count(*) INTO oi FROM order_items;
    SELECT count(*) INTO pa FROM payments;
    SELECT count(*) INTO e  FROM events;
    SELECT count(*) INTO s  FROM sessions;

    PERFORM lab.check(p_challenge, 'Data integrity',
        c = 200000 AND pr = 50000 AND o = 1000000 AND oi = 3000000
        AND pa = 1000000 AND e = 4000000 AND s = 2000000,
        'seed row counts unchanged',
        format('customers=%s products=%s orders=%s order_items=%s payments=%s events=%s sessions=%s',
               c, pr, o, oi, pa, e, s));
END;
$$;

-- Total size, in bytes, of every index on `sessions`.
CREATE OR REPLACE FUNCTION lab.sessions_index_bytes()
RETURNS bigint
LANGUAGE sql AS $$
    SELECT coalesce(sum(pg_relation_size(indexrelid)), 0)
    FROM pg_stat_user_indexes
    WHERE relname = 'sessions';
$$;

-- Print the console report for one challenge and return nothing.
CREATE OR REPLACE FUNCTION lab.report(p_challenge text)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
    r        record;
    v_out    text := E'\nChallenge ' || p_challenge || E'\n\n';
    v_failed integer := 0;
BEGIN
    FOR r IN
        SELECT * FROM lab.results WHERE challenge = p_challenge ORDER BY id
    LOOP
        IF r.ok THEN
            v_out := v_out || U&'\2713 ' || r.check_name || E'\n';
        ELSE
            v_out := v_out || U&'\2717 ' || r.check_name || E'\n';
            v_failed := v_failed + 1;
            IF r.expected IS NOT NULL THEN
                v_out := v_out || '    Expected: ' || r.expected || E'\n';
                v_out := v_out || '    Actual:   ' || coalesce(r.actual, '') || E'\n';
            ELSIF r.detail IS NOT NULL THEN
                v_out := v_out || '    Detail:   ' || r.detail || E'\n';
            END IF;
        END IF;
    END LOOP;

    v_out := v_out || E'\nStatus: ' ||
             CASE WHEN v_failed = 0 THEN 'PASSED' ELSE 'FAILED' END;
    RETURN v_out;
END;
$$;
