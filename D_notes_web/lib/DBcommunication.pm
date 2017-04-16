package DBcommunication;

use strict;
use warnings;

use DDP;
use DBI;
use FindBin;

use Encode qw(encode decode);
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
    # пытался все в одной sql сделать, но че-то хреново в SQLite сделали условия, решил, что оно того не стоит
    #    надо было нармальную субд взять, но ладн
    return undef if ($self->wantID($username));

    my $sql = "INSERT INTO auth (username, password) VALUES( (?), (?) );";
    my $sth = $dbh->prepare($sql);
    $sth->execute($username, $password);
    return 1;
}

sub new_note {
    my ($self, $note_id, $creatot_id, $time, $title, $text, $try_to_share) = @_;
    my @toComparator;
    push @toComparator, $creatot_id, $note_id, '';
    my $ans = "OK\n";
    if (defined $try_to_share) {
        foreach (@$try_to_share) {
            warn $_;
            if (my $local_id = $self->wantID($_)) {
                push @toComparator, ($local_id, $note_id, $creatot_id) if $local_id != $creatot_id;
            } else {
                $ans = $ans."Unknown: $_\n";
            }
        }
    } 
    p @toComparator;
    warn $ans;
    my $dbh = $self->{'dbh'};
    my $NoteSQL = 'INSERT INTO notes values (?, ?, ?, ?)';
    my $sth = $dbh->prepare($NoteSQL);
    $sth->execute($note_id, $title, $text, time);

    my $comparatorSQL = ' INSERT INTO comparator values '.(join ',', (("(?, ?, ?)")x(scalar(@toComparator)/3)));
    $sth = $dbh->prepare($comparatorSQL);
    $sth->execute(@toComparator);
    return $ans;
}

sub getNotes {
    my ($self, $user_id) = @_;

    my $dbh = $self->{'dbh'};
    
    my $sql = 'select note_id, title, body, got_from, time from comparator '.
                 'join notes '.
                 'on '.
                 'comparator.note_id == notes.id and comparator.who_id = ?';
    my $notesArr = $dbh->selectall_arrayref( $sql, { Slice => {} }, $user_id );

    # select note_id, who_id from comparator where got_from == ?;
    # как в social network проблема, новерняка есть приемчик. Как правильно-то??
    # когда есть много строк, соответствующих какому-то полю
    # наверное, надо было по-другому посторить таблицы в бд, сдаюсь
    # или это нормально?  :sweat:
    return {} if !scalar @$notesArr;

    my $sth = $dbh->prepare('SELECT who_id FROM comparator WHERE note_id == ? and got_from = ? and got_from != \'\';');

    foreach my $key (keys %{$notesArr->[0]}) {
        foreach my $note (@$notesArr) {
            $note->{$key} = decode('utf8', $note->{$key});
        }
    }

    foreach (@$notesArr) {
        $_->{'body'} = [ split '\r\n', $_->{'body'} ];
        my $note_id = $_->{'note_id'};
        warn $note_id."\n".$user_id;
        $sth->execute($note_id, $user_id);
        my @sharedWith = @{[ map { $self->wantNick($_) } map { @{$_} } @{$sth->fetchall_arrayref()}]};
        warn @sharedWith;
        $_->{'sharedWith'} = \@sharedWith;
        $_->{'got_from'} = $self->wantNick($_->{'got_from'});
        $_->{'note_id'} =  unpack 'H*', pack 'L', $_->{'note_id'};
    }

    return $notesArr;
}

sub want_note {
    my ($self, $note_id) = @_;

    my $dbh = $self->{'dbh'};
    my $note = $dbh->selectrow_hashref('SELECT id, title, body, time FROM notes where id = ?', {}, $note_id);
    
    $note->{id} = unpack 'H*', pack 'L', $note->{id};

    foreach my $key (keys %$note) {
            $note->{$key} = decode('utf8', $note->{$key});
    }

    return $note;
}

sub note_id_exists {
    my ($self, $id) = @_;
    my $dbh = $self->{'dbh'};
    return $dbh->selectrow_arrayref(
                    'SELECT COUNT(*) FROM notes WHERE id = (?)',
                    {},
                    $id,
                    )->[0];
    
}

sub wantNick  {
    my ($self, $id) = @_;
    warn $id;
    return if !$id;
    my $dbh = $self->{'dbh'};
    my $isOk = $dbh->selectrow_arrayref(
                    'SELECT username FROM auth WHERE id = (?)',
                    {},
                    $id,
                    );
    return $isOk? $isOk->[0] : undef;
}

sub wantID {
    my ($self, $username) = @_;
    my $dbh = $self->{'dbh'};
    my $isOk = $dbh->selectrow_arrayref(
                    'SELECT id FROM auth WHERE username = (?)',
                    {},
                    $username,
                    );

    p $isOk;
    return $isOk? $isOk->[0] : undef;
}
1;