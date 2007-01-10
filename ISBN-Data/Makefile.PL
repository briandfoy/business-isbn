# $Id: Makefile.PL,v 1.6 2007/01/10 03:45:41 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
                       
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN::Data',
    'VERSION_FROM' 	=> 'Data.pm', 
	'LICENSE'       => 'perl',
    'PREREQ_PM'     => {
    	'Test::More'       => '0',
    	},
	'PM'            => { 
		'Data.pm' => '$(INST_LIBDIR)/Data.pm',
		},
                         
	'MAN3PODS'		 => {
		'Data.pm' => '$(INST_MAN3DIR)/Business::ISBN::Data.3',
			},

	clean => { FILES => 'Business-ISBN-Data*' },
	);
