CREATE TABLE "Users" (
  "user_id"    UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         trimmed_text    NOT NULL,
  bio          TEXT            DEFAULT '',
  email        CITEXT          UNIQUE,
  preferences  JSONB           DEFAULT '{}'::jsonb,
  tags         TEXT[]          DEFAULT ARRAY['new_user']::TEXT[],
  moods        mood[]          NOT NULL,
  dupa         BLOB(20)         NOT NULL,
  created_at   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  referrer_id  UUID            REFERENCES "User"(user_id) ON DELETE SET NULL,
  CHECK (char_length(name) <= 50)
);
