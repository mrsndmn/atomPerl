#!/usr/bin/perl

use strict;
use warnings;

#use Date::Calc qw(Delta_DHMS Date_to_Time);
use DDP;
use 5.022;
use POSIX qw(floor round ceil);

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my @dataCode = qw(data 200 301 302 400 403 404 408 414 499 500);

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;


#IP	count	avg	data	data_200	data_301	data_302	data_400	data_403	data_404	data_408	data_414	data_499	data_500
# 68.51.111.236 [03/Mar/2017:18:28:38 +0300] "GET /music/artists/Pink%20Floyd HTTP/1.1" 200 66477 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)" "6.51"
sub parse_file {
    my $file = shift;

    # you can put your code here

    my $result;
    my ($ip, $ratio, $time);
    
    $result->{'requests'} = {};
    $result->{'total'} = {};    

    my $req = $result->{'requests'};
    my $total = $result->{'total'};
    
    my %again;

    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";

    while (my $log_line = <$fd>) {
        
        # dublicated nodes
        if (!exists $again{$log_line}){
            $again{$log_line} = 1;
        }   else {
            next;
        }

        $log_line =~ m/     ^
                            (?<ip>(?:\d{1,3}\.){3} \d{1,3}) \s
                            \[ 
                                (?<date>\d\d) \/ (?<month>\w\w\w) \/ (?<year>\d{4}) \: 
                                (?<hour>\d\d) \: (?<minute>\d\d) \: (?<second>\d\d) \s
                                (?<offset>[\-\+].{4})
                            \] \s
                            
                            \"(?:   (?<method>\w+) \s
                                    (?<URI>.+)\s?
                                    (?<protocol>HTTP.*)?
                            )\" \s
                            
                            (?<status>\d{3}) \s
                            (?<bytes>\d+) \s
                            \"(?<refferer>.+)\" \s
                            \"(?<userAgent>.+)\" \s
                            \"(?<ratio>.+?)\"
                            $
                            /x;

        if ($+{'ratio'} eq '-') { 
            $ratio = 1 
        } else {
             $ratio = $+{'ratio'}
        }
        
        $ip = $+{'ip'};
        $time = $+{'hour'}.$+{'minute'};
        
        
        $result->{'requests'}->{$ip}->{'count'} += 1;
        
        $req = $result->{'requests'}->{$ip};


        foreach ($req, $total) {
            $_->{'data'} += floor($+{'bytes'} * $ratio) if ($+{'status'} == 200);
            $_->{$+{'status'}} += $+{'bytes'};
            
            if ( !(exists $_->{'time'}) || !(exists $_->{'time'}->{$time})) {
                
                $_->{'time'}->{$time} = $time;
                $_->{'time'}->{'countMinutes'} += 1;
                
            }
        }


        if (eof($fd)) {
            $total->{'count'} = $.;
            $total->{'avg'} = sprintf("%.2f", $./$total->{'time'}->{'countMinutes'});
        }
        

    }
    close $fd;
    return $result;
}

sub report {
    my $result = shift;
    my $total = $result->{'total'};
    my $req = $result->{'requests'};
    my $ip;

     for (keys %{$req}) {
            $req->{$_}->{'avg'} = sprintf("%.2f", $req->{$_}->{'count'} / $req->{$_}->{'time'}->{'countMinutes'});
    }
    
    # head
    say join "\t", qw(IP count avg), @dataCode;

    # total
    print "total\t";
    say join "\t", @{$total}{qw(count avg)}, map {floor($_ / 1024)} @{$total}{@dataCode};


    #requests
    say join "\n", 
            map {   $ip = $_;
                    join "\t", $ip, 
                                (map { $req->{$ip}->{$_} }  qw(count avg)),
                                (map {    (exists($req->{$ip}->{$_})) ?
                                                                        floor($req->{$ip}->{$_} / 1024)
                                                                      :
                                                                        0 
                                    } @dataCode
                                )
                } @{[]}[0..9] = sort { $req->{$b}->{'count'} 
                                                         <=> 
                                    $req->{$a}->{'count'} }    keys %{$req};

}
