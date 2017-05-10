CREATE TABLE artist (
    id SERIAL primary key   ,
    name varchar(80),
    country varchar(10),
    create_time INTEGER
);

CREATE INDEX index_artist_name ON artist(name);
