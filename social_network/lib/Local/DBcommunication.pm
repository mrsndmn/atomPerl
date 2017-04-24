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

sub select_lonely {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    my $array_ref = $dbh->selectall_arrayref(
            "SELECT id FROM users EXCEPT SELECT DISTINCT first_id FROM relations EXCEPT SELECT DISTINCT second_id FROM relations;"
        );
    return [ map {$_->[0]} @$array_ref ];
}
sub select_common_friends {
    my ($self, $id0, $id1) = @_;
    warn $id0, $id1;
    my $sql = "SELECT * FROM (SELECT DISTINCT second_id FROM relations WHERE first_id == ? ".
                "UNION SELECT DISTINCT first_id FROM relations WHERE second_id == ?) ".
                "INTERSECT ".
                "SELECT * FROM (SELECT DISTINCT second_id FROM relations WHERE first_id == ? ".
                "UNION SELECT DISTINCT first_id FROM relations WHERE second_id == ?)".
                ""
                ;
    my $dbh = $self->{'dbh'};
    my $array_ref = $dbh->selectall_arrayref( $sql, {}, $id0, $id0, $id1, $id1 );
    return  [ map {$_->[0]} @$array_ref ];
}

sub select_friends_by_id {
    my ($self, $ids) = @_;
    my $dbh = $self->{'dbh'};

    my $sql = "SELECT DISTINCT second_id FROM relations WHERE first_id IN (". (join ", ", ('?') x @$ids).") ".
        "UNION SELECT DISTINCT first_id FROM relations WHERE second_id IN (". (join ", ", ('?') x @$ids).")";    

    my $array_ref = $dbh->selectall_arrayref( $sql, {}, @$ids, @$ids );
    return [ map {$_->[0]} @$array_ref ];
}

sub select_names_by_id {
    my ($self, $ids) = @_;
    my $dbh = $self->{'dbh'};
    my $sql = "SELECT * FROM users WHERE id IN (". (join ", ", ('?') x @$ids).") ";
    my $array_ref = $dbh->selectall_arrayref( $sql, { Slice => {} }, @$ids);
    return $array_ref;
}

sub select_max_id {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    my $array_count = $dbh->selectall_arrayref(
        "SELECT id FROM users ORDER BY id  DESC LIMIT 1;" );
    return $array_count->[0]->[0];
}

sub select_id_by_name {
    my ($self, $name, $surname) = @_;
    my $dbh = $self->{'dbh'};
    die "you must determine name and surname" if !$name or !$surname;
    my $sql = "SELECT id FROM users WHERE name == ? and surname == ? ";
    my $array_ref =  $dbh->selectall_arrayref( $sql, $name, $surname);
    return $array_ref->[0];
}


1;