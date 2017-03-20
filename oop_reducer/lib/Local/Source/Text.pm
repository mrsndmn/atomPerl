package Local::Source::Text;
{use parent Local::Source;
use strict;
use warnings;

sub getLine {
    my $self = shift;
    my $line;

    if ( $self->{'text'} !~ /\w|\d/x) {
        die "There is no more lines";
    }

    ($line, $self->{'text'}) = split m/\n/s, $self->{'text'}, 2;
    return $line;
}


}
1;