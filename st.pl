use strict;
use warnings;

use 5.020;
use DDP;
$| ="1";
use Encode qw(decode);

#  494bf971d20f6db1822754b89cc26cbb2d19cee3
my $sha1 = join '', map {chr($_)} unpack "C20", 'IK\371q\322\17m\261\202\'T\270\234\302l\273-\31\316\343F\0+\320\277\321\200\320\265\320\264\320\273\320\276\320\266\320\265\320\275\320\270\320\265 \320\276 \321\200\320\260\320\261\320\276\321\202\320\265.docx\1\264\0\2\22345G+\3176\223\276\351\363\322?\17\7tO+\344t\33,UD\0\10\320\244\320\276\321\202\320\276\1\375IF\0\fDSC_0003.JPG\1\264\0\n\23|\343\257D\f\376\207c)TDQ\303K,\252\242d\2tpF\0\fDSC_0004.JPG\1\264\0\10\272\331X\356\f\300\24';
say decode("utf8", $sha1);



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
