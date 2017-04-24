use strict;
use warnings;

use 5.020;
use DDP;
use DBI;
use FindBin;
use IO::Uncompress::Unzip;

my $dbFile = "$FindBin::Bin/soc.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbFile", "","", { RaiseError => 1 }) or die;

my $z = IO::Uncompress::Unzip->new( "$FindBin::Bin/user_relation.zip" or die "unzip failed((\n") ;  

my $c = 0;
my @fields;

my $table = "relations";
my $column = "first_id, second_id";
my $i  =0;
my $sql =sprintf "insert into %s (%s) values ", $table, $column;
my @sqls;
while(my $line = $z->getline) {
    $c++;
    $i++;
    chomp $line;

    push @fields, join ",", split " ", $line;

    if ($c == 1e6) {
        my $s = $sql.(join ", ", map {"(".$_.")"} @fields);
        $dbh->quote($s);
        $dbh->do($s);

        @fields = @{[]};
        $c = 0;
        warn $i;
    }

}
if (scalar(@fields)){
        my $s = $sql.(join ", ", map {"(".$_.")"} @fields);
        $dbh->quote($s);
        $dbh->do($s);
        warn "last relations in base";        
}