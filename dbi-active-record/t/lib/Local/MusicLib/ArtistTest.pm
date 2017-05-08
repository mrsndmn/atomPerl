package Local::MusicLib::ArtistTest;

use Test::Class::Moose extends => 'Local::Test';

use DDP;

use Local::MusicLib::Artist;

sub test_artist {
    my ($dbh, $artist, $album, $track) = @_;
    
    # вот единственное, что результаты тста в бд загоняются, нафиг это надо
    # но в модулеуже используются транзакции, а внутри транзакции нельзя запустить ещзе одну
    # так что можно считать, что даже если тесты сломаются и артист не удалится, наша база не взорвется от одного лишнего,
    # никому не нужного артиста
    # $dbh->{AutoCommit} = 0;
    # $dbh->begin_work();

    $artist->name("SOAD");
    $artist->country("us");
    my $dt = DateTime->now;
    $artist->create_time($dt);
    my $insert_ok = $artist->insert();

    ok($insert_ok, "inserted artist");
    is($artist->name, "SOAD", "artist's name");
    is($artist->country, "us", "artist's country");
    is($artist->create_time, $dt, "artist's create_time");
    ok(defined $artist->id, "artist's id");

    my $id = $artist->id;

    my $serialize_dt = $dbh->selectrow_arrayref("SELECT create_time FROM artist WHERE id = $id")->[0];
    is($serialize_dt, $dt->epoch, "artist's create_time serialized");

    $artist->name("System of a down");
    my $update_ok = $artist->update();

    ok($update_ok, "updated artist");
    is($artist->name, "System of a down", "updated artist's name");

    my $result = $artist->select("name", ["System of a down"]);
    ok((List::Util::all {$_->name eq 'System of a down'} @$result), "selected artist");

    my $artist_fom_db = $artist->select("id", $id);
    is($artist_fom_db->name, 'System of a down', 'selected artist\'s name');
    is($artist_fom_db->country, 'us', 'selected artist\'s country');
    is($artist_fom_db->create_time, $dt, 'selected artist\'s date time');

    is_deeply($artist->select_by_id($id), $artist_fom_db ,"select_by_id method works");
    is_deeply($artist->select_by_name($artist->name), $artist->select("name", $artist->name), "select_by_name method works");

    $artist->delete();
    is_deeply($artist->select_by_id($id), undef,"deleted artist");
    # $dbh->rollback();
    # $dbh->disconnect();

    $insert_ok = $artist->insert();
    ok($insert_ok, "inssert after delete");
}
1;
