# $Id: load.t,v 1.3 2004/09/16 16:02:59 comdog Exp $
BEGIN {
	@classes = qw(Business::ISMN Business::ISMN::Data);
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "bail out! Could not compile $class\n" unless use_ok( $class );
	}
