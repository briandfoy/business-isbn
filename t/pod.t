# $Id: pod.t,v 1.1 2002/09/04 20:53:22 comdog Exp $
BEGIN {
	use File::Find::Rule;
	@files = File::Find::Rule->file()->name( '*.pm' )->in( 'blib/lib' );
	}

use Test::More tests => scalar @files;
use Test::Pod;

foreach my $file ( @files )
	{
	pod_ok( $file );
	}
