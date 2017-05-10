CREATE TABLE artist (
    id INTEGER primary key AUTOINCREMENT,
    name varchar(80),
    country varchar(10),
    create_time INTEGER
);

CREATE INDEX index_artist_name ON artist(name);
