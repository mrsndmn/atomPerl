use strict;
use warnings;
use DDP;
use Mouse;
use Test::More tests => 3;

use lib 'lib';

BEGIN { use_ok("Local::MusicLib::Artist"); }
BEGIN { use_ok("Local::MusicLib::Track"); }
BEGIN { use_ok("Local::MusicLib::Album"); }


1;