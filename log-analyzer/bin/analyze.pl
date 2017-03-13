#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Delta_DHMS Date_to_Time);
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
    my $time;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {
    #chomp $log_line;
    
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
    
    #privetik)))) =*** lublu tebya)))  \andrushke i sane vseh blag, schastya,zdorovya\

    $ip = $+{'ip'};

    push @{$result->{$ip}}, {%+};

    # save here 1 request time
    $result->{'total'}->{'avg'} = [$+{year}, $+{month}, $+{date}, $+{hour}, $+{minute}, $+{second}] if ($. == 1);
    
    #total
    
    $result->{'total'}->{'data'} += $+{'bytes'};
    $result->{'total'}->{"data_@{[$+{'status'}]}"} += $+{'bytes'};

    if (eof($fd)) {
        $result->{'total'}->{'count'} = $.;
        $time = Date_to_Time(Delta_DHMS(@{$result->{'total'}->{'avg'}}, # first request time
                                        $+{year}, $+{month}, $+{date}, $+{hour}, $+{minute}, $+{second} # second request time
                                      ));
        $result->{'total'}->{'avg'} = $./$time;
    }

    }
    close $fd;
    
    p $result->{'total'};
    #p $result;
    # for (keys %$result) {
    #     if ($_ ne 'total' && scalar @{($result->{$_})} > 1){
    #         #p $result->{$_};
    #     }
    # }

    # you can put your code here, a mogu i ne put   /ahahah/ 


    return $result;
}

sub report {
    my $result = shift;
    my @dataCode = qw(data data_200 data_301 data_302 data_400 data_403 data_404 data_408 data_414 data_499 data_500);
    # head
    say join "\t", qw(IP count avg), @dataCode;

    # total
    print "total\n";


    # requests



    # you can put your code here

}
