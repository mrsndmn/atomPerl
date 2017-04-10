use strict;
use warnings;

use 5.020;
use DDP;
use DBI;
use FindBin;
use IO::Uncompress::Unzip;

my $dbFile = "$FindBin::Bin/soc.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbFile", "","", { RaiseError => 1 }) or die;

#open my $fh, "<:zip", "$FindBin::Bin/user.zip";
my $z = IO::Uncompress::Unzip->new( "$FindBin::Bin/user.zip" or die "unzip failed((\n") ;  

my $c = 0;
my @fields;
# like genius
# like genius
# like genius
# like genius
# like genius
# like genius

my $table = "users";
my $columns = "name, surname";
my $id = 0;
my $sql = sprintf "insert into %s (%s) values ", $table, $columns;

while(my $line = $z->getline) {
    $c++;
    chomp $line;
    push @fields, join ",",  map {"\"".$_."\""} @{[split " ", $line]}[1,2];
    $id++;
    if ($c == 1_000_000) {
        my $s = $sql.(join ", ", map {"(".$_.")"} @fields);
        $dbh->quote($s);
        $dbh->do($s);

        @fields = @{[]};
        $c = 0;
    }

}
warn $id;
warn "finisj";
$sql = sprintf "insert into %s (%s) values ",
                $table, $columns;
warn $sql;

if (scalar(@fields)){    
        my $s = $sql.(join ", ", map {"(".$_.")"} @fields);
        $dbh->quote($s);
        $dbh->do($sql.(join ", ", map {"(".$_.")"} @fields));    
}
