use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.21";
                       
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN::Data',
    'VERSION_FROM' 	=> 'lib/Business/ISBN/Data.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	'ABSTRACT'      => 'Data pack for Business::ISBN',
	
    'PREREQ_PM'     => {
    	'Test::More'            => '0.95',
		'Carp'                  => '0',
		'File::Basename'        => '0',
		'File::Spec::Functions' => '0',
		},

	clean => { FILES => 'Business-ISBN-Data* .DS_Store' },
	);
