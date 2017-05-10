CREATE TABLE album (
    id SERIAL primary key,
    name varchar(80),
    artist_id INTEGER,
    year INTEGER,
    type varchar(20),
    create_time INTEGER,
    FOREIGN KEY(artist_id) REFERENCES artist(id)
);
CREATE INDEX index_album_name ON album(name);
CREATE INDEX index_artist_id ON album(artist_id);
CREATE INDEX index_type ON album(type);
