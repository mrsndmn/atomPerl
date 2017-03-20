package Local::Source::Text;
{use parent Local::Source;
use strict;
use warnings;
#use Tie::File;

sub getLine {
    my $self = shift;
    my @fileLines;

    #tie (@fileLines, 'Tie::File', $self->{fh} ) or die "cnt";
    
    return shift @fileLines;
}


}
1;