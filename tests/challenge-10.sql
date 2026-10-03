-- =============================================================================
-- Challenge 10 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('10');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('shipped from 2024-01-01', 'ref10_a', $q$SELECT o.id, o.status, o.total_cents, o.created_at, c.full_name
   FROM orders o JOIN customers c ON c.id = o.customer_id
   WHERE o.status = 'shipped' AND o.created_at >= '2024-01-01'
   ORDER BY o.created_at DESC, o.id DESC LIMIT 100$q$),
('paid from 2024-06-01', 'ref10_b', $q$SELECT o.id, o.status, o.total_cents, o.created_at, c.full_name
   FROM orders o JOIN customers c ON c.id = o.customer_id
   WHERE o.status = 'paid' AND o.created_at >= '2024-06-01'
   ORDER BY o.created_at DESC, o.id DESC LIMIT 100$q$),
('pending from 2023-06-01', 'ref10_c', $q$SELECT o.id, o.status, o.total_cents, o.created_at, c.full_name
   FROM orders o JOIN customers c ON c.id = o.customer_id
   WHERE o.status = 'pending' AND o.created_at >= '2023-06-01'
   ORDER BY o.created_at DESC, o.id DESC LIMIT 100$q$),
('cancelled from 2024-01-01', 'ref10_d', $q$SELECT o.id, o.status, o.total_cents, o.created_at, c.full_name
   FROM orders o JOIN customers c ON c.id = o.customer_id
   WHERE o.status = 'cancelled' AND o.created_at >= '2024-01-01'
   ORDER BY o.created_at DESC, o.id DESC LIMIT 100$q$);

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
    PERFORM lab.check_ref('10', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('10', r.label, r.sql, 2500, 50, 'orders', true);
  END LOOP;
END $$;

SELECT lab.report('10');
