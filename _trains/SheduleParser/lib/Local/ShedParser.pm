package Local::ShedParser;

use strict;
use warnings;

use feature 'say';
use DDP;
use Encode qw(encode decode);

use Web::Query;

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
				push @week, substr ($text, 1, length($text) - 2);
				1;
			}
		);

	p @week;
	
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

							my $lsn = {};
							my ($i, $elem) = @_;			
							# warn encode('utf8', $elem->as_html()."\n\n\n");
							$lsn->{'time'} = $elem->find('.lesson-time')->text or die;
							# warn $lsn->{time};
							my $str = $elem->find('.lesson')->text;
							$str =~ /^\s*
								(?<room>\w-\d{3} | \w{3}\.\d* | \d{3})
								(?<type>\w{3})	\s*
								(?<subject> .*? ) \s*
								(?<teacher>\w*?\s\w\.\w\.)? \s*
								\( (?<date> \d{2}\.\d{2}\.\d{4} ) \)
								\s*$
							/x;
							warn encode('utf8', $str) if ! scalar %+;
							%$lsn = ( map { encode('utf8', $_) } %+, %$lsn);
							push @day, $lsn;
						}
					);
				# warn "\n==========\n";
				push @lessons, \@day;
			}
		);
	
	p @lessons;
	# p @wday;
	say join "\n\n", (@lessons);

}


1;