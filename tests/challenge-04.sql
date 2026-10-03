-- =============================================================================
-- Challenge 04 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('04');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('customer=42 page_view from 2023-01-01', 'ref04_a', $q$SELECT id, event_type, entity_type, entity_id, created_at
   FROM events WHERE customer_id = 42 AND event_type = 'page_view' AND created_at >= '2023-01-01'
   ORDER BY created_at DESC, id DESC LIMIT 50$q$),
('customer=1337 click from 2023-06-01', 'ref04_b', $q$SELECT id, event_type, entity_type, entity_id, created_at
   FROM events WHERE customer_id = 1337 AND event_type = 'click' AND created_at >= '2023-06-01'
   ORDER BY created_at DESC, id DESC LIMIT 50$q$),
('customer=90909 purchase from 2024-01-01', 'ref04_c', $q$SELECT id, event_type, entity_type, entity_id, created_at
   FROM events WHERE customer_id = 90909 AND event_type = 'purchase' AND created_at >= '2024-01-01'
   ORDER BY created_at DESC, id DESC LIMIT 50$q$),
('customer=150000 search from 2023-03-01', 'ref04_d', $q$SELECT id, event_type, entity_type, entity_id, created_at
   FROM events WHERE customer_id = 150000 AND event_type = 'search' AND created_at >= '2023-03-01'
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
    PERFORM lab.check_ref('04', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('04', r.label, r.sql, 40, 30, 'events', true);
  END LOOP;
END $$;

SELECT lab.report('04');
