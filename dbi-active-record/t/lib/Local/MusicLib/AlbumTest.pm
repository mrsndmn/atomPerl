package Local::MusicLib::AlbumTest;

use Test::Class::Moose extends => 'Local::Test';

use Test::Class::Moose;


sub test_album_insert {
    my ($self) = @_;
    use DDP;
    warn p $self;    
    pass "I tested something!";
    return;
}

sub test_album_select {
    my ($self) = @_;

}

sub test_album_update {
    my ($self) = @_;

}

sub test_album_delete {
    my ($self) = @_;

}

sub test_album_select_by_artist_id {
    my ($self) = @_;

}

sub test_album_select_by_id {
    my ($self) = @_;

}

sub test_album_select_by_name {
    my ($self) = @_;

}

sub test_album_select_by_type {
    my ($self) = @_;

}

1;