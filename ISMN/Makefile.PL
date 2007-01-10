# $Id: Makefile.PL,v 1.7 2007/01/10 03:47:51 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISMN',
    'VERSION_FROM' 	=> 'lib/ISMN.pm', 
	'LICENSE'       => 'perl',

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
