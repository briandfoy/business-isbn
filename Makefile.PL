# $Id: Makefile.PL,v 2.2 2007/03/14 07:37:38 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'lib/ISBN.pm', 
	'LICENSE'       => 'perl',
 	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
 	
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
