require 5.008;

use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.21";
	
WriteMakefile(
	'NAME'          => 'Business::ISBN',
	'ABSTRACT'      => 'Parse and validate ISBNs',
	'VERSION_FROM'  => 'lib/Business/ISBN.pm', 
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',

	'PREREQ_PM'     => {
		'Test::More'           => '0',
		'Business::ISBN::Data' => '20081208',
		'URI'                  => '0',
		},

	META_MERGE => {
		'meta-spec' => { version => 2 },
			resources => {
				repository => {
					type => 'git',
					url  => 'https://github.com/briandfoy/business--isbn.git',
					web  => 'https://github.com/briandfoy/business--isbn',
				},
			},
		},

	clean => { FILES => '*.bak Business-*' },
	);
