#!/usr/bin/perl

use strict;
use warnings;

#use Date::Calc qw(Delta_DHMS Date_to_Time);
use DDP;
use 5.022;

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

#IP	count	avg	data	data_200	data_301	data_302	data_400	data_403	data_404	data_408	data_414	data_499	data_500
# 68.51.111.236 [03/Mar/2017:18:28:38 +0300] "GET /music/artists/Pink%20Floyd HTTP/1.1" 200 66477 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)" "6.51"
sub parse_file {
    my $file = shift;

    my %total;

    # you can put your code here

    my $result;
    my $ip;
    

    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";

    while (my $log_line = <$fd>) {
        #chomp $log_line; # в общем-то, регулярка все равно эту строчку обработает, но для красоты можно, хотя лишенее действие

        # знаю, что парсинг излишний, но вдруг еще что-нибудь понадобится, а туту все так красиво уже есть
        $log_line =~ m/(?<ip>(?:\d{1,3}\.){3} \d{1,3}) \s* 
                            \[ 
                                (?<date>\d\d) \/ (?<month>\w\w\w) \/ (?<year>\d{4}) \: 
                                (?<hour>\d\d) \: (?<minute>\d\d) \: (?<second>\d\d) \s
                                (?<offset>[\-\+].{4})
                            \] \s*
                            
                            \"(?:   (?<method>\w+) \s*
                                    (?<URI>.+)\s*
                                    (?<protocol>\S+?)
                            )\" \s*
                            
                            (?<status>\d{3}) \s*
                            (?<bytes>\d+) \s*
                            \"(?<refferer>.*?)\" \s*
                            \"(?<userAgent>.*?)\" \s*
                            \"(?<ratio>.*?)\"
                            /x;
        
        

        $ip = $+{'ip'};
        
        $result->{'requests'}->{$ip}->{'count'} += 1;                        
        $result->{'requests'}->{$ip}->{'data'} += $+{'bytes'};        
        $result->{'requests'}->{$ip}->{"data_@{[$+{'status'}]}"} += $+{'bytes'};

        # ой, не нравится мне это
        # кажется, за это наругаете
        if (!exists $result->{'requests'}->{$ip}->{'time'} 
                || $result->{'requests'}->{$ip}->{'time'} != $+{'minute'}) {
            $result->{'requests'}->{$ip}->{'countMinutes'} += 1;
            $result->{'requests'}->{$ip}->{'time'} = $+{'minute'};
        }

        
        #total
        
        $result->{'total'}->{'data'} += $+{'bytes'};
        $result->{'total'}->{"data_@{[$+{'status'}]}"} += $+{'bytes'};

        if(!exists $result->{'total'}->{'time'} || $result->{'total'}->{'time'} != $+{'minute'}) { # counting minutes, with any request
            $result->{'total'}->{'time'} = $+{'minute'};
            $result->{'total'}->{'countMinutes'} += 1;
        }

        if (eof($fd)) {
            $result->{'total'}->{'count'} = $.;
            $result->{'total'}->{'avg'} = sprintf("%.2f", $./$result->{'total'}->{'countMinutes'});
        }
        

    }
    close $fd;
    
    #суммируем для кадого ip data'ы и считаем avg
    
    for (keys %{$result->{'requests'}}) {
            $result->{'requests'}->{$_}->{'avg'} = sprintf("%.2f", $result->{'requests'}->{$_}->{'count'} / $result->{'requests'}->{$_}->{'countMinutes'});
    }

    p $result;    

    return $result;
}

sub report {
    my $result = shift;
    my @dataCode = qw(count avg data data_200 data_301 data_302 data_400 data_403 data_404 data_408 data_414 data_499 data_500);
    # head
    say join "\t", qw(IP), @dataCode;

    # total
    print "total\t";
    say join "\t", @{$result->{'total'}}{@dataCode};

    # еще получить первые 10 я снаачала думал, получится с помощью grep
    # но там не работал $., а свой счетчик было неохота вводить (сделал с помощью среза, но получилось нечитаемо)
    # еще вариант(мне тоже не нравится, но новый массив делать неохота):
    my $req = $result->{'requests'};
    my $ip;

    say join "\n", 
            map {   $ip = $_;
                    join "\t", $ip, map {    exists($req->{$ip}->{$_})?
                                                 $req->{$ip}->{$_} 
                                                                :
                                                                0 
                                    } @dataCode
                } @{[]}[0..9] = sort { $req->{$b}->{'count'} 
                                                         <=> 
                                    $req->{$a}->{'count'} }    keys %{$req};

    # requests



    # you can put your code here

}
