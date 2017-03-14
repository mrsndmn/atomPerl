package Local::Source::Array;
{use parent Local::Source;
use strict;
use warnings;

sub getLine {
    my $self = shift;

    return my $elem = shift @{$self->{array}};   
}

}
1;