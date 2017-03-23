use strict;
use warnings;

use 5.022;
use DDP;

opendir(my $dhTechnosf, '../Technosfera-perl/homeworks/') or die;

my $fileName;
my $dirName;
my $otherFileName;
my %here;
my @toCopy;
#to write already existing dirs

open (my $fhData, "<", "./hwlist.dat") or die;
while($fileName = <$fhData>) {
        #print $filename.", ";
        $here{$fileName} = "$fileName";
}
close($fhData);


#lastDate;

# or not dirName, simple file too
while($dirName = readdir $dhTechnosf) {
    say $dirName;
    if (!exists $here{$dirName} && !-d $dirName) {
        push @toCopy, '../Technosfera-perl/homeworks/'.$dirName;
    }
}

if (scalar(@toCopy)) {
    say "Do you really want to copy here:\n", join ("\n", @toCopy);

    print '>(y|n) ';

    while (my $ans = <STDIN>) {
        say $ans;
    }
} else {
    say "nothing to copy";
}