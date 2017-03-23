use strict;
use warnings;

use 5.022;
use DDP;
$| ="1";


=cut
=======
use 5.022;
use strict;
use IO::Socket;
my $server = IO::Socket::INET->new(
    LocalPort => 8081,
    Type => SOCK_STREAM,
    ReuseAddr => 1,
    Listen => 10)
                    or die "Can't create server on port 8081 : $@ $/";
#$|++;
    $server->autoflush(1);

while(my $client = $server->accept()){
    $client->autoflush(1);
    say "COnnected"; 
    my $message = <$client>; 
    chomp( $message );
    print $client "Echo: ".$message;
    close( $client );
    last if $message eq 'END';
}
close( $server );








__END__
use strict;
use IO::Socket;
my $socket = IO::Socket::INET->new(
    PeerAddr => 'search.cpan.org',
    PeerPort => 80,
    Proto => "tcp",
    Type => SOCK_STREAM)
                            or die "Can't connect to search.cpan.org $/";
print $socket "GET / HTTP/1.0\nHost: search.cpan.org\n\n";
while (<$socket>) {
    print $_;
}

close



__END__
use strict;
use POSIX qw(:sys_wait_h);
$|=1;
my ($r, $w);
pipe($r, $w);
$r->autoflush(1);
$w->autoflush(1);

if(my $pid = fork()){
    close($r);
    for (1..5) {
        print $w $_ ;
        warn "write ".$_;        
    }
    sleep (1);
    close($w);
    waitpid($pid, 0);
}
else {
    die "Cannot fork $!" unless defined $pid;
    close($w);
    while(<$r>){
        warn "read ".$_;
        print $_."\n";
    }
    close($r);
    exit;
}
>>>>>>> 1852427341ccd80796b6e3f847ef8c88b60bcaf6
