# $Id: pod.t,v 1.2 2003/11/27 14:13:45 comdog Exp $
BEGIN {
	@files = qw(Data.pm);
	}

use Test::More tests => scalar @files;

SKIP: {
	eval { require Test::Pod; };

	skip "Skipping POD tests---No Test::Pod found", scalar @files if $@;
	
	my $v = $Test::Pod::VERSION;
	skip "Skipping POD tests---Test::Pod $v deprecated. Update!", scalar @files
		unless $Test::Pod::VERSION >= 0.95;
			
	foreach my $file ( @files )
		{
		Test::Pod::pod_file_ok( $file );
		}

	}