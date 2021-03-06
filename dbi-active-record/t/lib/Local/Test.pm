package Local::Test;

use Test::Class::Moose;

use FindBin qw( $Bin );
use lib "$Bin/../lib";

use Local::MusicLib::Artist;
use Local::MusicLib::Track;

sub test_startup {
    my ($self) = @_;

    $self->{'dbh'} = Local::MusicLib::Artist->meta->db_class->instance->connection;

    my $artist = Local::MusicLib::Artist->new();
    $self->{'artist'} = $artist;

    my $album = Local::MusicLib::Album->new();
    $self->{'album'} =  $album;

    my $track = Local::MusicLib::Track->new();
    $self->{'track'} = $track;    

    # $self->next::method();

    return;
}

sub test_shutdown {
    my ($self) = @_;
    foreach (qw(track album artist)) {
        eval {$self->{$_}->delete()};
        warn "delete not works in $_" if $@;
    }
    $self->{dbh}->disconnect;

}

## how to break on error
sub test_mus_lib : Test( no_plan ) {
    my ($self) = @_;

    # subtest 'using MusicLib' => sub {
    #     BEGIN { 
    #         use_ok("Local::MusicLib::Artist");
    #         use_ok("Local::MusicLib::Track");
    #         use_ok("Local::MusicLib::Album"); 
    #     }
    # };


    subtest 'Artist testing' => \&Local::MusicLib::ArtistTest::test_artist,
        $self->{dbh},
        $self->{artist}, 
        $self->{album}, 
        $self->{track};

    subtest 'Album testing' => \&Local::MusicLib::AlbumTest::test_album, 
        $self->{dbh},
        $self->{artist}, 
        $self->{album}, 
        $self->{track};

    subtest 'Track testing' => \&Local::MusicLib::TrackTest::test_track,
        $self->{dbh},       
        $self->{artist}, 
        $self->{album}, 
        $self->{track};

}

1;