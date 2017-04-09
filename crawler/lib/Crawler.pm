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

#say run();
sub run {
    my $start_page = shift;
    my $global_factor = shift; ;

    my @linksArr;
    my $links;
    my $global_size;

    #$start_page = URI->new($start_page)->canonical->as_string;

    $AnyEvent::HTTP::MAX_PEER_HOST = $global_factor;

    my @top10_list;
    
    push @linksArr, $start_page;

    # AE begins there
    my $cv = AnyEvent->condvar();
    my $index = 0;
    my $workers = 0;

    $cv->begin;

    my $next;
    $next = sub {

        return if ($index > $#linksArr or scalar @linksArr > 1000 );

        my $page = $linksArr[$index++];
        # say "I ",$index;
        # say "W ", $workers;
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
                
                if (    $header->{'Status'}       =~ /^2/
                        and scalar @linksArr
                        and $header->{'content-type'} =~ m/^text\/html/ ) {
                    
                    my $uri = URI->new();    
                    my $wq = Web::Query->new(); 
                    
                    http_get ( $page,
                        sub {
                            my ($body, $header) = @_;            
                            my $bsize = length($body);
                            $wq = $wq->add( $body );            
                            
                            # warn "got", $bsize;
                            $links->{$page} = $bsize;

                            my %tmp;
                            # getting othen links
                            # push @linksArr,     grep {$tmp->{$_} = 0; 1}
                            #                     grep { length($_) and !exists $links->{$_} }
                            #                     map { $_->as_string }
                            #                     #grep { $_ =~ m/^$start_page/ }                      # i dont like it regex !!!(donf forget to fix)
                            #                     grep { (substr $_, 0, length $start_page) eq $start_page }   # тоже криво(?), но лучше ничего не надумал
                            #                     map { 
                            #                         my $mod_uri = $uri->new_abs($_, $page)->canonical;    #
                            #                         $mod_uri->fragment(undef); $mod_uri                  # cutting fragment
                            #                     }
                            #                     $wq->find('[href]')->attr('href');

                            # моё внутреннее чувство подсказывает, что такие большие паровозы map/grep
                            # делать не стоит, но мне мне нравится, наверное
                            # warn "bfore ",scalar keys %tmp;
                            #  p $links;
                            foreach my $link ($wq->find('[href]')->attr('href')) {
                                
                                my $mod_uri = $uri->new_abs($link, $page)->canonical;
                                $mod_uri->fragment(undef);
                                $mod_uri = $mod_uri->as_string;
                                next if (substr $mod_uri, 0, length $start_page) ne $start_page;
                                next if !length($mod_uri) or exists $links->{$mod_uri};
                                $tmp{$mod_uri} = 0;
                                $links->{$mod_uri} = 0;
                            }
                            # p %tmp;
                            # p $links;
                            push @linksArr, keys %tmp;
                            
                            if (scalar(@linksArr)>1000) {
                                splice @linksArr, 1000, scalar @linksArr;
                                #warn scalar @linksArr; 
                            }

                            #p @linksArr;
                            for (0..min((scalar(@linksArr) - $workers - $index), $global_factor-1)) {
                                $workers++;
                                $next->();
                            }
                            $next->();
                            $workers--;
                            $cv->end;
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

    #say sprintf "%d", $global_size/1024;
    @top10_list[0..9] = sort { $links->{$b} <=> $links->{$a} } keys %$links;

    $global_size += $_ for (values %$links);
    # p $links;
    warn scalar keys %$links;
    say sort @linksArr;
    # p @top10_list;
    
    #$total_size = 10887168;
    return $global_size, @top10_list;
}

1;