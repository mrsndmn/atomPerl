use feature 'say';
my $line = '68.51.111.236 [03/Mar/2017:18:28:38 +0300] "GET /music/artists/Pink%20Floyd HTTP/1.1" 200 66477 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)" "6.51"';

say join "\n", $line =~ m/(?<ip>(?:\d{1,3}\.){3} \d{1,3}) \s* 
                        \[ 
                             (?<date>\d\d) \/ (?<month>\w\w\w) \/ (?<year>\d{4}) \: 
                             (?<hour>\d\d) \: (?<minute>\d\d) \: (?<second>\d\d) \s
                             (?<offset>[\-\+].{4})
                        \] \s*
                        
                        \"(?:   (?<method>\w*) \s*
                                (?<URI>\S*?)\s*
                                (?<proto>\S*?)
                                    )\" \s*
                        (?<status>\d{3}) \s*
                        (?<bytes>\d*) \s*
                        \"(?<refferer>.*?)\" \s*
                        \"(?<userAgent>.*?)\" \s*
                        \"(?<ratio>.+?)\"
                        /x;