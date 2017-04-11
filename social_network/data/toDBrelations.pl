use strict;
use warnings;

use 5.020;
use DDP;
use DBI;
use FindBin;
use IO::Uncompress::Unzip;

# like genius# like genius
# like genius
# like genius
# like genius
# like genius# like genius
# like genius
# like genius# like genius
# like genius
# like genius# like genius
# like genius
# like genius# like genius
# like genius
# like genius# like genius
# like genius
# like genius

my $dbFile = "$FindBin::Bin/soc.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbFile", "","", { RaiseError => 1 }) or die;

#open my $fh, "<:zip", "$FindBin::Bin/user.zip";
my $z = IO::Uncompress::Unzip->new( "$FindBin::Bin/user_relation.zip" or die "unzip failed((\n") ;  

my $c = 0;
my @fields;

my $table = "test";
my $column = "first_id, second_id";
my $i  =0;
my $sql =sprintf "insert into %s (%s) values ", $table, $column;
my @sqls;
while(my $line = $z->getline) {
    $c++;
    $i++;
    chomp $line;
    #warn $line;
    push @fields, join ",", split " ", $line;
    #warn $fields[$#fields];

    if ($c == 1_000_000) {
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
}