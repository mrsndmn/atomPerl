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

    $AnyEvent::HTTP::MAX_PEER_HOST = $parallel_factor;

    my $total_size = 0;
    my @top10_list;

    my $cv = AnyEvent->condvar();
    #$cv->begin;


    $cv->begin;
    http_head ($start_page, 
        #recurse => 0,
        on_header => sub {
        p $_[0]->{'URL'};
        $cv->end;            
        }, 
        sub {
            p @_;
            print "in cb\n";
            $cv->end;
    });

    
    #$cv->end;
    $cv->recv;

    return $total_size, @top10_list;
}

1;
