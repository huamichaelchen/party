-- TODO: Get Goose, or write a script to run up/down migrations

-- Up

DROP TABLE IF EXISTS party.events;

CREATE TABLE party.events (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    title VARCHAR(200),
    description text,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
