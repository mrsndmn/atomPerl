package myconst;
use 5.022;
use warnings;

use DDP;
=encoding utf8

=head1 NAME

    myconst - pragma to create exportable and groupped constants

    =head1 VERSION

    Version 1.00

=cut
our $VERSION = '1.00';
    
    $, = ', ';

 sub import {
    my $self = shift;
    my $caller = caller;
    
    my %wanted = @_;    
    p %wanted;

    if (!scalar( keys %wanted ) ) {return;}
    say '%wanted not empty';

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
                say "2) ".$val, $subname, ref $subname;
                
                if (ref $val->{$subname} ne '' ||
                             notValid($subname))    {
                    die "Bad argument $subname\n";                
                }
                
                *{"$caller::$subname"} = sub() {$val->{$subname}}
            }
        }

        elsif (ref $val eq '')  {
            say "3) ", $val;           
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
 

        # if ( any {ref $_ ne 'HASH' && ref $_ ne ''} keys %wanted) {
        #         #say ref $name ne 'HASH' , ref $name ne '';
        #         die "Bad argument $_\n";                
        #     }

        # no strict 'refs';            
        # foreach my $name (keys %wanted){

        #     if (ref $wanted{$name} eq 'HASH') {
        #         foreach my $subname (keys %{$wanted{$name}}) {
        #             say "2) ", $name, $subname;
        #             *{"$caller::$subname"} = sub() {$wanted{$name}->{$subname}}
        #         }
        #     }

        #     elsif (ref $wanted{$name} eq '')  {
        #         say "3) ", $name;           
        #         *{"$caller::$name"} = sub() {$wanted{$name}}
        #     } else {
        #         die "Bad argument $name\n";
        #     }


        # }
        # require strict;

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



1;
