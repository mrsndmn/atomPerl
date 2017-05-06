use strict;
use warnings;
use DDP;
use Test::More tests => 13;
use List::Util qw(all);
use lib 'lib';

use Local::MusicLib::Artist;
use Local::MusicLib::Track;
use Local::MusicLib::Album;

my $artist = Local::MusicLib::Artist->new();
my $track = Local::MusicLib::Track->new();
my $album = Local::MusicLib::Album->new();

# вот единственное, что результаты тста в бд загоняются, нафиг это надо
$artist->name("SOAD");
$artist->country("us");
my $dt = DateTime->now;
$artist->create_time($dt);
my $insert_ok = $artist->insert($artist);

ok($insert_ok, "inserted artist");
is($artist->name, "SOAD", "artist's name");
is($artist->country, "us", "artist's country");
is($artist->create_time, $dt, "artist's create_time");
ok(defined $artist->id, "artist's id");

$artist->name("System of a down");
my $update_ok = $artist->update();

ok($update_ok, "updated artist");
is($artist->name, "System of a down", "updated artist's name");

my $result = $artist->select("name", ["System of a down"]);
ok((all {$_->name eq 'System of a down'} @$result), "selected artist");

my $artist_fom_db = $artist->select("id", $artist->id);
is($artist_fom_db->name, 'System of a down', 'selected artist\'s name');
is($artist_fom_db->country, 'us', 'selected artist\'s country');
is($artist_fom_db->create_time, $dt, 'selected artist\'s date time');
# todo check serialized dt
#todo test connection
is_deeply($artist->select_by_id($artist->id), $artist_fom_db ,"select_by_id method works");
is_deeply($artist->select_by_name($artist->name), $artist->select("name", $artist->name), "select_by_name method works");

1;
