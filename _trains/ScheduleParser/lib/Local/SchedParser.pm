package Local::SchedParser;

use strict;
use warnings;

use feature 'say';
use DDP;
use Encode qw(encode decode);

use Web::Query;
use utf8;
# use URI;

sub parse {
	my ($self, $url) = @_;

	# my $uri = URI->new();
	my $wq = Web::Query->new_from_url( $url )or die "Cannot get a resource from $url: " . Web::Query->last_response()->status_line;;

	my @week;

	$wq->find('.lesson-wday')
		->each(
			sub {
				my ($i, $elem) = @_;
				my $text = encode('utf8', $elem->text());

				push @week, map {decode "utf8", $_ } ( $text =~ / .* , \s (.+) \s $/x );
			}
		);
	# p @week;

	my @lessons;

	$wq->find('.list-group')
		->each( 
			sub {
				# list-group
				my ($i, $elem) = @_;
				my @day;
				$elem->find(".list-group-item")
					->each(
						sub {
							# list-group-item

							my ($i, $elem) = @_;			
							# warn encode('utf8', $elem->as_html()."\n\n\n");
							my $time = $elem->find('.lesson-time')->text or die;
							# warn $lsn->{time};
							$elem->find('.lesson')->each( sub {
								my ($i, $elem) = @_;			
								
								my $lsn = {
									time => $time,
									date => $week[ (scalar @day) ],
								};
								

								my $str = $elem->text;
								$str =~ m/^\s*
									(?<room> \w\-\d{3} | \w{3}\.\d*\/?\d* | \d{3})
									(?<type>\w+)	\s+
									(?<subject> .+? ) \s+
									(?: Подгруппа \s (?<subgroup> \d ) )? \s*
									(?<teacher>\w+?\s(?:\w\.){1,2})? \s*
									#						     				--
									(?: \( (?<date> (?:\d{2}\.){2}\d{4} (?: \s \x{2014} \s (?:\d{2}\.){2}\d{4} )? ) \) )?
									\s*$
								/x;
								# warn encode('utf8', $str);;# if ! scalar %+;
								%$lsn = ( map { encode('utf8', $_) } %+, %$lsn);
								push @day, $lsn;
							} );
						}
					);
				# warn "\n==========\n";
				push @lessons, \@day;
			}
		);
	
	p @lessons;

	# p @wday;
	say join "\n\n", (@lessons);
	return \@lessons;
}


1;