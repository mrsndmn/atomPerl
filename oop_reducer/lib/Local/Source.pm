package Local::Source;

sub new {
    my ($self, %params) = @_;
    return bless \%params, $self;
}

1;