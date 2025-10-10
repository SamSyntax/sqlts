CREATE TABLE posts (
  id         UUID     PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id  UUID     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      TEXT     NOT NULL,
  body       TEXT     NOT NULL,
  published  BOOLEAN  NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
