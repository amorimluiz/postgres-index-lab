-- =============================================================================
-- Challenge 08 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('08');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('BR active from 2024-01-01', 'ref08_a', $q$SELECT id, full_name, country, plan, created_at
   FROM customers WHERE country = 'BR' AND status = 'active' AND created_at >= '2024-01-01'
   ORDER BY created_at DESC, id DESC LIMIT 100$q$),
('US inactive from 2023-06-01', 'ref08_b', $q$SELECT id, full_name, country, plan, created_at
   FROM customers WHERE country = 'US' AND status = 'inactive' AND created_at >= '2023-06-01'
   ORDER BY created_at DESC, id DESC LIMIT 100$q$),
('DE active from 2023-01-01', 'ref08_c', $q$SELECT id, full_name, country, plan, created_at
   FROM customers WHERE country = 'DE' AND status = 'active' AND created_at >= '2023-01-01'
   ORDER BY created_at DESC, id DESC LIMIT 100$q$),
('IN suspended from 2024-01-01', 'ref08_d', $q$SELECT id, full_name, country, plan, created_at
   FROM customers WHERE country = 'IN' AND status = 'suspended' AND created_at >= '2024-01-01'
   ORDER BY created_at DESC, id DESC LIMIT 100$q$);

SET enable_indexscan = off;
SET enable_bitmapscan = off;
SET enable_indexonlyscan = off;
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM cases LOOP
    PERFORM lab.make_ref(r.ref, r.sql);
  END LOOP;
END $$;
RESET enable_indexscan;
RESET enable_bitmapscan;
RESET enable_indexonlyscan;

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM cases LOOP
    PERFORM lab.check_ref('08', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('08', r.label, r.sql, 400, 25, 'customers', true);
  END LOOP;
END $$;

SELECT lab.report('08');
