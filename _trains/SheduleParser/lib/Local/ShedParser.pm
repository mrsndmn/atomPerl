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

				$elem->find(".list-group-item")
					->each(
						sub {
							# list-group-item
							my ($i, $elem) = @_;			
							warn encode('utf8', $elem->as_html()."\n\n\n");
						}
					)
			}
		);

	# p @wday;
	say join "\n\n", (@lessons);

}


1;