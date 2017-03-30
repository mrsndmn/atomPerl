package Local::Row::JSON;
use parent Local::Row;
# use strict;
# use warnings;

use JSON::XS;
use feature "say";

sub parse {
    my ($self, $line, $name) = @_;
    #say $line;
    my $obj = eval {JSON::XS->new()->decode( $line ) };
    return '0' if ($@ || ref $obj ne 'HASH');

    #use DDP;
    #p $obj;
    #say $$obj{$name};
    return $obj->{$name};    
}

1;