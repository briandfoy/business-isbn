# $Id: load.t,v 1.2 2004/01/28 17:31:16 comdog Exp $
BEGIN {
	use File::Find::Rule;
	@classes = qw(Business::ISBN Business::ISBN::Data);
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "Bail out!" unless use_ok( $class );
	}
