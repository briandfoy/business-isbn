# $Id: Makefile.PL,v 1.5 2004/09/16 16:06:18 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest";

unless( $@ )
	{
	*ExtUtils::MM_Any::test_via_harness = sub
		{
		my($self, $perl, $tests) = @_;
	
		return qq|\t$perl "-MTest::Manifest" | .
			   qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			   qq|'\$(INST_ARCHLIB)')"\n|;
		}
	}
	
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
