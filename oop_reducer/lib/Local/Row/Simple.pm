package Local::Row::Simple {
use parent Local::Row;
#use 5.022;
use strict;
use warnings;

sub parse {
    my ($self, $line, $name) = @_;
    #say "***".$line;
    #say $line =~ /[\W\D]$name:([^:\,]*)/ . "**";
    return $line =~ /[\W\D]$name:([^:\,]*)/;
}

}
1;