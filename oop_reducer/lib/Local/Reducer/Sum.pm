package Local::Reducer::Sum;
use parent Local::Reducer;
use feature "say";
# use strict;
# use warnings;

sub reduce {
    my ($self, $line) = @_;
    
    my $field = $self->{'field'};
    my $row = $self->{'row_class'}->new(str => $line);
    return $self->{'reduced'} + $row->get($field, 0);

}

1;