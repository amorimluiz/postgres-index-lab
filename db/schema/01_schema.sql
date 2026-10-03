-- =============================================================================
-- PostgreSQL Index Lab - Schema
-- =============================================================================
-- This schema is intentionally poor in secondary indexes. The only indexes that
-- exist are:
--   * PRIMARY KEY indexes (unavoidable),
--   * UNIQUE constraint indexes (unavoidable),
--   * a small set of "legacy" indexes on the `sessions` table, which model a
--     real system that accumulated indexes over time.
--
-- Everything else has no index. Finding out which indexes are needed to make
-- the challenge queries fast is the whole point of the lab.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- customers
-- ---------------------------------------------------------------------------
CREATE TABLE customers (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name  text        NOT NULL,
    email      text        NOT NULL UNIQUE,
    phone      text,
    country    char(2)     NOT NULL,
    plan       text        NOT NULL,
    status     text        NOT NULL,
    created_at timestamptz NOT NULL
);

COMMENT ON TABLE customers IS 'End customers of the platform (~200k rows).';

-- ---------------------------------------------------------------------------
-- products
-- ---------------------------------------------------------------------------
CREATE TABLE products (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku         text        NOT NULL UNIQUE,
    name        text        NOT NULL,
    category    text        NOT NULL,
    price_cents integer     NOT NULL,
    active      boolean     NOT NULL,
    created_at  timestamptz NOT NULL
);

COMMENT ON TABLE products IS 'Product catalog (~50k rows).';

-- ---------------------------------------------------------------------------
-- orders
-- ---------------------------------------------------------------------------
CREATE TABLE orders (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint      NOT NULL REFERENCES customers (id),
    status      text        NOT NULL,
    total_cents bigint      NOT NULL,
    channel     text        NOT NULL,
    reference   text        NOT NULL,
    created_at  timestamptz NOT NULL,
    updated_at  timestamptz NOT NULL
);

COMMENT ON TABLE orders IS 'Orders placed by customers (~1M rows).';

-- ---------------------------------------------------------------------------
-- order_items
-- ---------------------------------------------------------------------------
CREATE TABLE order_items (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id         bigint      NOT NULL REFERENCES orders (id),
    product_id       bigint      NOT NULL REFERENCES products (id),
    quantity         integer     NOT NULL,
    unit_price_cents integer     NOT NULL,
    discount_cents   integer     NOT NULL,
    created_at       timestamptz NOT NULL
);

COMMENT ON TABLE order_items IS 'Line items of an order (~3M rows).';

-- ---------------------------------------------------------------------------
-- payments
-- ---------------------------------------------------------------------------
CREATE TABLE payments (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id     bigint      NOT NULL REFERENCES orders (id),
    provider     text        NOT NULL,
    method       text        NOT NULL,
    status       text        NOT NULL,
    amount_cents bigint      NOT NULL,
    reference    text        NOT NULL,
    created_at   timestamptz NOT NULL,
    processed_at timestamptz
);

COMMENT ON TABLE payments IS 'Payments associated with orders (~1M rows).';

-- ---------------------------------------------------------------------------
-- events
-- ---------------------------------------------------------------------------
CREATE TABLE events (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id bigint      NOT NULL REFERENCES customers (id),
    event_type  text        NOT NULL,
    entity_type text        NOT NULL,
    entity_id   bigint      NOT NULL,
    request_id  uuid        NOT NULL,
    payload     jsonb       NOT NULL,
    created_at  timestamptz NOT NULL
);

COMMENT ON TABLE events IS 'Product/usage telemetry (~4M rows).';

-- ---------------------------------------------------------------------------
-- sessions
-- ---------------------------------------------------------------------------
-- This table is the subject of the read-vs-write challenge. It models a table
-- that already carries several indexes from previous "optimisation rounds".
-- No challenge requires you to keep them; no challenge forbids you to touch
-- them either.
CREATE TABLE sessions (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  bigint      NOT NULL REFERENCES customers (id),
    status       text        NOT NULL,
    device       text        NOT NULL,
    ip_address   text        NOT NULL,
    created_at   timestamptz NOT NULL,
    expires_at   timestamptz NOT NULL
);

COMMENT ON TABLE sessions IS 'User sessions (~2M rows) with pre-existing indexes.';

CREATE INDEX sessions_customer_id_idx        ON sessions (customer_id);
CREATE INDEX sessions_customer_created_idx   ON sessions (customer_id, created_at);
CREATE INDEX sessions_status_idx             ON sessions (status);
CREATE INDEX sessions_created_at_idx         ON sessions (created_at);
CREATE INDEX sessions_customer_status_idx    ON sessions (customer_id, status, created_at);
