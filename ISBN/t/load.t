# $Id: load.t,v 1.3 2004/02/11 21:00:32 comdog Exp $
BEGIN { @classes = map { "Business::ISBN" } '', '::Data' }

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "Bail out!" unless use_ok( $class );
	}
