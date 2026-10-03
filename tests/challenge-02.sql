-- =============================================================================
-- Challenge 02 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('02');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('customer=1337 status=paid', 'ref02_a', $q$SELECT id, status, total_cents, created_at
   FROM orders WHERE customer_id = 1337 AND status = 'paid'$q$),
('customer=42 status=pending', 'ref02_b', $q$SELECT id, status, total_cents, created_at
   FROM orders WHERE customer_id = 42 AND status = 'pending'$q$),
('customer=90909 status=shipped', 'ref02_c', $q$SELECT id, status, total_cents, created_at
   FROM orders WHERE customer_id = 90909 AND status = 'shipped'$q$),
('customer=150000 status=cancelled', 'ref02_d', $q$SELECT id, status, total_cents, created_at
   FROM orders WHERE customer_id = 150000 AND status = 'cancelled'$q$);

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
    PERFORM lab.check_ref('02', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('02', r.label, r.sql, 15, 20, 'orders');
  END LOOP;
END $$;

SELECT lab.report('02');
