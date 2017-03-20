package Local::Row::Simple {
use parent Local::Row;
use 5.022;
use strict;
use warnings;

sub parse {
    my ($self, $line, $name) = @_;
    #say "***".$line;
    #say $line =~ /[\W\D]$name:([^:\,]*)/ . "**";
    $line =~ /(?: ^ | [\,])$name:([^:\,]*)/x;
    my $value = $1;
    return $value;
}

}
1;