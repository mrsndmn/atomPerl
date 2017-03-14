package Local::Reducer::MaxDiff;
{use parent Local::Reducer;
#use 5.022;
use strict;
use warnings;

sub reduce {
    my ($self, $line) = @_;
    #say $self;
    
    my $top = $self->{top};
    my $bottom = $self->{bottom};
    #say $top, "+", $bottom;
    #say $self->{row_class};
    my $row = $self->{row_class}->new(str => $line);

    #say $row->get($top,0), "+", $row->get($bottom,0);
    my $diff = $row->get($top,0) - $row->get($bottom,0);

    ($diff > $self->{reduced})? return $diff : return $self->{reduced};
}

}
1;