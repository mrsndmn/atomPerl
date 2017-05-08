package Local::MusicLib::AlbumTest;

use Test::Class::Moose extends => 'Local::Test';

use Local::MusicLib::Album;

use DDP;

sub test_album {
    my ($dbh, $artist, $album, $track) = @_;

    my $dt = DateTime->now;
    
    # my $dbh = $test->{'dbh'};
    # my $artist = $test->{'artist'};
    # my $album = $test->{'album'};
    # my $track = $test->{'track'};
    
    subtest attributes => sub {
        my $album = shift;

        $album->name("The Menagerie Inside");
        $album->artist_id($artist->id);
        $album->year(1999);
        $album->type("single");
        $album->create_time($dt);
        
        is($album->name, "The Menagerie Inside", 'album name set');
        is($album->artist_id, $artist->id, 'album artist_id set');
        is($album->year, 1999, 'album year set');
        is($album->type, "single", 'album type set');
        is($album->create_time, $dt, 'album date/time set');
        return;
    }, $album;

    subtest album_insert => sub {
        my ($album, $dbh) = @_;

        my $insert_ok = $album->insert();
        my $id = $album->id;

        ok($insert_ok, 'insert album');
        ok(defined $id, 'album id defined');

        my $alb_from_db = $dbh->selectrow_hashref("SELECT * FROM album WHERE id = ?", {Slice => {}}, $id);
        
        is($alb_from_db->{'name'}, $album->name, 'select name from db');
        is($alb_from_db->{'artist_id'}, $album->artist_id, 'select artist_id from db');
        is($alb_from_db->{'year'}, $album->year, 'select year from db');
        is($alb_from_db->{'type'}, $album->type, 'select type from db');
        is($alb_from_db->{'create_time'}, $album->create_time->epoch, "album's create_time serialized");
        
        return;
    }, $album, $dbh;
    
    subtest album_select => sub {
        my ($album, $dbh) = @_;
        
        my $id = $album->id;
        my $selected_alb = $album->select("id", $id);
        my $alb_from_db = $dbh->selectrow_hashref("SELECT * FROM album WHERE id = ?", {Slice => {}}, $id);

        my $epoch = $alb_from_db->{'create_time'};
        $alb_from_db->{'create_time'} = DateTime->from_epoch(epoch => $epoch);

        is_deeply($selected_alb, $alb_from_db, "select() album works");

        my $result = $album->select("name", ["The Menagerie Inside"]);
        ok((List::Util::all {$_->name eq 'The Menagerie Inside'} @$result), "selected list of albums");


        return;
    }, $album, $dbh;

    foreach my $field (qw(id artist_id name type)) {

        subtest "album_select_by_$field" => sub {
            my ($album) = @_;
            
            my $alb_from_select = $album->select($field, $album->$field);
            my $other_alb;
            
            my $ev = '$other_alb = $album->'."select_by_$field".'($album->$field);';
            eval $ev;
            fail "eval error" if @!;

            is_deeply($other_alb, $alb_from_select, "method select_by_$field");

            return;
        }, $album;

    }

    subtest album_update => sub {
        my ($album) = @_;

        $album->name("Masquerade");
        $album->year(1999);

        $album->update();

        my $alb = $album->select_by_id($album->id);

        is($alb->{name}, $album->name, "updated name");
        is($alb->{year}, $album->year, "updated year");

        return; 
    }, $album;

    subtest album_delete => sub {
        my ($album) = @_;
        
        $album->delete();
        my $alb = $album->select_by_id($album->id);
        is($alb, undef, "delete successful");

        return; 
    }, $album;

    
    $album->name("The Menagerie Inside");
    $album->artist_id($artist->id);
    $album->year(1999);
    $album->type("single");
    $album->create_time($dt);
    die "smth went wrong cant insert albumz" unless $album->insert();
    ok(defined $album->id, "insert id ok after delete");
    
    # p $test->SUPER::ok;

}

1;