use ExtUtils::MakeMaker;
# $Author: comdog $
# $Id: Makefile.PL,v 1.2 2001/09/04 09:32:41 comdog Exp $

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'ISBN.pm', # finds $VERSION,
	'PM'            => { 'ISBN.pm' => '$(INST_LIBDIR)/ISBN.pm',
                         'Data.pm' => '$(INST_LIBDIR)/ISBN/Data.pm' },
);
