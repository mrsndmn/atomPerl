package Local::MusicLib::TrackTest;

use Test::Class::Moose extends => 'Local::Test';

use Local::MusicLib::Track;

use DDP;

sub test_track {
    my ($test) = @_;

    my $dbh = $test->{'dbh'};
    my $artist = $test->{'artist'};
    my $album = $test->{'album'};
    my $track = $test->{'track'};
    
    subtest attributes => sub {
        my $track = shift;

        my $duration = DateTime->new(seconds => 180)->hms;
        my $dt = DateTime->now;

        $track->name("The Phantom of the Opera");
        $track->album_id($album->id);
        $track->extension("mp3");
        $track->duratoin($duration);
        $track->create_time($dt);
        
        is($track->name, "The Phantom of the Opera", 'track name set');
        is($track->album_id,    , 'track album_id set');
        is($track->extension, "mp3", 'track extension set');
        is($track->duratoin, $duration, 'track duration set');
        is($track->create_time, $dt, 'track date/time set');

        return;
    }, $track;

    subtest track_insert => sub {
        my ($track, $dbh) = @_;

        my $insert_ok = $track->insert();
        my $id = $track->id;

        ok($insert_ok, 'insert track');
        ok(defined $id, 'track id defined');

        my $trck_from_db = $dbh->selectrow_hashref("SELECT * FROM tracks WHERE id = ?", {Slice => {}}, $id);
        
        is($trck_from_db->{'name'}, $track->name, 'select name from db');
        is($trck_from_db->{'album_id'}, $track->album_id, 'select album_id from db');
        is($trck_from_db->{'extension'}, $track->extension, 'select extension from db');
        is($trck_from_db->{'duration'}, $track->duration, 'select duration from db');
        is($trck_from_db->{'create_time'}, $track->create_time->epoch, "track's create_time serialized");
        
        return;
    }, $track, $dbh;
    
    subtest track_select => sub {
        my ($track, $dbh) = @_;
        
        my $id = $track->id;
        my $selected_trck = $track->select("id", $id);
        my $trck_from_db = $dbh->selectrow_hashref("SELECT * FROM tracks WHERE id = ?", {Slice => {}}, $id);

        my $sec = $trck_from_db->{'create_time'};
        $trck_from_db->{'create_time'} = DateTime::Duration->new(seconds => $sec)->hms;

        is_deeply($selected_trck, $trck_from_db, "select() track works");

        return;
    }, $track, $dbh;

    # subtest track_select_by_album_id => sub {
    #     my ($track) = @_;

    #     my $art_id = $track->album_id;
        
    #     my $trck_from_select = $track->select('album_id', $art_id);
    #     my $other_trck = $track->select_by_album_id($art_id);
        
    #     is_deeply($other_trck, $trck_from_select, 'method select_by_album_id');

    #     return;
    # }, $track;

    foreach my $field (qw(id album_id name)) {

        subtest "track_select_by_$field" => sub {
            my ($track) = @_;
            
            my $trck_from_select = $track->select($field, $track->$field);
            my $other_trck;
            
            my $ev = '$other_trck = $track->'."select_by_$field".'($track->$field);';
            eval $ev;
            fail "eval error" if @!;

            is_deeply($other_trck, $trck_from_select, "method select_by_$field");

            return;
        }, $track;

    }

    subtest track_update => sub {
        my ($track) = @_;

        $track->name("Opera");
        $track->extension("flack");

        $track->update();

        my $selected_trck = $track->select_by_id($track->id);

        is($selected_trck->{name}, $track->name, "updated name");
        is($selected_trck->{extension}, $track->extension, "updated extension");

        return; 
    }, $track;

    subtest track_delete => sub {
        my ($track) = @_;
        
        $track->delete();
        my $selected_trck = $track->select_by_id($track->id);
        is($selected_trck, undef, "delete successful");

        return; 
    }, $track;
}

1;



