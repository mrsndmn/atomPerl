#!/usr/bin/env perl

use strict;
use warnings;


use Dancer2;

get '/' => sub {
return 'Hello World!';
};

start;
