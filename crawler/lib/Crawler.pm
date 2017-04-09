package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;
# doesnt installed on my PC
#use Coro::LWP; # afterwards LWP should not block

use DDP;
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
#9771
my @linksArr;
my $links;
my $global_factor;
my $global_size;
my $start_page;
#say run();
sub run {
    $start_page = shift;
    $global_factor = shift; 

    $start_page = URI->new($start_page)->canonical->as_string;

    $AnyEvent::HTTP::MAX_PEER_HOST = $global_factor;

    my @top10_list;
    
    push @linksArr, $start_page;

    # AE begins there
    crawl_this();
    
    #say sprintf "%d", $global_size/1024;
    @top10_list[0..9] = sort { $links->{$b} <=> $links->{$a} } keys %$links;
    
    #p $links;
    #p @linksArr;
    p @top10_list;
    
    #$total_size = 10887168;
    return $global_size, @top10_list;
}

sub crawl_this {

    my $cv = AnyEvent->condvar();
    my $index = 0;
    my $workers = 0;

    $cv->begin;

    my $next;
    $next = sub {

        return if ($index > $#linksArr or $index > 1000 );

        my $page = $linksArr[$index++];
         say "I ",$index;
         say "W ", $workers;
        #say $page;
        #say $counter;
        $cv->begin;
        
        http_head ($page, 
            sub {
                my ($body, $header) = @_;
                
                my $hsize;# = 0;
                # foreach my $k (keys %$header) {
                #     $hsize += (length $k) + (length $header->{$k});
                # }
                #warn "hsize ".$hsize;
                #p $header;
                # $global_size += $hsize;

                # if( exists $header->{"location"} 
                #     and $header->{'Status'} =~ /3/
                #     and (substr $header->{"location"} , 0, length $page) eq $start_page ) {

                #             push @linksArr, $header->{"location"};
                #             $next->();
                #             $workers--;
                #             return;
                # }
                
                if (    $header->{'Status'}       =~ /^2/     and
                        $header->{'content-type'} =~ m{^text/html} ) {
                    
                    my $uri = URI->new();    
                    my $wq = Web::Query->new(); 
                    
                    http_get ( $page,
                        sub {
                            my ($body, $header) = @_;            
                            my $bsize = length($body);
                            $wq = $wq->add( $body );            
                            
                            warn "got", $bsize;
                            $links->{$page} = $bsize;    
                            $global_size += $bsize;

                            # getting othen links
                            push @linksArr,     grep {$links->{$_} = 0; 1}
                                                grep { length($_) and !exists $links->{$_} }
                                                map { $_->as_string }
                                                #grep { $_ =~ m/^$start_page/ }                      # i dont like it regex !!!(donf forget to fix)
                                                grep { (substr $_, 0, length $start_page) eq $start_page }   # тоже криво(?), но лучше ничего не надумал
                                                map { 
                                                    my $other_uri = $uri->new_abs($_, $page)->canonical;    #
                                                    $other_uri->fragment(undef); $other_uri                  # cutting fragment
                                                }
                                                $wq->find('[href]')->attr('href');
                                
                            #p @linksArr;
                            for (0..min((scalar(@linksArr) - $workers - $index), $global_factor-1)) {
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