CREATE TABLE tracks (
    id INTEGER primary key,
    name TEXT,
    extension TEXT,
    album_id INTEGER,
    create_time INTEGER,
    duration INTEGER,
    FOREIGN KEY(album_id) REFERENCES album(id)
);

CREATE INDEX index_name ON tracks(name);
CREATE INDEX index_album_id ON tracks(album_id);
