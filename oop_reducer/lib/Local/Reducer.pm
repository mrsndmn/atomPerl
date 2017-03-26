package Local::Reducer;
    #use 5.022;
    use strict;
    use warnings;


=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut


sub new {
    my ($class, %params) = @_;
    $params{'reduced'} = ( exists $params{'initial_value'} ? $params{'initial_value'} : 0 ) ; # to avoid warnings
    return bless \%params, $class;
 }
 


sub reduce_n {
    my ($self, $n) =  @_;

    my $line;

    for (1..$n) {
        # get next line

        $line =  $self->{'source'}->next();  
        # ф-я reduce будет определена в классах-наследниках, 
        # в зависимости от их миссии по-разному будет обрабатывать $line          
        $self->{'reduced'} = $self->reduce($line);
    }   
    return $self->{'reduced'};
}

sub reduce_all() {
    my $self = shift;

    my $line;

    while ( defined ($line =  $self->{'source'}->next()) ) {
        $self->{'reduced'} = $self->reduce($line);
    }   
    return $self->{'reduced'};
}

sub reduced {
    my $self = shift;
    $self->{'reduced'};
}



1;