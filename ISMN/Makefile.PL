# $Id: Makefile.PL,v 1.8 2007/10/26 02:53:51 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISMN',
    'VERSION_FROM' 	=> 'lib/ISMN.pm', 
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	'ABSTRACT'      => 'Work with International Standard Music Numbers',
	
    'PREREQ_PM'     => {
    	'List::Util'       => '0',
    	'Test::More'       => '0',
    	'Tie::Cycle'       => '0',
    	},
	'PM'            => { 'lib/ISMN.pm' => '$(INST_LIBDIR)/ISMN.pm',
                         'lib/Data.pm' => '$(INST_LIBDIR)/ISMN/Data.pm',
                         
                          },
	'MAN3PODS'     => {
		'lib/ISMN.pm' => '$(INST_MAN3DIR)/Business::ISMN.3',
		},

    clean  => { FILES => 'Business-ISMN-*' },
	);
