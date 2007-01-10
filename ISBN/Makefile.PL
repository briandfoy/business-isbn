# $Id: Makefile.PL,v 1.11 2007/01/10 03:43:21 comdog Exp $
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
		'ISBN.pm' => '$(INST_LIBDIR)/ISBN.pm',
		},
	
	'MAN3PODS'  => {
			'ISBN.pm' => '$(INST_MAN3DIR)/Business::ISBN.3',
			},

	clean => { FILES => '*.bak Business-*' },
	);
