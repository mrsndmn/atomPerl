package Local::Row::Simple;
use parent Local::Row;
use 5.020;
use feature 'state';

sub parse {
    my ($self, $line, $name) = @_;
    #say "***".$line;
    
    $line =~ /${name} \s* : s* (?<value>[^:\,\s]+) /x;
    return $+{'value'};
    
}

1;