# $Id: load.t,v 2.2 2007/03/11 20:17:09 comdog Exp $
BEGIN { @classes = map { "Business::ISBN$_" } '',  '10', '13' }

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "Bail out!\n" unless use_ok( $class );
	}
