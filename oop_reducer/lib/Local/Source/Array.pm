package Local::Source::Array;
use parent Local::Source;
use feature 'state';

# use strict;
# use warnings;

sub next {
    my $self = shift;
    state $i = 0;
    #say $i;
    return $self->{'array'}->[$i++];
}


1;