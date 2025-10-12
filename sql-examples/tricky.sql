CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');

CREATE DOMAIN trimmed_text AS TEXT
  CHECK (TRIM(VALUE) = VALUE);

CREATE TABLE "User" (
  "user_id"    UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         trimmed_text    NOT NULL,
  bio          TEXT            DEFAULT '',
  email        CITEXT          UNIQUE,
  preferences  JSONB           DEFAULT '{}'::jsonb,
  tags         TEXT[]          DEFAULT ARRAY['new_user']::TEXT[],
  moods        mood[]          NOT NULL,
  created_at   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  referrer_id  UUID            REFERENCES "User"(user_id) ON DELETE SET NULL,
  CHECK (char_length(name) <= 50)
);

CREATE TYPE address AS (
  street TEXT,
  city   TEXT,
  zip    TEXT
);

CREATE TABLE order_header (
  order_id    BIGSERIAL,
  user_ref    UUID          NOT NULL REFERENCES "User"(user_id),
  ship_address address      NOT NULL,
  order_date  DATE          NOT NULL DEFAULT CURRENT_DATE,
  PRIMARY KEY (order_id, user_ref)
);

CREATE TABLE order_items (
  "order-id"    BIGINT       NOT NULL,
  "user-ref"    UUID         NOT NULL,
  item_id       INTEGER      NOT NULL,
  quantity      SMALLINT     NOT NULL CHECK (quantity > 0),
  price_cents   INTEGER      NOT NULL CHECK (price_cents >= 0),
  PRIMARY KEY ("order-id","user-ref",item_id),
  FOREIGN KEY ("order-id","user-ref")
    REFERENCES order_header(order_id,user_ref)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE VIEW recent_orders AS
  SELECT user_ref, COUNT(*) AS cnt
  FROM order_header
  WHERE order_date > now() - INTERVAL '30 days'
  GROUP BY user_ref;

CREATE MATERIALIZED VIEW recent_items AS
  SELECT oi.item_id, SUM(oi.quantity) AS total_q
  FROM order_items oi
  GROUP BY oi.item_id;
