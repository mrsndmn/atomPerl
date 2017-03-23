package Local::MatrixMultiplier;
use 5.022;
use strict;
use warnings;
use List::Util qw(any);
use DDP;

sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    my $res = [];

    # mat_a -> m x p
    my $m = scalar(@{$mat_a});
    my $pa = scalar(@{$mat_a->[0]});
    # mat_b -> p x n
    my $pb = scalar(@{$mat_b});
    my $n = scalar(@{$mat_b->[0]});
    
    #say ( $m, $n, $pa, $pb );
    die "Wrong Matrix" if ((any { $_ == 0 } $m, $n, $pa, $pb) || $pa != $pb);

    # res will be m x n
    my $cellsCount = $m * $n;
    
    if ($cellsCount < $max_child) {
        $max_child = $cellsCount;
    }

    die "You are CRAZY!" if $max_child > 100;

    my $avgCalculateCells = int( $cellsCount / $max_child );       


    my (@pids, @pipeRead);
    my ($r, $w);            # parent
    pipe ($r, $w);
    for my $i (0..$max_child-1){
        
        if (my $pid = fork()){
            
            push @pids, $pid;
            push @pipeRead, $r;
            
            close($w);
            warn "parent".$i;

        } else {                # child
            die "Cant fork" unless defined $pid;
            close($r);
            $w->autoflush(1);

            warn "child.$i";
            my ($fromCell, $toCell); # each Cell number may be presented as 1, 2, 3 .. m*n or like this
                                                                            # [0][0], [0][1]  ... [1][0]... [m][n]
                                                                            # $Cell ~ [int($Cell / n)] [$Cell % n]
            if ($i == $max_child-1) {
                $fromCell = $i * $avgCalculateCells;
                $toCell = $cellsCount - 1;                  # but may be one of the child will calculate liitle more cells
            } else {
                $fromCell = $i * $avgCalculateCells;
                $toCell = $fromCell + $avgCalculateCells - 1;
            }
             
            my @calculatedCells;
            
            for my $cell ($fromCell..$toCell) {
                my $i =  int($cell / $n) ;
                my $j =  $cell % $n ;   

                foreach my $k (0..$pa-1) {
                    $, = ", ";
                    #say $i, $j, $k, $mat_a->[$i]->[$k], $mat_b->[$k]->[$j];
                    $calculatedCells[$cell - $fromCell] += $mat_a->[$i]->[$k] * $mat_b->[$k]->[$j];
                }

            }

            #p @calculatedCells;
            # waitpid !!!!!!!
            foreach (@calculatedCells){
                #say $_;
                print $w $_."\n";
            }
            close($w);
            exit;
        }
    }

    # waitpid !!!!!!!
    my $count = 0 ;
    foreach my $q (0..$#pids) {
        my $p = $pids[$q];
        my $r = shift @pipeRead;
        while (<$r>) {
            my $i = int($count / $n);
            my $j = $count % $n;
            chomp $_;
            $res->[$i]->[$j] = $_;
            $count++;
        }
        waitpid ($p, 0); #?//        
        close($r);
    }

    # one line solution
    # foreach my $i (0..$m-1) {
    #     die "wrong Matrix" if (scalar(@{$mat_a->[$i]})!=$pa);       # if Matrix is correct
    #     foreach my $j (0..$n-1) {
    #         foreach my $k (0..$pa-1) {
    #             die "wrong Matrix" if (scalar(@{$mat_b->[$k]})!=$pa);   # if Matrix is correct
    #             $res->[$i][$j] += $mat_a->[$i]->[$k] * $mat_b->[$k]->[$j];
    #         }
    #     }        
    # }
    #p $res;
    return $res;
}

1;
