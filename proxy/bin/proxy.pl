use 5.010;
use strict;
use warnings;

use DDP;
use AnyEvent::HTTP;
use AnyEvent::Socket;
use Data::Validate::URI qw(is_web_uri);

my $help =<<__TEXT__
'URL'   remember folowing URL
'HEAD'  head request to URL
'GET'   get request to URL
'FIN'   exit
'?'     this message
__TEXT__
;

$AnyEvent::HTTP::USERAGENT = "my incognito proxy";      # )

my $cv = AnyEvent::condvar;

my %comparator;

$cv->begin();
my $g;
$g = tcp_server undef, 8081, 
    sub {
        # p @_;
        my ($fh, $thishost, $thisport) = @_;
        warn "new connection";
        my $h = AnyEvent::Handle->new( fh => $fh );

        $h->on_error( sub { $h->destroy; } );
        
        # Start message
        $h->push_write("You are welcome to my proxy\nTry '?' to get help\n");
        
        $h->on_read (   
            sub {
                $h->push_read( line => sub {
                    
                    my $URL = $comparator{$thishost.$thisport};
                    # no regexp no overhead
                    my ($op, $other ) = split " ", $_[1], 2;
                    return if !defined $op;
                    chomp $op;
                    # no Switch no problems :: we have given when
                    
                    given ($op) {
                        when('?') {
                            $h->push_write($help);
                        }
                        when ('URL') {

                            if (!defined($other)) {
                                $h->push_write("Need argument.\nTry '?' to get help\n");
                            }
                            if ( is_web_uri $other ) {
                                $comparator{$thishost.$thisport} = $other;
                                $URL = $comparator{$thishost.$thisport};
                                $h->push_write("OK\n");
                                warn $URL;
                            } else {
                                $h->push_write("Invalid URL: $other\nURL must be absolute and begins with \'hhtp(s)://\'\nTry '?' to get help\n");
                                return;
                            }
                        }
                        when ('HEAD') {
                            warn $URL, $thisport;
                            # p %comparator;
                            if (!defined($URL)) {
                                $h->push_write("You should set URL\nTry '?' to get help\n");
                                return;
                            }
                            
                            head_request ($URL, sub {
                                                    my ($ans, $length) = @_;

                                                    if ($length) {
                                                        $h->push_write( "OK ".$length."\n".$ans."\n" );
                                                        say "head OK ", $length ;
                                                    } else {
                                                        $h->push_write( "NOT OK\nCant head this page\n$URL\n" );                                                    
                                                    }
                                                    });
                        }
                        when ('GET') {
                            if (!defined($URL)) {
                                $h->push_write("You should set URL\nTry '?' to get help\n");
                                return;
                            }
                            get_request ($URL, sub {
                                                my ($ans, $length) = @_;

                                                if ($length){
                                                    $h->push_write( "OK ".$length."\n".$ans."\n " );
                                                    say "get OK ", $length;
                                                } else {
                                                    $h->push_write( "NOT OK\nCant get this page\n$URL\n" );                                                    
                                                }

                                        });

                        }
                        
                        when ('FIN') {
                            $h->push_write("Goodbye\n");
                            $h->destroy;
                        }

                        default {
                            $h->push_write("Unknown operation: '${op}'\n");
                        }
                    }
                })
            }
        );

    };

$cv->recv;

sub head_request {
    my $page = shift;
    my $cb = shift;

    $cv->begin;

    http_head ($page, 
            sub {
                my ($body, $header) = @_;
                #p $header;
                my $ans = join "\n", map { "$_ : ". $header->{$_} } sort keys %$header;
                $cb->($ans, $header->{'content-length'} // length $ans);
                $cv->end;
            });

}


sub get_request {

    my $page = shift;
    my $cb = shift;

    $cv->begin;
    http_get ($page, 
            sub {
                my ($body, $header) = @_;
                # p $header;
                #warn $header->{'content-length'};
                $cb->($body, $header->{'content-length'} // length $body);
                $cv->end;
            });

}


