package Crawler;

use 5.010;
use strict;
use warnings;
#no warnings 'recursion';

use AnyEvent::HTTP;
use Web::Query;
use URI;
# doesnt installed on my PC
#use Coro::LWP; # afterwards LWP should not block

use DDP;
no warnings 'once';
use feature 'state';
use List::Util qw(min sum);
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

our $linksArr;
our $links;
our $global_factor;
our $global_size;
#say run();
sub run {
    my ($start_page, $parallel_factor) = @_;
    #$start_page = "https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler" if ! $start_page;
    $global_factor = $parallel_factor;

    $start_page = URI->new($start_page)->canonical->as_string;

    $AnyEvent::HTTP::MAX_PEER_HOST = $parallel_factor;

    my $total_size;
    my @top10_list;
    my $crawled_size;
    
    push @$linksArr, $start_page;

    # AE begins there
    crawl_this();
    
    warn "ended";
    my $ck = sum(values %$links);
    say $ck;
    p $links;
    say sprintf "%d", $total_size/1024;
    @top10_list[0..9] = sort { $links->{$b} <=> $links->{$a} } keys %$links;
    
    #p $links;
    #p $linksArr;
    #p @top10_list;
    $total_size = $global_size;
    #$total_size = 10887168;
    return $total_size, @top10_list;
}

sub crawl_this {

    my $cv = AnyEvent->condvar();
    my $index = 0;
    my $workers = 0;

    $cv->begin;

    my $next;
    $next = sub {

        return if ($index > $#$linksArr or $index > 1000 );

        my $page = $linksArr->[$index++];
        say "I ",$index;
        say "W ", $workers;
        #say $page;
        #say $counter;
        $cv->begin;
        
        http_head ($page, 
            sub {
                my ($body, $header) = @_;
                
                my $hsize = length($header);
                $global_size += $hsize;
                

                if (    $header->{'Status'}       =~ /^2/     and
                        $header->{'content-type'} =~ m{^text/html} ) {
                    
                    my $uri = URI->new();    
                    my $wq = Web::Query->new(); 
                    
                    http_get ( $page,
                        sub {
                            my ($body, $header) = @_;                    
                            my $bsize = length($body);
                            say defined($body)? "ok" : "NOOOO";
                            $wq = $wq->add( $body );            
                            
                            #warn "got", $bsize;
                            $links->{$page} = $bsize;    
                            $global_size += $bsize;

                            # getting othen links
                            push @$linksArr,    map { $_->as_string }
                                                grep { $links->{$_} = 0 ; 1}           # так можно? хотя вообще-то и не очень это нужно
                                                grep { length($_) && !exists $links->{$_} }
                                                grep { $_ =~ m/^${page}/ }                      # i dont like it regex !!!(donf forget to fix)
                                                map { 
                                                    my $other_uri = $uri->new_abs($_, $page)->canonical;    #
                                                    $other_uri->fragment(undef); $other_uri                  # cutting fragment
                                                }
                                                $wq->find('[href]')->attr('href');
                                
                            #p $linksArr;
                            for (0..min((scalar(@$linksArr) - $workers - $index), $global_factor-1)) {
                                # say (scalar($linksArr) - $workers - $index);
                                # $, = " ";
                                # say $workers,$index, scalar(@$linksArr);
                                $workers++;
                                $next->();
                            }
                            $next->();
                            $workers--;
                            $cv->end;
                            #say "Stop";
                        }
                    );

                } else {
                    #say "Stop not 200";
                    $next->();
                    $workers--;
                    $cv->end;   
                }
        });
    };

    $workers++;
    $next->();

    $cv->end;
    $cv->recv;

};
1;
__END__
sub get_links_from {

    my $uri = URI->new();    
    my $wq = Web::Query->new();    
    my $cv = AnyEvent->condvar();  
    my $guard;
    state $index = 0; 
    state $works = 0;

    $cv->begin;

    warn "in get_links_from";

    $guard = sub {
        if ($#$linksArr > 1000 or $index > $#$linksArr){
                return ;
        }
        my $page = $linksArr->[$index++];
        say "I ", $index;
        
        warn "getting links";
        
        warn $page;
        $cv->begin;

        http_get ( $page,
            on_body => sub {
                my ($body, $header) = @_;
                #say length $body;
                
                $wq = $wq->add( $body );            
                #p @_;
            },
            sub {                               # say 'no' to regexp
               push @$linksArr, map { $_->as_string }
                                grep { $links->{$_} = 1 ; 1}           # так можно? хотя вообще-то и не очень это нужно
                                grep { length($_) && !exists $links->{$_} }
                                grep { $_ =~ m/^${page}/ }                      # i dont like it regex !!!(donf forget to fix)
                                map { 
                                    my $other_uri = $uri->new_abs($_, $page)->canonical;    #
                                    $other_uri->fragment(undef); $other_uri                  # cutting fragment
                                }
                                $wq->find('[href]')->attr('href');
                
                #
                p $linksArr;
                
                $guard->();
                

                $cv->end;
            }
        );
    };

        $guard->();

    $cv->end;
    $cv->recv;

}

1;
