package Local::Source::Text;
use parent Local::Source;


sub next {
    my $self = shift;
    my $line;

    if ( !defined $self->{'text'}) {
        #print "\'@{[$self->{'text'}]}\'\n";
        return undef;
    }

    ($line, $self->{'text'}) = split m/\n/s, $self->{'text'}, 2;
    return $line;
}

1;