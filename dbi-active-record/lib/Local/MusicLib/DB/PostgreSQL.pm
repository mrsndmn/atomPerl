package Local::MusicLib::DB::PostgreSQL;
use Mouse;
extends 'DBI::ActiveRecord::DB::PostgreSQL';

my $dbname = 'muslib';
my $username = 'mrsndmn';
my $password = '123qwe';

sub _build_connection_params {
    my ($self) = @_;
    return [
        'dbi:Pg:dbname=$dbname;',
        $username,
        $password,
        { RaiseError => 1 },
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();