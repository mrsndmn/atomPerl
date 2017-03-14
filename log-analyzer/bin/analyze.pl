#!/usr/bin/perl

use strict;
use warnings;

#use Date::Calc qw(Delta_DHMS Date_to_Time);
use DDP;
use 5.022;
use POSIX qw(round);

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my @dataCode = qw(data data_200 data_301 data_302 data_400 data_403 data_404 data_408 data_414 data_499 data_500);

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
    my ($ip, $ratio);
    $result->{'requests'} = {};
    my $req = $result->{'requests'};
    $result->{'total'}->{'time'} = -1;    

    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";

    while (my $log_line = <$fd>) {

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
        
        if ($+{'ratio'} eq '-') { 
            $ratio = 1 
        } else {
             $ratio = $+{'ratio'}
        }
        #say $ratio, ($+{'ratio'} eq '-');
        $ip = $+{'ip'};
        
        $req->{$ip}->{'count'} += 1;                        
        $req->{$ip}->{'data'} += $+{'bytes'} * $ratio;        
        $req->{$ip}->{"data_@{[$+{'status'}]}"} += $+{'bytes'} * $ratio;

        # ой, не нравится мне это
        # кажется, за это наругаете
        # но вроде я правильно понял условие
        if (!exists $req->{$ip}->{'time'} 
                || $req->{$ip}->{'time'} != $+{'minute'}) {
            $req->{$ip}->{'countMinutes'} += 1;
            $req->{$ip}->{'time'} = $+{'minute'};
        }
      
        #total
        
        $result->{'total'}->{'data'} += $+{'bytes'} * $ratio;
        $result->{'total'}->{"data_@{[$+{'status'}]}"} += $+{'bytes'} * $ratio;

        if($result->{'total'}->{'time'} != $+{'minute'}) { # counting minutes, with any request
            $result->{'total'}->{'countMinutes'} += 1;
            $result->{'total'}->{'time'} = $+{'minute'};
        }

        if (eof($fd)) {
            $result->{'total'}->{'count'} = $.;
            # опять буду грешить на тест, т к не вижу здесь ошибки
            # в тесте могло получиться больше, если там рассчет был такой: общее среднее = сумме средних за каждую минуту
            # но это маловероятно, на самом деле. не знаю, что у меня не так тут((
            $result->{'total'}->{'avg'} = sprintf("%.2f", $./$result->{'total'}->{'countMinutes'});
        }
        

    }
    close $fd;
    
    for (keys %{$req}) {
            $req->{$_}->{'avg'} = sprintf("%.2f", $req->{$_}->{'count'} / $req->{$_}->{'countMinutes'});
    }

    #p $result;    

    return $result;
}

sub report {
    my $result = shift;
    # head
    say join "\t", qw(IP count avg), @dataCode;

    # total
    print "total\t";
    say join "\t", @{$result->{'total'}}{qw(count avg)}, map {round($_ / 1024)} @{$result->{'total'}}{@dataCode};

    # еще получить первые 10 я снаачала думал, получится с помощью grep
    # но там не работал $., а свой счетчик было неохота вводить (сделал с помощью среза, но получилось нечитаемо)
    # еще вариант(мне тоже не нравится, но новый массив делать неохота):
    my $req = $result->{'requests'};
    my $ip;

    say join "\n", 
            map {   $ip = $_;
                    join "\t", $ip, (map { $req->{$ip}->{$_} }  qw(count avg)),
                                     (map {    (exists($req->{$ip}->{$_})) ?
                                                round($req->{$ip}->{$_} / 1024)
                                                                            :
                                                                0 
                                    } @dataCode)
                } @{[]}[0..9] = sort { $req->{$b}->{'count'} 
                                                         <=> 
                                    $req->{$a}->{'count'} }    keys %{$req};

    # requests



    # you can put your code here

}
