use ExtUtils::MakeMaker 6.65;

use 5.008;

eval "use Test::Manifest 1.21";
                       
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN::Data',
    'VERSION_FROM' 	=> 'lib/Business/ISBN/Data.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	'ABSTRACT'      => 'Data pack for Business::ISBN',
	
    'PREREQ_PM'     => {
		'Carp'                  => '0',
		'File::Basename'        => '0',
		'File::Spec::Functions' => '0',
		},

	'TEST_REQUIRES' => {
		'Test::More'            => '0.95',
		},

	'META_MERGE' => {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url  => 'git@github.com:briandfoy/business--isbn.git',
				web  => 'https://github.com/briandfoy/business--isbn',
				},
			},
		},

	clean => { FILES => 'Business-ISBN-Data* .DS_Store' },
	);
