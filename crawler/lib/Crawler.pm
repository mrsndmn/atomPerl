package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;

use DDP;
no warnings 'once';

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
    $start_page = "https://www.github.com" if ! $start_page;
    $parallel_factor = 4 if ! $parallel_factor;


    my $q = Web::Query->new_from_url($start_page);
    #open (my $fh1, "+>:utf8", "gh.html") or die "Cant get or create file";

    my $uri = URI->new();
    $AnyEvent::HTTP::MAX_PEER_HOST = $parallel_factor;

    open (my $fh, "+>:utf8", "gh.html") or die "Cant get or create file";

    my $total_size = 0;
    my @top10_list;

    my $wq = Web::Query->new();    

    my $cv = AnyEvent->condvar();
    
    $cv->begin;
    http_get ($start_page, 
        on_header => sub {
        warn $_[0]->{'Status'};
        }, 
        on_body => sub {
            warn  'BODYY';
            $wq = $wq->add( $_[0] );            
            #p @_;
        },
        sub {
            print "in cb\n";
            my %s = map {$_ => 1}   map { $uri->new_abs($_, $start_page)->as_string() } 
                                   grep { length($_) } $wq->find('[href]')->attr('href');
            p %s;
            say scalar(keys %s);
            print $fh $wq->as_html();
            $cv->end;                   
    });

    
    $cv->recv;

    return $total_size, @top10_list;
}

1;
