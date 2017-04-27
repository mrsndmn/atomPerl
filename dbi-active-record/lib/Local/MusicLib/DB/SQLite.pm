package Local::MusicLib::DB::SQLite;
use Mouse;
extends 'DBI::ActiveRecord::DB::SQLite';

sub _build_connection_params {
    my ($self) = @_;
    return [
        'dbi:SQLite:dbname=/data/muslib.db', '', '', {}
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();