-- =============================================================================
-- PostgreSQL Index Lab - Deterministic seed
-- =============================================================================
-- All values are derived from a deterministic hash of the row number, so the
-- dataset is byte-for-byte reproducible on any machine without downloading
-- anything. `setseed` is set as well so that any random() usage stays stable.
--
-- Approximate sizes:
--   customers    200,000
--   products      50,000
--   orders     1,000,000
--   order_items 3,000,000
--   payments   1,000,000
--   events     4,000,000
--   sessions   2,000,000
-- =============================================================================

\timing on
SELECT setseed(0.4242);

-- ---------------------------------------------------------------------------
-- customers
-- ---------------------------------------------------------------------------
INSERT INTO customers (full_name, email, phone, country, plan, status, created_at)
SELECT
    'Customer ' || i,
    'customer' || i || '@example.com',
    '+55' || lpad((abs(hashtext('ph:' || i)::bigint) % 100000000000)::text, 11, '0'),
    (ARRAY['BR','US','DE','FR','GB','IN','JP','CA','AU','MX',
           'ES','IT','NL','SE','PT','AR','CL','CO','PE','PL'])
        [1 + abs(hashtext('co:' || i)::bigint) % 20],
    (ARRAY['free','starter','pro','business','enterprise'])
        [1 + abs(hashtext('pl:' || i)::bigint) % 5],
    (ARRAY['active','active','active','active','inactive','suspended'])
        [1 + abs(hashtext('st:' || i)::bigint) % 6],
    TIMESTAMPTZ '2021-01-01 00:00:00+00'
        + (abs(hashtext('ct:' || i)::bigint) % (4 * 365 * 24 * 3600)) * interval '1 second'
FROM generate_series(1, 200000) AS i;

-- ---------------------------------------------------------------------------
-- products
-- ---------------------------------------------------------------------------
INSERT INTO products (sku, name, category, price_cents, active, created_at)
SELECT
    'SKU-' || lpad(i::text, 8, '0'),
    'Product ' || i,
    (ARRAY['electronics','books','home','garden','toys','sports','clothing',
           'shoes','beauty','health','grocery','automotive','music','games',
           'office','pet','baby','tools','furniture','jewelry'])
        [1 + abs(hashtext('pc:' || i)::bigint) % 20],
    199 + abs(hashtext('pp:' || i)::bigint) % 500000,
    (abs(hashtext('pa:' || i)::bigint) % 100) < 85,
    TIMESTAMPTZ '2020-01-01 00:00:00+00'
        + (abs(hashtext('pcr:' || i)::bigint) % (5 * 365 * 24 * 3600)) * interval '1 second'
FROM generate_series(1, 50000) AS i;

-- ---------------------------------------------------------------------------
-- orders
-- ---------------------------------------------------------------------------
INSERT INTO orders (customer_id, status, total_cents, channel, reference, created_at, updated_at)
SELECT
    1 + abs(hashtext('oc:' || i)::bigint) % 200000,
    (ARRAY['paid','paid','paid','paid','paid','paid','pending','pending',
           'shipped','cancelled','refunded'])
        [1 + abs(hashtext('os:' || i)::bigint) % 11],
    100 + abs(hashtext('ot:' || i)::bigint) % 500000,
    (ARRAY['web','mobile','api','pos'])
        [1 + abs(hashtext('och:' || i)::bigint) % 4],
    'ORD-' || lpad(i::text, 10, '0'),
    TIMESTAMPTZ '2022-01-01 00:00:00+00'
        + (abs(hashtext('ots:' || i)::bigint) % (3 * 365 * 24 * 3600)) * interval '1 second',
    TIMESTAMPTZ '2022-01-01 00:00:00+00'
        + (abs(hashtext('ots:' || i)::bigint) % (3 * 365 * 24 * 3600)) * interval '1 second'
        + (abs(hashtext('ou:' || i)::bigint) % 2592000) * interval '1 second'
FROM generate_series(1, 1000000) AS i;

-- ---------------------------------------------------------------------------
-- order_items
-- ---------------------------------------------------------------------------
INSERT INTO order_items (order_id, product_id, quantity, unit_price_cents, discount_cents, created_at)
SELECT
    1 + abs(hashtext('oioc:' || i)::bigint) % 1000000,
    1 + abs(hashtext('oipr:' || i)::bigint) % 50000,
    1 + abs(hashtext('oiq:' || i)::bigint) % 10,
    199 + abs(hashtext('oiu:' || i)::bigint) % 500000,
    abs(hashtext('oid:' || i)::bigint) % 5000,
    TIMESTAMPTZ '2022-01-01 00:00:00+00'
        + (abs(hashtext('oits:' || i)::bigint) % (3 * 365 * 24 * 3600)) * interval '1 second'
