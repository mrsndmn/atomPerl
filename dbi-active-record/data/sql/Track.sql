CREATE TABLE tracks (
    id INTEGER primary key,
    name TEXT,
    extension TEXT,
    album_id INTEGER,
    create_time INTEGER,
    duration INTEGER,
    FOREIGN KEY(album_id) REFERENCES album(id)
);