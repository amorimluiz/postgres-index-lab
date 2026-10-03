-- =============================================================================
-- Challenge 01 - evaluator
-- =============================================================================
SELECT lab.reset_results();
SELECT lab.check_seed('01');

CREATE TEMP TABLE cases (label text, ref text, sql text);
INSERT INTO cases VALUES
('event id=123456', 'ref01_a', $q$SELECT id, customer_id, event_type, entity_type, entity_id, created_at
   FROM events WHERE request_id = (SELECT request_id FROM events WHERE id = 123456)$q$),
('event id=1000000', 'ref01_b', $q$SELECT id, customer_id, event_type, entity_type, entity_id, created_at
   FROM events WHERE request_id = (SELECT request_id FROM events WHERE id = 1000000)$q$),
('event id=2500000', 'ref01_c', $q$SELECT id, customer_id, event_type, entity_type, entity_id, created_at
   FROM events WHERE request_id = (SELECT request_id FROM events WHERE id = 2500000)$q$),
('event id=3999999', 'ref01_d', $q$SELECT id, customer_id, event_type, entity_type, entity_id, created_at
   FROM events WHERE request_id = (SELECT request_id FROM events WHERE id = 3999999)$q$);

-- Ground truth: compute the reference with every index access path disabled.
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
    PERFORM lab.check_ref('01', r.label, r.sql, r.ref);
    PERFORM lab.eval_case('01', r.label, r.sql, 25, 30, 'events');
  END LOOP;
END $$;

SELECT lab.report('01');
