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

my $c = 0;
my @fields;

my $table = "users";
my $column = "name";

while(my $line = $z->getline) {
    $c++;
    chomp $line;
    push @fields, $line;

    if ($c == 800) {

        my $sql = sprintf "insert into %s (%s) values %s",
                $table, $column, join",", ("(?)") x @fields;
            say $sql;

        my $sth = $dbh->prepare($sql);

        $sth->execute(@fields);
        @fields = @{[]};
        $c = 0;
    }

}

my $sql = sprintf "insert into %s (%s) values %s",
        $table, $column, join",", ("(?)") x @fields;
    warn $sql;
my $sth = $dbh->prepare($sql);
$sth->execute(@fields);

