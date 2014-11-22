require 5.008;

use ExtUtils::MakeMaker 6.65;

eval "use Test::Manifest 1.21";
	
WriteMakefile(
    'NAME'  	 	=> 'Business::ISMN',
    'VERSION_FROM' 	=> 'lib/Business/ISMN.pm', 
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	'ABSTRACT'      => 'Work with International Standard Music Numbers',
	
    'PREREQ_PM'     => {
    	'List::Util'       => '0',
    	'Tie::Cycle'       => '0',
    	},

	'TEST_REQUIRES' => {
		'Test::More'  => '0.95',
		},

	'META_MERGE' => {
		'meta-spec' => { version => 2 },
			resources => {
				repository => {
					type => 'git',
					url  => 'https://github.com/briandfoy/business--isbn.git',
					web  => 'https://github.com/briandfoy/business--isbn',
				},
			},
		},

    clean  => { FILES => 'Business-ISMN-*' },
	);
