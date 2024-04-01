CREATE TABLE users (
  id serial PRIMARY KEY,
  username varchar(32) UNIQUE NOT NULL,
  pw_hash text NOT NULL,
  join_date timestamp DEFAULT NOW(),
  wins int NOT NULL DEFAULT 0,
  losses int NOT NULL DEFAULT 0,
);