# $Id: Makefile.PL,v 1.10 2005/03/19 18:50:44 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.13";
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'ISBN.pm', 
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
