package myconst;
use 5.020;
use warnings;
use strict;
use List::Util qw(any);
use DDP;

no warnings 'once';

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

    return if (!scalar(@_));

    die "invalid args" if (any { !defined($_) } @_ );
    
    my %wanted;    
    
    my $exprtTgs;
    
    while (scalar @_) {
        my $key = shift;
        my $val = shift;
        
        die "Bad arguments!\n" if ( ref $key ne '' || notValid($key) );
        $wanted{$key} = $val;

        if (ref $val eq 'HASH') {
            #warn "val eq hash" , p $val;
            #die "Bad aguments!\n" if (notValid($val));

            foreach my $subname (keys %$val) {
                #warn "subkey = ", $subname;
                die "Bad argument $subname\n" if ( (ref $val->{$subname}) ne'' or notValid($subname));

                $exprtTgs->{'all'}->{$subname} = $subname;
                $exprtTgs->{$key}->{$subname} = $subname;
                
                no strict 'refs';    
                *{"${caller}::${subname}"} = sub() {$val->{$subname}};
                use strict;

            }
        
        } elsif (ref $val eq '')  {
            $exprtTgs->{'all'}->{$key} = $key;
            
            no strict 'refs';
            *{"${caller}::${key}"} = sub() {$val};
            use strict;

        } else {
            #warn "main else";
            die "Bad argument $key\n";
        }

        no strict 'refs';        
        ${"${caller}::"}{"EXPORT_TAGS"} = $exprtTgs;
        use strict;        
        #p ${"${caller}::"}->{"EXPORT_TAGS"};

    }

    # override other import  
    no strict 'refs';
    *{"${caller}::import"} = sub() {
        use strict;    
        my $self = shift;
        my %wanted;

        no strict 'refs';
        my $exprtTgs = ${"${self}::"}{"EXPORT_TAGS"};
        use strict;        
        #warn "in overriden import",p %{"${self}::"};

        foreach my $wanna (@_){
            #warn "wann -> ", $wanna;
            if (my $tag = shift @{[$wanna =~ m/^:(.*)/ ]}) {
                #warn "tag", $tag;
                die "Bad argument! $tag\n" if !exists $exprtTgs->{$tag};
                my $tagHash = $exprtTgs->{"$tag"};
                
                foreach my $const (keys %{$tagHash}) {
                    $wanted{$const} = $const;
                }
                last if $tag eq 'all'; 
            } else {
                die "Bad arguments! $wanna \n" if ( ref $wanna ne '' or 
                                                    !exists $exprtTgs->{'all'}->{$wanna});
                #
                $wanted{$wanna} = $wanna;
            }
        }

        my $callerer = caller;

        foreach my $subname (keys %wanted) {
            no strict 'refs';            
            *{"$callerer::$subname"} =  "$self::$subname";
            use strict;    
        }

    };
    use strict;

 }

sub notValid {
    my $str = shift;
    return (!defined $str) || ($str =~ m/^$ | ^\d | [@\'\"\\\/] /x);
}

1;
