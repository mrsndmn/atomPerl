use strict;
use warnings;

use 5.020;
use DDP;
use DBI;
use FindBin;
use IO::Uncompress::Unzip;

my $dbFile = "$FindBin::Bin/social.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbFile", "","", { RaiseError => 1 }) or die;

#open my $fh, "<:zip", "$FindBin::Bin/user.zip";
my $z = IO::Uncompress::Unzip->new( "$FindBin::Bin/user.zip" or die "unzip failed((\n") ;  

my $sth = $dbh->prepare('INSERT INTO users (name) VALUES( ? )');
my $c = 0;
while(my $line = $z->getline and $c < 5) {
    $c++;
    chomp $line;
    $sth->execute($line);
} 



