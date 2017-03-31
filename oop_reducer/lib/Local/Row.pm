package Local::Row;

use strict;
use warnings;
#use feature 'say';
use Scalar::Util qw(looks_like_number);

sub new {
    my ($self, %params) = @_;
    return bless \%params, $self;
}

sub get {
    my ($self, $name, $default) = @_;
    my $line = $self->{'str'};
    my $value = $self->parse($line, $name);
    #say $value;
    return $value if defined $value and looks_like_number $value;
    return $default;
}

1;