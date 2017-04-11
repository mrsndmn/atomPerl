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

    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbFile", "","", { RaiseError => 1 }) or die "Cannot connect this db:\n";
    #warn "dbh created";
    $params{'dbh'} = $dbh;

    return bless \%params, $class;
}

# sub doIt {
#     my ($self, $sql, @args) = @_;
#     my $dbh = $self->{'dbh'};
#     my $sth = $dbh->prepare( $sql );
#     $sth->execute(@_);    
# }

sub select_lonely {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    my $array_ref = $dbh->selectall_arrayref(
            "SELECT id FROM users EXCEPT SELECT DISTINCT first_id FROM relations EXCEPT SELECT DISTINCT second_id FROM relations;",
        )   or die "smth went wrong in get lonely";
    return [ map {$_->[0]} @$array_ref ];
}

sub select_friends_by_id {
    warn "here";
    my ($self, $ids) = @_;
    my $dbh = $self->{'dbh'};

    my $array_ref = $dbh->selectall_arrayref(
        "SELECT DISTINCT second_id FROM relations WHERE first_id IN (". (join ", ", ("?") x scalar(@$ids))") ".
        "UNION SELECT DISTINCT first_id FROM relations WHERE second_id IN (". (join ", ", ("?") x scalar(@$ids)).");",
        {}, @$ids, @$ids
        ) or die "smth went wrong in get_friends_by_id";

    return [ map {$_->[0]} @$array_ref ];
}

sub select_names_by_id {
    my ($self, $id) = @_;
    my $dbh = $self->{'dbh'};
    my $array_ref = $dbh->selectall_arrayref(
        "SELECT name, surname FROM users WHERE id IN (". (join ", ", ("?") x scalar(@$id)) .")",
        { Slice => {} }, @$id
        ) or die "smth went wrong in get_names_by_id";
    return $array_ref;
}

sub select_count_users {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    my $array_count = $dbh->selectall_arrayref(
        "SELECT COUNT(*) FROM users;" ) or die "smth went wrong in get_names_by_id";
    p $array_count;
    return $array_count->[0]->[0];
}


1;