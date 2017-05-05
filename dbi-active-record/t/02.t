use strict;
use warnings;
use DDP;
use Test::More tests => 5;

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

is($artist->name, "SOAD", "artist's name");
is($artist->country, "us", "artist's country");
is($artist->create_time, $dt, "artist's create_time");
ok(defined $artist->id, "artist's id");
ok($insert_ok, "artist inserted");


