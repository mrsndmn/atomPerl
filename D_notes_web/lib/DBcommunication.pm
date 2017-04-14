package DBcommunication;

use strict;
use warnings;

use DDP;
use DBI;
use FindBin;

# DBcommunication->new( dbFile => 'dbFile' );
sub new {
    my ($class, %params) = @_;
    die "You must define \'dbFile\' in constructor" if !exists $params{'dbFile'};
    my $dbFile = "$FindBin::Bin/../data/".$params{'dbFile'};
    die "No such file $dbFile" if ! -e $dbFile;
    $params{'dbFile'} = $dbFile;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbFile", "","", { RaiseError => 1 }) or die "Cannot connect this db:\n";
    warn "dbh created";
    $params{'dbh'} = $dbh;
    return bless \%params, $class;
}

sub isValid {
    my ($self, $username, $password) = @_;
    warn "VALIDATION ", $username, " | ", $password;
    my $dbh = $self->{'dbh'};
    return $dbh->selectrow_arrayref(
                    'SELECT COUNT(*) FROM auth WHERE username = (?) and password == (?)',
                    {},
                    $username,
                    $password
                    )->[0];
}

sub newUser {
    my ($self, $username, $password) = @_;
    warn "NEW USER ", $username, " | ", $password;
    my $dbh = $self->{'dbh'};
    if ($self->nick_exists($username)) {
        warn "nik EXISTS";
        return 0;
    }
    my $sql = "INSERT INTO auth (username, password) VALUES( (?), (?) );";
    my $sth = $dbh->prepare($sql);
    $sth->execute($username, $password);
    return 1;
}

sub nick_exists {
    my ($self, $username) = @_;
    warn "nick UNique check ", $username;
    my $dbh = $self->{'dbh'};
    return $dbh->selectrow_arrayref(
                    'SELECT COUNT(*) FROM auth WHERE username = (?)',
                    {},
                    $username,
                    )->[0];
}

1;