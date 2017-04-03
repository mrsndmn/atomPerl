package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;

use DDP;
no warnings 'once';
use feature 'state';
use List::Util qw(min);
=encoding UTF8

=head1 NAME

Crawler

=head1 SYNOPSIS

Web Crawler

=head1 run($start_page, $parallel_factor)

    Сбор с сайта всех ссылок на уникальные страницы

    Входные данные:

    $start_page - Ссылка с которой надо начать обход сайта

    $parallel_factor - Значение фактора паралельности

    Выходные данные:

    $total_size - суммарный размер собранных ссылок в байтах

    @top10_list - top-10 страниц отсортированный по размеру.

=cut

run();

sub run {
    my ($start_page, $parallel_factor) = @_;
    # $start_page or die "You must setup url parameter";
    # $parallel_factor or die "You must setup parallel factor > 0";
    $start_page = "https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler/" if ! $start_page;
    $parallel_factor = 100 if ! $parallel_factor;


    my $q = Web::Query->new_from_url($start_page);
    #open (my $fh1, "+>:utf8", "gh.html") or die "Cant get or create file";

    my $uri = URI->new();
    my $links;
    my %links = ($start_page => 1); #???
    $AnyEvent::HTTP::MAX_PEER_HOST = $parallel_factor;

    open (my $fh, "+>:utf8", "gh.html") or die "Cant get or create file";

    my $total_size = 0;
    my @top10_list;

    my $wq = Web::Query->new();    
    my $cv0 = AnyEvent->condvar();
    $cv0->begin;    
    http_get ($start_page, 
            on_body => sub {
                say length $_[0];
                $wq = $wq->add( $_[0] );            
                #p @_;
            },
            sub {
                %links = map {$_ => 0} map { $_->as_string }  map { $uri = $uri->new_abs($_, $start_page)->canonical ; $uri->fragment(undef); $uri } 
                                    grep { length($_) } $wq->find('[href]')->attr('href');
                @{$links}[0..min(999, scalar(keys %links)-1)] = keys %links;
                #p $links;
                say scalar(@$links);
                print $fh $wq->as_html();
        
                $cv0->end;
            }
        );
    $cv0->recv;

    my $cv = AnyEvent->condvar();
    say join "\n", sort @$links;
    $cv->begin;

    my $next;
    $next = sub {
        return if (!scalar(@{$links}));
        state $counter++;
        return if ($counter > 1000);

        my $page = shift @$links;
        #say $page;
        #say $counter;
        $cv->begin;
        
        http_head ($page, 
            sub {
                #say $_[1]->{'content-type'};
                $total_size += length $_[1];
                if ( $_[1]->{'Status'} =~ /^2/ and $_[1]->{'content-type'} =~ m/^text\/html/ ) {
                    
                    http_get ( $page,
                        on_body => sub {
                        my $psize = length($_[0]);
                        $links{$page} = $total_size;    
                        $total_size += $psize;
                        #say $total_size;
                        }, 
                        sub {
                            $next->();
                            $cv->end;             
                        }
                    );
                } else {
                    $next->();
                    $cv->end;   
                }
        });
    };
    $next->() for 1..$parallel_factor;

    $cv->end;
    $cv->recv;

    say sprintf "%d", $total_size/1024;
    @top10_list[0..9] = sort { $links{$a} <=> $links{$b} } keys %links;
    p @top10_list;
    return $total_size, @top10_list;
}

1;
