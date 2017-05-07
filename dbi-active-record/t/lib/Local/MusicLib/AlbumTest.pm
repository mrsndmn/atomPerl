package Local::MusicLib::AlbumTest;

use Test::Class::Moose extends => 'Local::Test';

use Local::MusicLib::Album;

my $dt = DateTime->now;

my $artist;

my $album;

sub test_attributes {
    my ($self) = @_;
    $self->test_report->plan(1);

    $artist = $self->{'artist'};

    is($album->name, "The Menagerie Inside");
    is($album->artist_id, $artist->id);
    is($album->year, 1999);
    is($album->type, "single");
    is($album->create_time, $dt);
}

sub test_album_insert {
    my ($self) = @_;
    $album = $self->{'album'}; 
    my $insert_ok = $album->insert();
    
    ok($insert_ok);
    
    # my $serialize_dt = $dbh->selectrow_arrayref("SELECT create_time FROM album WHERE id = $id")->[0];
    # is($serialize_dt, $dt->epoch, "artist's create_time serialized");

    return;
}

sub test_album_select {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};


    return 1;
}

sub test_album_update {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};

    return 1; 
}

sub test_album_delete {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};

    return 1; 
}

sub test_album_select_by_artist_id {
    my ($self) = @_;

    my $dbh = $self->{'dbh'};
    return 1;
}

sub test_album_select_by_id {
    my ($self) = @_;

    my $dbh = $self->{'dbh'};
    return 1; 
}

sub test_album_select_by_name {
    my ($self) = @_;

    my $dbh = $self->{'dbh'};
    return 1;
}

sub test_album_select_by_type {
    my ($self) = @_;

    my $dbh = $self->{'dbh'};
    return 1;
}

1;