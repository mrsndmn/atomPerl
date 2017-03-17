use feature 'say';
use DDP;
$str = '185.168.176.199 [03/Mar/2017:18:32:44 +0300] "GET /music/search/03:22%20%D0%9D%D0%A0%D0%90%D0%9 HTTP" 414 458 "-" "-" "-"';
$str =~ m/^(?<ip>(?:\d{1,3}\.){3} \d{1,3}) \s* 
                            \[ 
                                (?<date>\d\d) \/ (?<month>\w\w\w) \/ (?<year>\d{4}) \: 
                                (?<hour>\d\d) \: (?<minute>\d\d) \: (?<second>\d\d) \s
                                (?<offset>[\-\+].{4})
                            \] \s*
                            
                            \"(?:   (?<method>\w+) \s*
                                    (?<smthElse>.+)
                            )\" \s*
                            
                            
                            (?<status>\d{3}) \s*
                            (?<bytes>\d+) \s*
                            \"(?<refferer>.*?)\" \s*
                            \"(?<userAgent>.*?)\" \s*
                            \"(?<ratio>.*?)\"$
                            /x;
p %+;