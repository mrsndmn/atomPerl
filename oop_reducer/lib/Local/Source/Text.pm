package Local::Source::Text;
use parent Local::Source;
use feature 'state';
sub new {
    my ($self, %params) = @_;
    die "need text in constructor" if ! exists $params{'text'};
    $params{'text'} = [ split /\n/, $params{'text'} ];
    return bless \%params, $self;
}

sub next {
    my $self = shift;

    state $i = 0;

    if ($i >= scalar(@{$self->{'text'}}) ) {
        return undef;
    }

    return $self->{'text'}->[$i++];
}

1;