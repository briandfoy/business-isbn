use ExtUtils::MakeMaker;
# $Author: comdog $
# $Id: Makefile.PL,v 1.1.1.1 2001/08/13 06:38:02 comdog Exp $

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'  	 	=> 'Business::ISBN',
    'VERSION_FROM' 	=> 'ISBN.pm', # finds $VERSION
);
