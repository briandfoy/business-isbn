# $Id: load.t,v 1.2 2002/10/09 06:17:52 comdog Exp $
BEGIN {
	use File::Find::Rule;
	@classes = map { my $x = $_;
		$x =~ s|^blib/lib/||;
		$x =~ s|/|::|g;
		$x =~ s|\.pm$||;
		$x;
		} File::Find::Rule->file()->name( '*.pm' )->in( 'blib/lib' );
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "bail out! Could not compile $class\n" unless use_ok( $class );
	}
