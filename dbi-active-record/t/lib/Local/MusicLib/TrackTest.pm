package Local::MusicLib::TrackTest;

use Test::Class::Moose extends => 'Local::Test';


use Local::MusicLib::Track;
my $track = Local::MusicLib::Track->new();

sub test_track_insert {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    return;
}

sub test_track_select {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    return;
}

sub test_track_update {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    return;
}

sub test_track_delete {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    return;
}

sub test_track_select_by_id {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    return;
}

sub test_track_select_by_album_id {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    return;
}

sub test_track_select_by_name {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    
    return;
}

1;