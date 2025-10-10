CREATE TABLE users (
  id        UUID     PRIMARY KEY DEFAULT uuid_generate_v4(),
  email     TEXT     NOT NULL UNIQUE,
  name      TEXT     NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
