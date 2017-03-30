package Local::Row;

use strict;
use warnings;
use feature 'say';

sub new {
    my ($self, %params) = @_;
    return bless \%params, $self;
}

sub get {
    my ($self, $name, $default) = @_;
    my $line = $self->{'str'};
    my $value = $self->parse($line, $name);
    #say $value;
    return $value if defined $value and $value =~ /^\d+\.?\d*$/ ;
    return $default;
}

1;