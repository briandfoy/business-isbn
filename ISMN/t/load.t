BEGIN {
	@classes = qw(Business::ISMN Business::ISMN::Data);
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "bail out! Could not compile $class\n" unless use_ok( $class );
	}
