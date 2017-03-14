use feature 'say';
# my $line = '78.161.32.13 [03/Mar/2017:19:01:14 +0300] "GET /music/search/Larger Than life HTTP/1.1" 301 688 "-" "ELinks/0.11.4-3 (textmode; Debian; Linux 2.6.26-1-sparc64 sparc64; 160x64-2)" "-"';
# say $line;
# say join "\n", $line =~ m/(?<ip>(?:\d{1,3}\.){3} \d{1,3}) \s* 
#                         \[ 
#                              (?<date>\d\d) \/ (?<month>\w\w\w) \/ (?<year>\d{4}) \: 
#                              (?<hour>\d\d) \: (?<minute>\d\d) \: (?<second>\d\d) \s
#                              (?<offset>[\-\+].{4})
#                         \] \s*
                        
#                         \"(?:   (?<method>\w+) \s*
#                                 (?<URI>.+)\s*
#                                 (?<proto>\S+?)
#                         )\" \s*
                        
#                         (?<status>\d{3}) \s*
#                         (?<bytes>\d+) \s*
#                         \"(?<refferer>.*?)\" \s*
#                         \"(?<userAgent>.*?)\" \s*
#                         \"(?<ratio>.*?)\"
#                         /x;
use Date::Calc qw(Parse_Date);
say Parse_Date('03/Mar/2017:19:01:14');
