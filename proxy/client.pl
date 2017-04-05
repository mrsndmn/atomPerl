
#or even telnet


# ooh no telnet forever

=X
use strict;
use warnings;

use 5.022;
use DDP;
use IO::Socket::INET;

#$|++;
my $socket = IO::Socket::INET->new(
    PeerAddr => 'localhost',
    Proto => "tcp",
    PeerPort => 8081,
    Type => SOCK_STREAM,
    ReuseAddr => 1,)  or die "Can't connect to search.cpan.org $/";

$socket->autoflush(1);
while (<>){
    warn "printing";
    print $socket $_;

    my $ans = <$socket>;
    print $ans."\n";

}
close($socket);
