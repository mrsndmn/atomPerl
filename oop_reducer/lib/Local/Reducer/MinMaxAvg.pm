package Local::Reducer::MinMaxAvg {
use parent Local::Reducer;
use strict;
use warnings;

sub reduce {
    my ($self, $line) = @_;  
    my $field = $self->{field};
    my $row = $self->{row_class}->new(str => $line);
    my $value = $row->get($field, 0);

    if (not defined $self->{reduced}) {
        
        return $self -> {max => $value, 
                         min => $value,
                         avg => $value,
                         count => 1,
                         }
    }

    if  ($self->{reduced}->get_min() > $value ) { $self->set_min($value) }
    elsif ($self->{reduced}->get_max() < $value ) { $self->set_max($value) }
    
    $self->set_avg($value);

    return $self;
}

sub get_min{
    my $self = shift;
    return $self->{min};
}

sub get_max{
    my $self = shift;
    return $self->{max};    
}

sub get_avg{
    my $self = shift;
    return $self->{avg};
}
########

sub set_avg{
    my ($self, $value) = shift;
    my $count = $self->{count};
    my $avg = $self->{avg};
    # тут такая формула будет
    $self->{avg} = ($avg * $count + $value) / ($count+1);
    $self->{count} = $count++

}

sub set_min{
    my ($self, $value) = shift;
    $self->{min} = $value;
}

sub set_max{
    my ($self, $value) = shift;
    $self->{max} = $value;
}

}
1;