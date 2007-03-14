#!/usr/bin/perl
use strict;

use Test::More 'no_plan';

my $class = 'Business::ISBN';

use_ok( $class );

ok( defined &Business::ISBN::png_barcode, "Method defined" );

foreach my $num ( qw( 0596527241 9780596527242 ) )
	{
	my $isbn = Business::ISBN->new( $num );
	isa_ok( $isbn, $class );
	
	ok( $isbn->is_valid, "Valid ISBN" );
	
	SKIP: {
		skip "Need GD::Barcode::EAN13", 2,
			unless eval "use GD::Barcode::EAN13";
			
		my $png  = eval { $isbn->png_barcode };
		ok( defined $png, "PNG defined" );
		}
	}
