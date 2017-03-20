package Local::Row;

use strict;
use warnings;

sub new {
    my ($self, %params) = @_;
    return bless \%params, $self;
}

sub get {
    my ($self, $name, $default) = @_;
    my $line = $self->{'str'};
    my $value = $self->parse($line, $name);
    
    return $value if defined $value && $value =~ /\d+\.?\d*/ ;
    return $default;
}

1;