FROM generate_series(1, 3000000) AS i;

-- ---------------------------------------------------------------------------
-- payments
-- ---------------------------------------------------------------------------
INSERT INTO payments (order_id, provider, method, status, amount_cents, reference, created_at, processed_at)
SELECT
    1 + abs(hashtext('poc:' || i)::bigint) % 1000000,
    (ARRAY['stripe','adyen','paypal','mercadopago'])
        [1 + abs(hashtext('ppr:' || i)::bigint) % 4],
    (ARRAY['credit_card','debit_card','pix','boleto','wallet'])
        [1 + abs(hashtext('pm:' || i)::bigint) % 5],
    (ARRAY['captured','captured','captured','captured','captured',
           'pending','failed','refunded'])
        [1 + abs(hashtext('pst:' || i)::bigint) % 8],
    100 + abs(hashtext('pam:' || i)::bigint) % 500000,
    'PAY-' || lpad(i::text, 10, '0'),
    TIMESTAMPTZ '2022-01-01 00:00:00+00'
        + (abs(hashtext('pts:' || i)::bigint) % (3 * 365 * 24 * 3600)) * interval '1 second',
    CASE
        WHEN abs(hashtext('pst:' || i)::bigint) % 8 < 5
        THEN TIMESTAMPTZ '2022-01-01 00:00:00+00'
             + (abs(hashtext('pts:' || i)::bigint) % (3 * 365 * 24 * 3600)) * interval '1 second'
             + (abs(hashtext('pd:' || i)::bigint) % 3600) * interval '1 second'
    END
FROM generate_series(1, 1000000) AS i;

-- ---------------------------------------------------------------------------
-- events
-- ---------------------------------------------------------------------------
INSERT INTO events (customer_id, event_type, entity_type, entity_id, request_id, payload, created_at)
SELECT
    1 + abs(hashtext('ec:' || i)::bigint) % 200000,
    (ARRAY['page_view','page_view','page_view','page_view','click','click',
           'search','login','logout','purchase'])
        [1 + abs(hashtext('ee:' || i)::bigint) % 10],
    (ARRAY['page','product','order','cart'])
        [1 + abs(hashtext('ent:' || i)::bigint) % 4],
    1 + abs(hashtext('eid:' || i)::bigint) % 50000,
    (substr(md5('event:' || i), 1, 8) || '-' ||
     substr(md5('event:' || i), 9, 4) || '-' ||
     substr(md5('event:' || i), 13, 4) || '-' ||
     substr(md5('event:' || i), 17, 4) || '-' ||
     substr(md5('event:' || i), 21, 12))::uuid,
    jsonb_build_object(
        'source', (ARRAY['web','mobile','api'])[1 + abs(hashtext('es:' || i)::bigint) % 3],
        'duration_ms', abs(hashtext('ed:' || i)::bigint) % 120000
    ),
    TIMESTAMPTZ '2023-01-01 00:00:00+00'
        + (abs(hashtext('ets:' || i)::bigint) % (2 * 365 * 24 * 3600)) * interval '1 second'
FROM generate_series(1, 4000000) AS i;

-- ---------------------------------------------------------------------------
-- sessions
-- ---------------------------------------------------------------------------
INSERT INTO sessions (customer_id, status, device, ip_address, created_at, expires_at)
SELECT
    1 + abs(hashtext('sc:' || i)::bigint) % 200000,
    (CASE
        WHEN abs(hashtext('sst:' || i)::bigint) % 100 < 12 THEN 'active'
        WHEN abs(hashtext('sst:' || i)::bigint) % 100 < 72 THEN 'expired'
        ELSE 'revoked'
     END),
    (ARRAY['desktop','mobile','tablet','api'])
        [1 + abs(hashtext('sd:' || i)::bigint) % 4],
    (abs(hashtext('sip:' || i)::bigint) % 256)::text || '.' ||
    (abs(hashtext('sip2:' || i)::bigint) % 256)::text || '.' ||
    (abs(hashtext('sip3:' || i)::bigint) % 256)::text || '.' ||
    (abs(hashtext('sip4:' || i)::bigint) % 256)::text,
    TIMESTAMPTZ '2023-01-01 00:00:00+00'
        + (abs(hashtext('sts:' || i)::bigint) % (2 * 365 * 24 * 3600)) * interval '1 second',
    TIMESTAMPTZ '2023-01-01 00:00:00+00'
        + (abs(hashtext('sts:' || i)::bigint) % (2 * 365 * 24 * 3600)) * interval '1 second'
        + (1 + abs(hashtext('sexp:' || i)::bigint) % 720) * interval '1 hour'
FROM generate_series(1, 2000000) AS i;

\timing off
