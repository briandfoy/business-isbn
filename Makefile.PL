# $Id: Makefile.PL,v 1.5 2004/01/28 17:35:42 comdog Exp $
use ExtUtils::MakeMaker;

sub ExtUtils::MM_Any::test_via_harness
	{
	my($self, $perl, $tests) = @_;

	return qq|\t$perl "-MTest::Manifest" | .
		qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
		qq|'\$(INST_ARCHLIB)')"\n|;
	}

WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'ISBN.pm', 
    'PREREQ_PM'     => {
    	'Test::Manifest'   => '0',
    	'Test::More'       => '0',
    	},
	'PM'            => { 
		'ISBN.pm' => '$(INST_LIBDIR)/ISBN.pm',
		'Data.pm' => '$(INST_LIBDIR)/ISBN/Data.pm',
		},
	
	'MAN3PODS'  => {
			'ISBN.pm' => '$(INST_MAN3DIR)/Business::ISBN.3',
			},

	clean => { FILES => '*.bak Business-*' },
	);
