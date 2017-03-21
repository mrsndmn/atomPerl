package myconst;
use 5.022;
use warnings;

use DDP;

use strict;
use warnings;

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
    
    $, = ', ';

# блиииин, че-то 5 тест вообще все перевернул

 sub import {
    my $self = shift;
    my $caller = caller;
    
    my %wanted = @_ if scalar(@_)>0;    
    #p %wanted;

    if (!scalar( keys %wanted ) ) {return;}
    #say '%wanted not empty';

    while (scalar @_) {
        my $key = shift;
        my $val = shift;
        
        if ( ref $key ne '' || notValid($key) ) {
            die "Bad arguments!\n";
        }
            
        no strict 'refs';            
        
        if (ref $val eq 'HASH') {

            if (notValid($val)) {
                die "Bad arguments!\n";                
            }

            foreach my $subname (keys %$val) {
                #say "2) ".$val, $subname, ref $subname;
                
                if (ref $val->{$subname} ne '' ||
                             notValid($subname))    {
                    die "Bad argument $subname\n";                
                }
                
                *{"$caller::$subname"} = sub() {$val->{$subname}}
            }
        }

        elsif (ref $val eq '')  {
            #say "3) ", $val;           
            *{"$caller::$key"} = sub() {$val}
        } else {
            die "Bad argument $key\n";
        }
    }
    require strict;        
 }

sub notValid {
    my $str = shift;
    return (!defined $str) || ($str =~ m/^$ | ^\d | [@\'\"\\\/] /x);

}
1;
