#!/usr/bin/perl

use Test::More 'no_plan';

use_ok( 'Business::ISBN::Data' );
ok( defined %Business::ISBN::country_data );

foreach my $key ( sort { $a <=> $b } keys %Business::ISBN::country_data )
	{
	my $value = $Business::ISBN::country_data{$key};
	isa_ok( $value, ref [], "Value is array ref for country $key" );
	
	my( $country, $ranges ) = @$value;
	
	my $count = @$ranges;

	ok( ($count % 2) == 0, "Even number of elements ($count) for country $key" );
	}