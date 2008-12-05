#!/usr/local/bin/perl5.10.0
use 5.010;

use strict;
use warnings;

use LWP::Simple;

my $js_url = 'http://www.isbn-international.org/converter/ranges.js';
my $js_data = get( $js_url );
die "Could not fetch $js_url!" unless defined $js_data;

$js_data =~ s|.*?// \s+ ID \s+ List: \s+||s;

my @keys = qw(text ranges);
my %data;

while( $js_data =~
	/
		^gi\.area(?<group>\d+)\.text \s* = \s* "(?<text>.*?)" ;?  [\r\n]+
		^gi\.area(\1)\.pubrange \s* = \s* "(?<ranges>.*?)"    ;?  [\r\n]+
    /gmx
    )
	{
	@{ $data{ $+{group} } }{ @keys } = @+{ @keys };
	}

foreach my $group ( sort keys %data )
	{
	my $empty = $data{$group}{text} =~ s/\s+-\s+no ranges fixed yet\s*//;
	my $text  = $data{$group}{text};
	
	$text =~ s/'/\\'/g;
	
	printf "%-5s => [%s =>   [",
		$group,
		qq|'$text'|;
		;
	
	if( $empty )
		{
		print "] ],\n";
		next;
		}

	my @ranges = 
		map { 
			if( /-/ ) { map { qq|'$_'| } split /-/, $_ }
			else      { qq|'$_'|, qq|'$_'| }
			} 
		split /;/, $data{$group}{ranges};
	warn "Odd number of ranges for $text!\n" if @ranges % 2;
	
	foreach my $i ( 0 .. $#ranges - 1 )
		{
		print $ranges[$i], ( " => ", ", " )[$i % 2];
		}
	print $ranges[-1], "] ],\n";	
	}

#     0 => ['English',               ['00' => '19', '200' => '699', '7000' => '8499', '85000' => '89999', '900000' => '949999', '9500000' => '9999999' ] ],
