package Local::Test;

use Test::Class::Moose;
use FindBin qw( $Bin );
use lib "$Bin/../lib";

use Local::MusicLib::Artist;

sub test_startup {
    my ($self) = @_;

    $self->next::method();
    
    return;
}
# todo test order, alb_id, tr_id;
sub test_setup {
    my ($self) = @_;
    my $artist = Local::MusicLib::Artist->new();
    $artist->name("Midas Fall");
    $artist->country("UK");
    my $dt = DateTime->now;
    $artist->create_time($dt);
    my $insert_ok = $artist->insert();

    die "previosly test artist" unless $insert_ok or not defined $artist->id;

    $self->{'artist'} = $artist;

    my $album = Local::MusicLib::Album->new();
    $album->name("The Menagerie Inside");
    $album->artist_id($artist->id);
    $album->year(1999);
    $album->type("single");
    $album->create_time($dt);

    $self->{'album'} =  $album;

    my $track = Local::MusicLib::Track->new()

    $track->name();
    $track->album_id();
    $track->extension();
    $track->create_time();
    $track->duration();

    return;
}

# sub test_setup {
#     my ($self) = @_;

#     $self->{schema}->txn_begin();

#     return;
# }

# sub test_teardown {
#     my ($self) = @_;

#     $self->{schema}->txn_rollback();

#     return;
# }

1;