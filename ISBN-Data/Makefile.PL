# $Id: Makefile.PL,v 1.3 2003/11/27 14:13:25 comdog Exp $
use ExtUtils::MakeMaker;
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN::Data',
    'VERSION_FROM' 	=> 'Data.pm', 
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
