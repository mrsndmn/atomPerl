use strict;
use warnings;
use 5.020;
use DDP;
$, = ", ";
use Encode qw(encode decode);
use utf8;
say "�Yh0P";
say encode('utf8',"�Yh0P");


=Gsf

http_request
      HEAD    => "https://www.google.com",
      timeout => 30,
      sub {
         my ($body, $hdr) = @_;
         use Data::Dumper;
         print Dumper $hdr;
      }
   ;

my $i = 3;
main($i);
sub main {
    my $int = shift;
    die if $int ==0;
    my @arr;
    push @arr, $int;
    }
    say @arr;
    foreach my $i (0..$#arr) {
        foreach my $i (0..$#arr) {
            my $num = $arr[$i];
            next if ($num == 1);
            my $less = $num - 1;

            foreach my 

        }
    }

} 
use AnyEvent::Socket;
 my $g;
 $g =  tcp_server undef, 8080, sub {
      my ($fh, $host, $port) = @_;

      syswrite $fh, "The internet is full, $host:$port. Go away!\015\012";
   }, sub {
      my ($fh, $thishost, $thisport) = @_;
      AE::log info => "Bound to $thishost, port $thisport.";
   };
AE::cv->recv;

say 2;
cede; #
say 4;
};
say 1;
cede;
say 3;
cede;
=HEAD
my $even = generator {
my $x = 0;

while(1) {
    $x += 2;
    yield $x;
    }
};
# This will print even numbers from 2..20
for(1..10) {
    say $even->();
}

__END__

    our $ok = 1;
    a();
    sub a {    
        ma(); 
    }
    sub ma {
        say $ok;
    }



my $uri = URI->new('http://www.ya.ru#adfd');
p $uri;
$uri->canonical->fragment(undef);
say $ur
my %params = (text => "qweqw\ndfdfs\nweq");

$params{'text'} = [split /\n/, $params{'text'}];
 p %params;


use AE;

sub async {
    my $cb = pop;
    my $w;$w = AE::timer rand(0.1),0,sub {
        #say "in async";
        undef $w;
        $cb->();
    };
    return;
}

my $cv = AE::cv;
$cv->begin;
my @array = 1..10;
for my $cur (@array) {
    say "Process $cur";
    $cv->begin;
    async sub {
        say "Processed $cur";
        $cv->end;
    };
}
$cv->end;
$cv->recv;

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
