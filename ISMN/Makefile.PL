# $Id: Makefile.PL,v 1.3 2002/10/09 06:25:43 comdog Exp $
use ExtUtils::MakeMaker;

my $tests = do {
	local @ARGV = qw(t/test_manifest);
	my $data = join " ", map {chomp; "t/$_" } <>;
	};
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISMN',
    'VERSION_FROM' 	=> 'lib/ISMN.pm', 
    'PREREQ_PM'     => {
    	'File::Find::Rule' => '0',
    	'List::Util'       => '0',
    	'Test::More'       => '0',
    	'Test::Pod'        => '0',
    	'Test::Prereq'     => '0',
    	'Tie::Cycle'       => '0',
    	},
	'PM'            => { 'lib/ISMN.pm' => '$(INST_LIBDIR)/ISMN.pm',
                         'lib/Data.pm' => '$(INST_LIBDIR)/ISMN/Data.pm',
                         
                          },
                         
    depend => { Makefile => 't/test_manifest' },
    test   => { TESTS => $tests },
    clean  => { FILES => 'Business-ISMN-*' },
	);
