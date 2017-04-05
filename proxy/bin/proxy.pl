use 5.010;
use strict;
use warnings;

use DDP;
use AnyEvent::HTTP;
use AnyEvent::Socket;
use URI;
use Data::Validate::URI qw(is_web_uri);

our $URL;

my $cv = AnyEvent::condvar;
$cv->begin();
my $g;
$g = tcp_server undef, 8081, 
    sub {
        my ($fh, $thishost, $thisport) = @_;
        warn "new connection";
        my $h = AnyEvent::Handle->new( fh => $fh );

        $h->on_error( sub { $h->destroy; } );
        
        # Start message
        $h->push_write("You are welcome to my proxy\nTry '?' to get help\n");
        
        $h->on_read (   
            sub {
                $h->push_read( line => sub {
                    #p @_;
                    #$my $line = $_[1];
                    
                    # no regexp no overhead
                    my ($op, $other ) = split " ", $_[1], 2;
                    return if !defined $op;
                    # no Switch no problems
                    if ($op eq '?') {
                        $h->push_write(join "", <DATA>);                 
                    } elsif($op eq 'URL') {

                        if (!defined($other)) {
                            $h->push_write("Need argument.\nTry '?' to get help\n");
                            return;
                        } 

                        if ( is_web_uri $other ) {
                            $URL = $other;
                            $h->push_write("OK\n");
                            warn $URL;
                        } else {
                            $h->push_write("Invalid URL: $other\nURL must be absolute and begins with \'hhtp(s)://\'\nTry '?' to get help\n");
                            return;
                        }

                    } elsif($op eq 'HEAD') {
                        if (!defined($URL)) {
                            $h->push_write("You should set URL\nTry '?' to get help\n");
                            return;
                        }
                        
                        $cv->begin;
                        my $ans;
                        http_head ($URL, 
                                sub {
                                    my ($body, $header) = @_;
                                    #p $header;
                                    $ans = join "\n", map { "$_ : ". $header->{$_} } sort keys %$header;
                                    warn "head ",length $ans;

                                    $h->push_write( $ans."\nOK\n" );                        
                                    $cv->end;
                                });

                    } elsif($op eq 'GET') {
                        
                        if (!defined($URL)) {
                            $h->push_write("You should set URL\nTry '?' to get help\n");
                            return;
                        }

                        $cv->begin;
                        http_get ($URL, 
                                sub {
                                    my ($body, $header) = @_;

                                    warn "body; ", length $body;

                                    $h->push_write( $body."\nOK\n" );
                                    $cv->end;
                                });


                    } elsif($op eq 'FIN') {
                        $h->push_write("Goodbye\n");
                        $h->destroy;
                    } else {
                        $h->push_write("Unknown operation: '${op}'\n");
                    }


                })
            }
        );

    };

$cv->recv;

sub head_request {
    my $page = shift;
    my $cb = shift;

    my $ans;
    warn $page;
    my $cv = AnyEvent::condvar;
    $cv->begin;

    http_head ($page, 
            sub {
                my ($body, $header) = @_;
                p $header;
                $ans = join "\n", map { "$_ : ". $header->{$_} } sort keys %$header;
                $cb->();
                $cv->end;
            });

    $cv->recv;
    warn $ans;
    return $ans;
}


sub get_request {


}



__END__
'URL'   remember folowing URL
'HEAD'  head request to URL
'GET'   get request to URL
'FIN'   exit
'?'     this message
