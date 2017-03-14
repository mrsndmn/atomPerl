package Local::Row::JSON {
use parent Local::Row;
use strict;
use warnings;

use JSON::XS;
use feature "say";

sub parse {
    my ($self, $line, $name) = @_;
    my $JSON = JSON::XS->new;
    #say $line;
    my $obj = $JSON->decode( $line );
    #say $$obj{$name};
    return $$obj{$name};    
}

}
1;