# $Id: Makefile.PL,v 1.1 2002/09/09 16:37:45 comdog Exp $
use ExtUtils::MakeMaker;

my $tests = do {
	local @ARGV = qw(t/test_manifest);
	my $data = join " ", map {chomp; "t/$_" } <>;
	};
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISMN',
    'VERSION_FROM' 	=> 'lib/ISMN.pm', 
    'PREREQ_PM'     => {
    	Test::More       => 0,
    	Test::Pod        => 0,
    	File::Find::Rule => 0,
    	Tie::Toggle      => 0,
    	List::Util       => 0,
    	},
	'PM'            => { 'lib/ISMN.pm' => '$(INST_LIBDIR)/ISMN.pm',
                         'lib/Data.pm' => '$(INST_LIBDIR)/ISMN/Data.pm',
                         
                          },
                         
    depend => { Makefile => 't/test_manifest' },
    test   => { TESTS => $tests },
	);
