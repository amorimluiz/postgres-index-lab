-- =============================================================================
-- Challenge 03 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('03');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('category=electronics', 'ref03_a', $q$SELECT id, name, price_cents, created_at
   FROM products WHERE category = 'electronics' AND active = true
   ORDER BY created_at DESC, id DESC LIMIT 20$q$),
('category=books', 'ref03_b', $q$SELECT id, name, price_cents, created_at
   FROM products WHERE category = 'books' AND active = true
   ORDER BY created_at DESC, id DESC LIMIT 20$q$),
('category=toys', 'ref03_c', $q$SELECT id, name, price_cents, created_at
   FROM products WHERE category = 'toys' AND active = true
   ORDER BY created_at DESC, id DESC LIMIT 20$q$),
('category=grocery', 'ref03_d', $q$SELECT id, name, price_cents, created_at
   FROM products WHERE category = 'grocery' AND active = true
   ORDER BY created_at DESC, id DESC LIMIT 20$q$);

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
    PERFORM lab.check_ref('03', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('03', r.label, r.sql, 60, 15, 'products', true);
  END LOOP;
END $$;

SELECT lab.report('03');
