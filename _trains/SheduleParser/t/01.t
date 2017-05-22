use strict;
use warnings;

use feature 'say';
use DDP;

use lib 'lib';

use Test::More tests => 1;

BEGIN {
	use_ok('Local::ShedParser');
}

Local::ShedParser->parse('https://home.mephi.ru/study_groups/2190/week');