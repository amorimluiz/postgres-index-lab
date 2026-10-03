-- =============================================================================
-- Challenge 07 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('07');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('pending from 2024-01-01', 'ref07_a', $q$SELECT id, customer_id, total_cents, created_at
   FROM orders WHERE status = 'pending' AND created_at >= '2024-01-01'
   ORDER BY created_at DESC, id DESC LIMIT 50$q$),
('pending from 2024-06-01', 'ref07_b', $q$SELECT id, customer_id, total_cents, created_at
   FROM orders WHERE status = 'pending' AND created_at >= '2024-06-01'
   ORDER BY created_at DESC, id DESC LIMIT 50$q$),
('pending from 2024-10-01', 'ref07_c', $q$SELECT id, customer_id, total_cents, created_at
   FROM orders WHERE status = 'pending' AND created_at >= '2024-10-01'
   ORDER BY created_at DESC, id DESC LIMIT 50$q$),
('pending from 2023-06-01', 'ref07_d', $q$SELECT id, customer_id, total_cents, created_at
   FROM orders WHERE status = 'pending' AND created_at >= '2023-06-01'
   ORDER BY created_at DESC, id DESC LIMIT 50$q$);

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
    PERFORM lab.check_ref('07', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('07', r.label, r.sql, 200, 30, 'orders', true);
  END LOOP;
END $$;

SELECT lab.report('07');
