# $Id: Makefile.PL,v 1.8 2004/11/22 01:45:19 comdog Exp $
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
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'ISBN.pm', 
    'PREREQ_PM'     => {
    	'Test::More'           => '0',
    	'Business::ISBN::Data' => '1.08',
    	},
	'PM'            => { 
		'ISBN.pm' => '$(INST_LIBDIR)/ISBN.pm',
		},
	
	'MAN3PODS'  => {
			'ISBN.pm' => '$(INST_MAN3DIR)/Business::ISBN.3',
			},

	clean => { FILES => '*.bak Business-*' },
	);
