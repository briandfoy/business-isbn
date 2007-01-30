# $Id: Makefile.PL,v 2.1 2007/01/30 04:14:03 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'ISBN.pm', 
	'LICENSE'       => 'perl',
 
 'PREREQ_PM'     => {
    	'Test::More'           => '0',
    	'Business::ISBN::Data' => '1.09',
    	},

	'PM'            => { 
		'lib/ISBN.pm'   => '$(INST_LIBDIR)/ISBN.pm',
		'lib/ISBN10.pm' => '$(INST_LIBDIR)/ISBN10.pm',
		'lib/ISBN13.pm' => '$(INST_LIBDIR)/ISBN13.pm',
		},
	

	clean => { FILES => '*.bak Business-*' },
	);
