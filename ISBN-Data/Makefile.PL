# $Id: Makefile.PL,v 1.1 2002/11/25 20:10:01 comdog Exp $
use ExtUtils::MakeMaker;

sub ExtUtils::MM_Any::test_via_harness
		{
		my($self, $perl, $tests) = @_;

		return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
		}
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN::Data',
    'VERSION_FROM' 	=> 'Data.pm', 
    'PREREQ_PM'     => {
    	'File::Find::Rule' => '0',
    	'Test::Manifest'   => '0.9',
    	'Test::More'       => '0',
    	'Test::Pod'        => '0',
    	},
	'PM'            => { 
		'Data.pm' => '$(INST_LIBDIR)/ISBN/Data.pm',
		},
                         
	'MAN3PODS'		 => {
		'Data.pm' => '$(INST_MAN3DIR)/Business::ISBN::Data.3',
			},

	clean => { FILES => 'Business-ISBN-Data*' },
	);
