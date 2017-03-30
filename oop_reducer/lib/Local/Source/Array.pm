package Local::Source::Array;

use parent Local::Source;
# use strict;
# use warnings;

sub next {
    my $self = shift;
    return shift @{$self->{array}};   
}


1;