# $Id: load.t,v 2.1 2007/01/30 04:14:04 comdog Exp $
BEGIN { @classes = map { "Business::ISBN" } '', '::Data' }

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "Bail out!" unless use_ok( $class );
	}
