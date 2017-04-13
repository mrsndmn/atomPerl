#!/usr/bin/env perl

use strict;
use warnings;


use Dancer2;

get '/' => sub {
  template 'show_entries.tt', {
     'msg' => get_flash(),
     'add_entry_url' => uri_for('/add'),
     'entries' => $sth->fetchall_hashref('id'),
  };
};

dance;
