-- =============================================================================
-- Challenge 09 - evaluator (read requirements + read/write trade-off)
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('09');

VACUUM (ANALYZE) sessions;

-- ---------------------------------------------------------------------------
-- R1 - recent sessions for a customer
-- ---------------------------------------------------------------------------
CREATE TEMP TABLE r1_cases (label text, ref text, sql text);
INSERT INTO r1_cases VALUES
('customer=42', 'ref09r1_a', $q$SELECT id, status, device, created_at
   FROM sessions WHERE customer_id = 42
   ORDER BY created_at DESC, id DESC LIMIT 20$q$),
('customer=1337', 'ref09r1_b', $q$SELECT id, status, device, created_at
   FROM sessions WHERE customer_id = 1337
   ORDER BY created_at DESC, id DESC LIMIT 20$q$),
('customer=90909', 'ref09r1_c', $q$SELECT id, status, device, created_at
   FROM sessions WHERE customer_id = 90909
   ORDER BY created_at DESC, id DESC LIMIT 20$q$),
('customer=150000', 'ref09r1_d', $q$SELECT id, status, device, created_at
   FROM sessions WHERE customer_id = 150000
   ORDER BY created_at DESC, id DESC LIMIT 20$q$);

SET enable_indexscan = off;
SET enable_bitmapscan = off;
SET enable_indexonlyscan = off;
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM r1_cases LOOP
    PERFORM lab.make_ref(r.ref, r.sql);
  END LOOP;
  PERFORM lab.make_ref('ref09r2', $q$SELECT count(*)
     FROM sessions WHERE status = 'active' AND created_at >= '2024-12-25'$q$);
END $$;
RESET enable_indexscan;
RESET enable_bitmapscan;
RESET enable_indexonlyscan;

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM r1_cases LOOP
    PERFORM lab.check_ref('09', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('09', 'R1 ' || r.label, r.sql, 60, 30, 'sessions', true);
  END LOOP;
END $$;

DO $$
BEGIN
  PERFORM lab.check_ref('09', 'R2', $q$SELECT count(*)
     FROM sessions WHERE status = 'active' AND created_at >= '2024-12-25'$q$, 'ref09r2');
  PERFORM lab.eval_case('09', 'R2 active count', $q$SELECT count(*)
     FROM sessions WHERE status = 'active' AND created_at >= '2024-12-25'$q$, 200, 30, 'sessions');
END $$;

-- ---------------------------------------------------------------------------
-- Write benchmark - rolled back, so the data is untouched.
-- ---------------------------------------------------------------------------
CHECKPOINT;
BEGIN;
SELECT pg_current_wal_lsn() AS lsn0,
       extract(epoch FROM clock_timestamp()) AS t0 \gset

INSERT INTO sessions (customer_id, status, device, ip_address, created_at, expires_at)
SELECT
    1 + abs(hashtext('wi:' || i)::bigint) % 200000,
    (CASE
        WHEN abs(hashtext('ws:' || i)::bigint) % 100 < 12 THEN 'active'
        WHEN abs(hashtext('ws:' || i)::bigint) % 100 < 72 THEN 'expired'
        ELSE 'revoked'
     END),
    (ARRAY['desktop','mobile','tablet','api'])[1 + abs(hashtext('wd:' || i)::bigint) % 4],
    '10.0.0.' || (abs(hashtext('wip:' || i)::bigint) % 256),
    now(),
    now() + interval '1 day'
FROM generate_series(1, 20000) AS i;

UPDATE sessions SET status = 'expired' WHERE id BETWEEN 1500000 AND 1519999;
DELETE FROM sessions WHERE id BETWEEN 1800000 AND 1819999;

SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), :'lsn0')::bigint AS wal_bytes,
       (extract(epoch FROM clock_timestamp()) - :'t0'::numeric) * 1000.0 AS bench_ms \gset
ROLLBACK;

SELECT lab.check('09', 'Write WAL',
    (:'wal_bytes')::bigint <= 136314880,
    '<= 130 MB',
    pg_size_pretty((:'wal_bytes')::bigint));
SELECT lab.check('09', 'Write time',
    (:'bench_ms')::numeric <= 20000,
    '<= 20000 ms',
    round((:'bench_ms')::numeric, 0)::text || ' ms');
SELECT lab.check('09', 'Index footprint',
    lab.sessions_index_bytes() <= 157286400,
    '<= 150 MB',
    pg_size_pretty(lab.sessions_index_bytes()));

SELECT lab.report('09');
