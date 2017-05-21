use strict;
use warnings;

use feature 'say';
use DDP;

use EV;
use AnyEvent::HTTP::Server;
my $s = AnyEvent::HTTP::Server->new(
host => '0.0.0.0',
port => 5000,
cb => sub {
    my $request = shift;
    my $status  = 200;
    my $content = "<h1>Reply message</h1>";
    my $headers = { 'content-type' => 'text/html' };
    use DDP;
    p $request;
    $request->reply($status, $content, headers => $headers);
}
);
$s->listen;

$s->accept;

my $sig = AE::signal INT => sub {
warn "Stopping server";
$s->graceful(sub {
    warn "Server stopped";
    EV::unloop;
});
};

EV::loop;