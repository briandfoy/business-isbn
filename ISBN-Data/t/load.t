# $Id: load.t,v 1.2 2004/09/15 00:51:14 comdog Exp $
BEGIN {
	@classes = qw(Business::ISBN::Data);
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "bail out! $class did not compile!" unless use_ok( $class );
	}
