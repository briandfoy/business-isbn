#!/usr/bin/perl

use Tie::Cycle;

$|++;

tie my $indicator, 'Tie::Cycle', [ qw( \ | / - ) ];

print "\n$indicator";

while ( 1 ) { print "\b$indicator"; sleep 1 }
