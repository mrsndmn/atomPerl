package myconst;
use 5.022;
use warnings;
use strict;

#use DDP;


=encoding utf8

=head1 NAME

    myconst - pragma to create exportable and groupped constants

    =head1 VERSION

    Version 1.00

=cut
=head1 SYNOPSIS
    package aaa;

    use myconst math => {
            PI => 3.14,
            E => 2.7,
        },
        ZERO => 0,
        EMPTY_STRING => '';

    package bbb;

    use aaa qw/:math PI ZERO/;

    print ZERO;             # 0
    print PI;               # 3.14
=cut

our $VERSION = '1.00';
    
    #$, = ', ';

 sub import {
    my $self = shift;
    my $caller = caller;
    my %wanted = @_;
    #warn p %wanted;

    return if (!scalar( keys %wanted ) );

    no strict 'refs';
    
    while (scalar @_) {
        my $key = shift;
        my $val = shift;
        
        die "Bad arguments!\n" if ( ref $key ne '' || notValid($key) );
            
        if (ref $val eq 'HASH') {

            die "Bad arguments!\n" if (notValid($val));

            foreach my $subname (keys %$val) {                
                die "Bad argument $subname\n" if (ref $val->{$subname} ne '' || notValid($subname));

                ${"${caller}::"}{"EXPORT_TAGS"}->{'all'}->{$subname} = $subname;
                ${"${caller}::"}{"EXPORT_TAGS"}->{"$key"}->{$subname} = $subname;
                *{"${caller}::${subname}"} = sub() {$val->{$subname}}
            }
        
        } elsif (ref $val eq '')  {
            ${"${caller}::"}{"EXPORT_TAGS"}->{'all'}->{$key} = $key;

            *{"${caller}::${key}"} = sub() {$val}
        } else {
            die "Bad argument $key\n";
        }

    }

    # override other import          
    *{"${caller}::import"} = sub() {

        my $self = shift;
        my %wanted;
        foreach my $wanna (@_){

            if (my $tag = shift @{[$wanna =~ m/^:(.*)/ ]}) {
                #warn $tag;
                die "Bad argument! $tag\n" if !exists ${"${self}::"}{"EXPORT_TAGS"}->{$tag};
                my $tagHash = ${"${self}::"}{"EXPORT_TAGS"}->{"$tag"};
                
                foreach my $const (keys %{$tagHash}) {
                    $wanted{$const} = $const;
                }
                last if $$tag eq 'all'; 

            } else {
                die "Bad arguments! $wanna \n" if ( ref $wanna ne '' || 
                                                    !exists ${"${self}::"}{"EXPORT_TAGS"}->{'all'}->{"$wanna"});
                #
                $wanted{$wanna} = $wanna;
            }
        }

        my $val = shift;
        my $callerer = caller;

        foreach my $subname (keys %wanted) {
            *{"$callerer::$subname"} =  "$self::$subname";
        }

    };

    require strict;

 }

sub notValid {
    my $str = shift;
    return (!defined $str) || ($str =~ m/^$ | ^\d | [@\'\"\\\/] /x);
}

1;
