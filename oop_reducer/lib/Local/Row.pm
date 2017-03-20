package Local::Row {

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
    (defined $value )? return $value : return $default;
}

}
1;