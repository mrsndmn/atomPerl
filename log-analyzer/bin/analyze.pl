#!/usr/bin/perl

use strict;
use warnings;

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
    #chomp $log_line;
    
    say $log_line if (not $log_line =~ m/(?<ip>(?:\d{1,3}\.){3} \d{1,3}) \s* 
                        \[ 
                             (?<date>\d\d) \/ (?<month>\w\w\w) \/ (?<year>\d{4}) \: 
                             (?<hour>\d\d) \: (?<minute>\d\d) \: (?<second>\d\d) \s
                             (?<offset>[\-\+].{4})
                        \] \s*
                        
                        \"(?:   (?<method>\w+) \s*
                                (?<URI>.+)\s*
                                (?<proto>\S+?)
                        )\" \s*
                        
                        (?<status>\d{3}) \s*
                        (?<bytes>\d+) \s*
                        \"(?<refferer>.*?)\" \s*
                        \"(?<userAgent>.*?)\" \s*
                        \"(?<ratio>.*?)\"
                        /x);
    
    #privetik)))) =*** lublu tebya)))  \andrushke i sane vseh blag, schastya,zdorovya\

    $ip = $+{'ip'};
    #say $ip;

    $result->{$ip} = [];
    push @{$result->{$ip}}, \{%+};

    #total
    $result->{'total'}->{'count'} += 1;
    $result->{'total'}->{"data_@{[$+{'status'}]}"} += $+{'bytes'};

    }
    close $fd;
    
    p $result->{'total'};
    for (keys %$result) {
        if ($_ ne 'total' && scalar @{($result->{$_})} > 1){
            p $result->{$_};
        }
    }

    # you can put your code here, a mogu i ne put   /ahahah/ 


    return $result;
}

sub report {
    my $result = shift;

    # you can put your code here

}
