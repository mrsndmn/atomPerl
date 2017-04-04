use strict;
use warnings;

use 5.022;
use DDP;

$dbh = DBI->connect("dbi:SQLite:dbname=social.db", "","");
