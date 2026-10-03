-- =============================================================================
-- Read-vs-write benchmark for the `sessions` table
-- =============================================================================
-- Run with:  make bench
--            (or)  docker compose exec -T db psql -U postgres -d indexlab \
--                       < benchmarks/write_tradeoff.sql
--
-- The workload is deterministic and always runs inside a transaction that is
-- rolled back, so it never modifies the data. WAL volume is used as the write
-- cost metric because it does not depend on the machine's hardware.
-- =============================================================================

\pset pager off
\timing on

\echo '=== Index inventory on sessions ==='
SELECT indexrelname AS index,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE relname = 'sessions'
ORDER BY pg_relation_size(indexrelid) DESC;

\echo ''
\echo '=== Write workload (rolled back) ==='

CHECKPOINT;
BEGIN;
SELECT pg_current_wal_lsn() AS lsn0,
       extract(epoch FROM clock_timestamp()) AS t0 \gset

INSERT INTO sessions (customer_id, status, device, ip_address, created_at, expires_at)
SELECT
    1 + abs(hashtext('wi:' || i)::bigint) % 200000,
    (CASE
        WHEN abs(hashtext('ws:' || i)::bigint) % 100 < 12 THEN 'active'
        WHEN abs(hashtext('ws:' || i)::bigint) % 100 < 72 THEN 'expired'
        ELSE 'revoked'
     END),
    (ARRAY['desktop','mobile','tablet','api'])[1 + abs(hashtext('wd:' || i)::bigint) % 4],
    '10.0.0.' || (abs(hashtext('wip:' || i)::bigint) % 256),
    now(),
    now() + interval '1 day'
FROM generate_series(1, 20000) AS i;

UPDATE sessions SET status = 'expired' WHERE id BETWEEN 1500000 AND 1519999;
DELETE FROM sessions WHERE id BETWEEN 1800000 AND 1819999;

SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), :'lsn0')::bigint AS wal_bytes,
       (extract(epoch FROM clock_timestamp()) - :'t0'::numeric) * 1000.0 AS bench_ms \gset
ROLLBACK;

\echo ''
\echo '=== Result ==='
SELECT
    pg_size_pretty((:'wal_bytes')::bigint)                                   AS wal_generated,
    round((:'bench_ms')::numeric, 0)                                         AS elapsed_ms,
    pg_size_pretty(lab.sessions_index_bytes())                               AS total_index_size;
