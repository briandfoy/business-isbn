# $Id: Makefile.PL,v 1.8 2007/10/26 02:37:55 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
                       
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN::Data',
    'VERSION_FROM' 	=> 'Data.pm', 
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	'ABSTRACT'      => 'Data pack for Business::ISBN',
	
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
