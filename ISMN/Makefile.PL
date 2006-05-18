# $Id: Makefile.PL,v 1.6 2006/05/18 23:04:39 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISMN',
    'VERSION_FROM' 	=> 'lib/ISMN.pm', 
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
