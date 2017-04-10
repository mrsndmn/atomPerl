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

sub getLonely {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    my $sql = 'SELECT name, surname FROM users WHERE id IN (SELECT id FROM users EXCEPT SELECT DISTINCT first_id FROM test EXCEPT SELECT DISTINCT second_id FROM test);'
    my $sth = $dbh->prepare( $sql );
    $sth->execute();
    
}

sub get_friends {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};

    # select second_id from test where (first_id == 1) union select first_id from test where second_id == 1 ;


}

sub get_names {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};

    # select name, surname from users where id == ?

}

sub 

1;