package Local::Source::Array;

use parent Local::Source;
<<<<<<< HEAD
use strict;
use warnings;
use feature 'state';
#use feature 'say';
=======
# use strict;
# use warnings;
>>>>>>> bcfc469a7a3e082e60520e412f106e317abf5090

sub next {
    my $self = shift;
    state $i = 0;
    #say $i;
    return $self->{'array'}->[$i++];
}


1;