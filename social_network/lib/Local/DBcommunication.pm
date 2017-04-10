package Local::DBcommunication;

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
    return bless \%params, $class;
}

sub create {
    my $self= shift;
    my $dbFile = $self->{'dbFile'};
    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbFile", "","", { RaiseError => 1 }) or die "Cannot connect this db:\n";
    #warn "dbh created";
    $self->{'dbh'} = $dbh;
    return $self;
}

sub doIt {
    my ($self, $sql, @args) = @_;
    my $dbh = $self->{'dbh'};
    my $sth = $dbh->prepare( $sql );
    $sth->execute(@_);    
}

sub getLonely (
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    my $sql = 'select id from users except select distinct first_id from test order by first_id;'
    my $sth = $dbh->prepare( $sql );
    $sth->execute();
    
)

1;