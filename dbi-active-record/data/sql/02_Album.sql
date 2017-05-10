CREATE TABLE album (
    id INTEGER primary key,
    name TEXT,
    artist_id INTEGER,
    year INTEGER,
    type TEXT,
    create_time INTEGER,
    FOREIGN KEY(artist_id) REFERENCES artist(id)
);
CREATE INDEX index_name ON album(name);
CREATE INDEX index_artist_id ON album(artist_id);
CREATE INDEX index_type ON album(type);
