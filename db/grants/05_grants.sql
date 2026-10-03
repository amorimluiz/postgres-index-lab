-- =============================================================================
-- PostgreSQL Index Lab - Student role
-- =============================================================================
-- `student` owns the data and can create/drop indexes, but is NOT a superuser
-- and cannot change cluster-wide planner settings through ALTER SYSTEM. The
-- evaluator connects as `postgres` so that student-level ALTER ROLE / ALTER
-- DATABASE settings cannot influence the measured plans.
-- =============================================================================

CREATE ROLE student LOGIN PASSWORD 'student';

GRANT USAGE, CREATE ON SCHEMA public TO student;
GRANT USAGE ON SCHEMA lab TO student;

ALTER TABLE customers   OWNER TO student;
ALTER TABLE products    OWNER TO student;
ALTER TABLE orders      OWNER TO student;
ALTER TABLE order_items OWNER TO student;
ALTER TABLE payments    OWNER TO student;
ALTER TABLE events      OWNER TO student;
ALTER TABLE sessions    OWNER TO student;

GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO student;
GRANT ALL ON ALL TABLES IN SCHEMA public TO student;

-- Marker the Makefile waits for so nobody runs the evaluator while the initial
-- seed is still in progress.
CREATE TABLE lab.ready (finished_at timestamptz NOT NULL DEFAULT now());
GRANT SELECT ON lab.ready TO student;
