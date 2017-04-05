package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;

use IO::Socket;

socket my $s, AF_INET, SOCK_STREAM, IPPROTO_TCP;
bind $s, sockaddr_in(1234, INADDR_ANY);
listen $s, SOMAXCONN;
my ($port, $addr) = sockaddr_in(getsockname($s));
say "Listening on ".inet_ntoa($addr).":".$port;
while (my $peer = accept my $c, $s) {
# got client socket $c
# $peer = getpeername($c);
my ($port, $addr) = sockaddr_in($peer);
my $ip = inet_ntoa($addr);
my $host = gethostbyaddr($addr, AF_INET);
say "Client connected from $ip:$port ($host)";
}
