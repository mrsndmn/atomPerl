CREATE TABLE artist (
    id INTEGER primary key AUTOINCREMENT,
    name varchar(80),
    country varchar(10),
    create_time INTEGER
);

CREATE INDEX index_artist_name ON artist(name);

CREATE TABLE album (
    id INTEGER primary key,
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

CREATE TABLE tracks (
    id INTEGER primary key AUTOINCREMENT,
    name varchar(80),
    extension varchar(20),
    album_id INTEGER,
    create_time INTEGER,
    duration INTEGER,
    FOREIGN KEY(album_id) REFERENCES album(id)
);

CREATE INDEX index_track_name ON tracks(name);
CREATE INDEX index_album_id ON tracks(album_id);
