package Local::MusicLib::DB::SQLite;
use Mouse;
extends 'DBI::ActiveRecord::DB::SQLite';

sub _build_connection_params {
    my ($self) = @_;
    # Foreign key constraints are disabled by default in sqlite
    return [
        'dbi:SQLite:dbname=data/muslib.db', '', '', { RaiseError => 1 },
        "PRAGMA foreign_keys = ON;"
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();