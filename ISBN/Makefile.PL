require 5.008;

use ExtUtils::MakeMaker 6.65;

eval "use Test::Manifest 1.21";
	
WriteMakefile(
	'NAME'          => 'Business::ISBN',
	'ABSTRACT'      => 'Parse and validate ISBNs',
	'VERSION_FROM'  => 'lib/Business/ISBN.pm', 
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',

	'PREREQ_PM'     => {
		'Business::ISBN::Data' => '20140910',
		'URI'                  => '0',
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

	clean => { FILES => '*.bak Business-*' },
	);
