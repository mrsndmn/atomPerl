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
    my $sql = "SELECT DISTINCT second_id FROM relations WHERE first_id == $id0 ".
                "UNION SELECT DISTINCT first_id FROM relations WHERE second_id == $id0 ".
                "INTERSECT ".
                "SELECT DISTINCT second_id FROM relations WHERE first_id == $id1 ".
                "UNION SELECT DISTINCT first_id FROM relations WHERE second_id == $id1;";
    my $dbh = $self->{'dbh'};
    my $array_ref = $dbh->selectall_arrayref( $sql );
    return  [ map {$_->[0]} @$array_ref ];
}

sub select_friends_by_id {
    my ($self, $ids) = @_;
    my $dbh = $self->{'dbh'};

    my $sql = "SELECT DISTINCT second_id FROM relations WHERE first_id IN (". (join ", ", @$ids).") ".
        "UNION SELECT DISTINCT first_id FROM relations WHERE second_id IN (". (join ", ", @$ids).");";    

    my $array_ref = $dbh->selectall_arrayref( $sql );
    return [ map {$_->[0]} @$array_ref ];
}

sub select_names_by_id {
    my ($self, $ids) = @_;
    my $dbh = $self->{'dbh'};
    my $sql = "SELECT * FROM users WHERE id IN (". (join ", ", @$ids).") ";
    my $array_ref = $dbh->selectall_arrayref( $sql, { Slice => {} });
    return $array_ref;
}

sub select_count_users {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    my $array_count = $dbh->selectall_arrayref(
        "SELECT COUNT(*) FROM users;" );
    return $array_count->[0]->[0];
}

sub select_id_by_name {
    my ($self, $name, $surname) = @_;
    my $dbh = $self->{'dbh'};
    die "you must determine name and surname" if !$name or !$surname;
    my $sql = "SELECT id FROM users WHERE name == \"$name\" and surname == \"$surname\"";
    my $array_ref =  $dbh->selectall_arrayref( $sql);
    return $array_ref->[0];
}


1;