CREATE TABLE artist (
    id INTEGER primary key,
    name TEXT,
    country TEXT,
    create_time INTEGER
);

CREATE INDEX index_name ON artist(name);
