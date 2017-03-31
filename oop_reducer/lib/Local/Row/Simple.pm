package Local::Row::Simple;
use parent Local::Row;
#use 5.020;
#use feature 'state';

sub parse {
    my ($self, $line, $name) = @_;
    #say "***".$line;
    
    ###### я понимаю, что пробелов там нет, но я люблю везде их ставить, 
    ###### и если вдруг мне захочется более читабельно записать эту строку, она распарсится
    #$line =~ / (?:${name}) \s* : s* (?<value>[^:\,\s]+) /gx;
    #return $+{'value'};
    
    # но чтобы совсем без регулярок можно так
    # хотя почему-то мне кажется, что вы имели в виду не это

    my %h = split /[:\,]/, $line;
    
    return $h{$name} if exists $h{$name};
    return undef;

}

1;