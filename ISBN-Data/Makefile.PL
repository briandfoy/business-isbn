use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
                       
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN::Data',
    'VERSION_FROM' 	=> 'lib/Business/ISBN/Data.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	'ABSTRACT'      => 'Data pack for Business::ISBN',
	
    'PREREQ_PM'     => {
    	'Test::More'       => '0',
    	},

	clean => { FILES => 'Business-ISBN-Data*' },
	);
