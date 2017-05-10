CREATE TABLE album (
    id INTEGER primary key,
    name TEXT,
    artist_id INTEGER,
    year INTEGER,
    type TEXT,
    create_time INTEGER,
    FOREIGN KEY(artist_id) REFERENCES artist(id)
);