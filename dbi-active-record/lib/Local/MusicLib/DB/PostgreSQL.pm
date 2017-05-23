package Local::MusicLib::DB::PostgreSQL;
use Mouse;
extends 'DBI::ActiveRecord::DB::PostgreSQL';

# use Carp qw/confess/;
use YAML::Tiny;

sub _build_connection_params {
    my ($self) = shift;

    # its better to create new module conf reader, but copypaste easier
    #TODO create conf reader module
    my ($volume, $directory, $file) = File::Spec->splitpath(__FILE__);
    my $conf = YAML::Tiny->read( "$directory../etc/config.yml" )->[0];
    
    # enter your db conf
    my $DBMS = $conf->{DBMS};
    die "please, change DBMS to 'postgres' in you conf if you really want to use it\n"
        ."Or use Local::MusicLib::DB::SQLite in your entities" 
        if $DBMS ne 'postgres';
        
    my $dbname = $conf->{dbname};
    my $host = $conf->{host};
    my $username = $conf->{username};
    my $password = $conf->{password};

    warn "define db configuration in config\nit's here: $directory../etc/config.yml\n" unless defined $dbname && $username && $password;

    return [
        "dbi:Pg:dbname=$dbname;host=$host",
        $username,
        $password,
        { RaiseError => 1 },
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();