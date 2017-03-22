
use strict;
use warnings;

use 5.022;
use DDP;
use IO::Socket;

#$|++;
my $socket = IO::Socket::INET->new(
    PeerAddr => 'localhost',
    PeerPort => 8081,
    Proto => "tcp",
    Type => SOCK_STREAM)  or die "Can't connect to search.cpan.org $/";

$socket->autoflush(1);
print $socket "hi\n";
warn "print";
while (<$socket>) {
    print $_;
}

close($socket);