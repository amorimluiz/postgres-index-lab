-- =============================================================================
-- Challenge 05 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('05');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('cursor=2023-06-01', 'ref05_a', $q$SELECT id, customer_id, event_type, created_at
   FROM events WHERE created_at < '2023-06-01'
   ORDER BY created_at DESC, id DESC LIMIT 100$q$),
('cursor=2024-01-01', 'ref05_b', $q$SELECT id, customer_id, event_type, created_at
   FROM events WHERE created_at < '2024-01-01'
   ORDER BY created_at DESC, id DESC LIMIT 100$q$),
('cursor=2024-06-01', 'ref05_c', $q$SELECT id, customer_id, event_type, created_at
   FROM events WHERE created_at < '2024-06-01'
   ORDER BY created_at DESC, id DESC LIMIT 100$q$),
('cursor=2024-12-01', 'ref05_d', $q$SELECT id, customer_id, event_type, created_at
   FROM events WHERE created_at < '2024-12-01'
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
    PERFORM lab.check_ref('05', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('05', r.label, r.sql, 400, 60, 'events', true);
  END LOOP;
END $$;

SELECT lab.report('05');
