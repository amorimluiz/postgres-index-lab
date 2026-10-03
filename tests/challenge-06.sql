-- =============================================================================
-- Challenge 06 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('06');

-- Keep the visibility map current so an all-covering index can actually avoid
-- heap fetches; this is a fairness measure for the evaluator, not a hint.
VACUUM (ANALYZE) payments;

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('order=777', 'ref06_a', $q$SELECT order_id, amount_cents, status
   FROM payments WHERE order_id = 777$q$),
('order=12345', 'ref06_b', $q$SELECT order_id, amount_cents, status
   FROM payments WHERE order_id = 12345$q$),
('order=500000', 'ref06_c', $q$SELECT order_id, amount_cents, status
   FROM payments WHERE order_id = 500000$q$),
('order=999000', 'ref06_d', $q$SELECT order_id, amount_cents, status
   FROM payments WHERE order_id = 999000$q$);

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
    PERFORM lab.check_ref('06', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('06', r.label, r.sql, 15, 20, 'payments', false, 'Index Only Scan');
  END LOOP;
END $$;

SELECT lab.report('06');
