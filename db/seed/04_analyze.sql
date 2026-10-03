-- =============================================================================
-- PostgreSQL Index Lab - Statistics + visibility map
-- =============================================================================
-- ANALYZE gives the planner the statistics it needs to consider indexes at all.
-- VACUUM marks pages all-visible, which is required for Index Only Scans to
-- avoid heap fetches. The evaluator re-runs VACUUM ANALYZE on the tables it
-- measures so results are stable.
-- =============================================================================

VACUUM (ANALYZE) customers;
VACUUM (ANALYZE) products;
VACUUM (ANALYZE) orders;
VACUUM (ANALYZE) order_items;
VACUUM (ANALYZE) payments;
VACUUM (ANALYZE) events;
VACUUM (ANALYZE) sessions;
