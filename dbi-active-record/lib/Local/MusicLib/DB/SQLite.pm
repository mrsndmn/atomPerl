package Local::MusicLib::DB::SQLite;
use Mouse;
extends 'DBI::ActiveRecord::DB::SQLite';
use YAML::Tiny;

sub _build_connection_params {
    my ($self) = @_;

    # its better to create new module conf reader, but copypaste easier
    #TODO create conf reader module
    my ($volume, $directory, $file) = File::Spec->splitpath(__FILE__);
    my $conf = YAML::Tiny->read( "$directory../etc/config.yml" )->[0];
    
    # enter your db conf
    my $DBMS = $conf->{DBMS};
    die "please, change DBMS to 'sqlite' in you conf if you really want to use it" if $DBMS ne 'sqlite';
    my $dbname = $conf->{dbname};

    return [
        "dbi:SQLite:dbname=$dbname", '', '', { RaiseError => 1 },
        # Foreign key constraints are disabled by default in sqlite
        "PRAGMA foreign_keys = ON;"
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();