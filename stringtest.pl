#!/usr/bin/perl

use Business::ISBN;

my $GOOD_ISBN          = "1565922573";

my $isbn = new Business::ISBN $GOOD_ISBN;

print $isbn->as_string;
