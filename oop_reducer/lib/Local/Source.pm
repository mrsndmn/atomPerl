package Local::Source;
{use strict;
use warnings;

sub new {
    my ($self, %params) = @_;
    return bless \%params, $self;
}

sub next {
    my $self = shift;

    return $self->getLine();

}

}
1;