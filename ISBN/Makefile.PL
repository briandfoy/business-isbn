# $Id: Makefile.PL,v 1.3 2002/09/04 20:53:22 comdog Exp $
use ExtUtils::MakeMaker;

my $tests = do {
	local @ARGV = qw(t/test_manifest);
	my $data = join " ", map {chomp; "t/$_" } <>;
	};
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'ISBN.pm', 
    'PREREQ_PM'     => {
    	Test::More       => 0,
    	File::Find::Rule => 0,
    	},
	'PM'            => { 'ISBN.pm' => '$(INST_LIBDIR)/ISBN.pm',
                         'Data.pm' => '$(INST_LIBDIR)/ISBN/Data.pm',
                         
                          },
                         
    depend => { Makefile => 't/test_manifest' },
    test   => { TESTS => $tests },
	);
