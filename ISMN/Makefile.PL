# $Id: Makefile.PL,v 1.4 2002/10/22 16:47:21 comdog Exp $
use ExtUtils::MakeMaker;

sub ExtUtils::MM_Any::test_via_harness
	{
    my($self, $perl, $tests) = @_;

    return qq|\t$perl "-MTest::Manifest" | .
           qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
           qq|'\$(INST_ARCHLIB)')"\n|;
	}
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISMN',
    'VERSION_FROM' 	=> 'lib/ISMN.pm', 
    'PREREQ_PM'     => {
    	'File::Find::Rule' => '0',
    	'List::Util'       => '0',
    	'Test::Manifest'   => '0.9',
    	'Test::More'       => '0',
    	'Test::Pod'        => '0',
    	'Test::Prereq'     => '0.14',
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
