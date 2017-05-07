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
    $artist->name("Midas Fall");
    $artist->country("UK");
    my $dt = DateTime->now;
    $artist->create_time($dt);
    my $insert_ok = $artist->insert();

    die "previosly test artist" unless $insert_ok or not defined $artist->id;

    $self->{'artist'} = $artist;

    my $album = Local::MusicLib::Album->new();
    $self->{'album'} =  $album;

    my $track = Local::MusicLib::Track->new();
    $self->{'track'} = $track;    

    $self->next::method();

    return;
}

sub test_shutdown {
    my ($self) = @_;
    # $self->{$_}->delete() foreach (qw(track artist album));

}


1;