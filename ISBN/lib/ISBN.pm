# $Revision: 2.1 $
# $Id: ISBN.pm,v 2.1 2007/01/30 04:14:04 comdog Exp $
package Business::ISBN;
use strict;

use subs qw( _common_format _checksum is_valid_checksum
	INVALID_COUNTRY_CODE
	INVALID_PUBLISHER_CODE
	BAD_CHECKSUM
	GOOD_ISBN
	BAD_ISBN
	);
use vars qw( $VERSION @ISA @EXPORT_OK $debug %country_data
	$MAX_COUNTRY_CODE_LENGTH %ERROR_TEXT );

use Carp qw(carp);
use Exporter;

use Business::ISBN::Data 1.09; # now a separate module

my $debug = 0;

@ISA       = qw(Exporter);
@EXPORT_OK = qw(is_valid_checksum ean_to_isbn isbn_to_ean
	INVALID_COUNTRY_CODE INVALID_PUBLISHER_CODE
	BAD_CHECKSUM GOOD_ISBN BAD_ISBN %ERROR_TEXT);

($VERSION)   = q$Revision: 2.1 $ =~ m/(\d+\.\d+)\s*$/;

sub INVALID_COUNTRY_CODE   () { -2 };
sub INVALID_PUBLISHER_CODE () { -3 };
sub BAD_CHECKSUM           () { -1 };
sub GOOD_ISBN              () {  1 };
sub BAD_ISBN               () {  0 };

%ERROR_TEXT = (
	 0 => "Bad ISBN",
	 1 => "Good ISBN",
	-1 => "Bad ISBN checksum",
	-2 => "Invalid country code",
	-3 => "Invalid publisher code",
	);

use Business::ISBN10;
use Business::ISBN13;

sub new
	{
	my $class       = shift;
	my $common_data = _common_format shift;

	my $isbn = do {
		if( length( $common_data ) == 10 )
			{
			Business::ISBN10->new( $common_data );
			}
		elsif( length( $common_data ) == 13 )
			{
			require Business::ISBN10;
			Business::ISBN13->new( $common_data );
			}
		else
			{
			();
			}
		};
		
	return $isbn;
	}
	
#internal function.  you don't get to use this one.
sub _common_format
	{
	#we want uppercase X's
	my $data = uc shift;

	#get rid of everything except decimal digits and X
	$data =~ s/[^0-9X]//g;

	return $1 if $data =~ m/
	        \A   	         #anchor at start
			(\d{9,12}[0-9X])
	        \z	             #anchor at end
	                  /x;

	return;
	}

1;

__END__

=head1 NAME

Business::ISBN - work with International Standard Book Numbers

=head1 SYNOPSIS

	use Business::ISBN;

	$isbn_object = Business::ISBN->new('1565922573');
	$isbn_object = Business::ISBN->new('1-56592-257-3');

	#print the ISBN with hyphens at positions specified
	#by constructor
	print $isbn_object->as_string;

	#print the ISBN with hyphens at specified positions.
	#this not does affect the default positions
	print $isbn_object->as_string([]);

	#print the country code or publisher code
	print $isbn->country_code;
	print $isbn->publisher_code;

	#check to see if the ISBN is valid
	$isbn_object->is_valid;

	#fix the ISBN checksum.  BEWARE:  the error might not be
	#in the checksum!
	$isbn_object->fix_checksum;

	# create an EAN13 barcode in PNG format
	$isbn_object->png_barcode;

	#EXPORTABLE FUNCTIONS

	use Business::ISBN qw( is_valid_checksum
		isbn_to_ean ean_to_isbn );

	#verify the checksum
	if( is_valid_checksum('0123456789')
		eq Business::ISBN::GOOD_ISBN )
		{ ... }

	#convert to EAN (European Article Number)
	$ean = isbn_to_ean('1565921496');

	#convert from EAN (European Article Number)
	$isbn = ean_to_isbn('9781565921498');

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item new($isbn)

The constructor accepts a scalar representing the ISBN.

The string representing the ISBN may contain characters
other than C<[0-9xX]>, although these will be removed in the
internal representation.  The resulting string must look
like an ISBN - the first nine characters must be digits and
the tenth character must be a digit, 'x', or 'X'.

The constructor attempts to determine the country
code and the publisher code.  If these data cannot
be determined, the constructor sets C<$obj-E<gt>is_valid>
to something other than C<GOOD_ISBN>.
An object is still returned and it is up to the program
to check C<$obj-E<gt>is_valid> for one of five values (which
may be exported on demand). The actual values of these
symbolic versions are the same as those from previous
versions of this module which used literal values.


	Business::ISBN::INVALID_PUBLISHER_CODE
	Business::ISBN::INVALID_COUNTRY_CODE
	Business::ISBN::BAD_CHECKSUM
	Business::ISBN::GOOD_ISBN
	Business::ISBN::BAD_ISBN

If you have one of these values and want to turn it into
a string, you can use the %Business::ISBN::ERROR_TEXT hash,
which is exportable by asking for it explicitly in the import
list.

	use Business::ISBN qw(%ERROR_TEXT);

The string passed as the ISBN need not be a valid ISBN as
long as it superficially looks like one.  This allows one to
use the C<fix_checksum()> method.  Despite the disclaimer in
the discussion of that method, the author has found it
extremely useful.  One should check the validity of the ISBN
with C<is_valid()> rather than relying on the return value
of the constructor.  If all one wants to do is check the
validity of an ISBN, one can skip the object-oriented
interface and use the C<is_valid_checksum()> function
which is exportable on demand.

If the constructor decides it cannot create an object, it
returns C<undef>.  It may do this if the string passed as the
ISBN cannot be munged to the internal format meaning that it
does not even come close to looking like an ISBN.

=item isbn

Returns the isbn as a string with no hyphens or other separating
characters.

=item publisher_code

Returns the publisher code or C<undef> if no publisher
code was found.

=item country_code

Returns the country code or C<undef> if no country code
was found.

=item country

Returns the country group (which may not be an actual country
name (e.g. "English")) or C<undef> if no country code
was found.

=item article_code

Returns the article code or C<undef> if no article code
was found

=item checksum

Returns the checksum (last character) or C<undef> if no 
checksum was found or it could not be computed.

=item hyphen_positions

Returns the list of hyphen positions as determined from the
country and publisher codes.  the C<as_string> method provides
a way to temporarily override these positions and to even
forego them altogether.

=item as_string(),  as_string([])

Return the ISBN as a string.  This function takes an
optional anonymous array (or array reference) that specifies
the placement of hyphens in the string.  An empty anonymous array
produces a string with no hyphens. An empty argument list
automatically hyphenates the ISBN based on the discovered
country and publisher codes.  An ISBN that is not valid may
produce strange results.

The positions specified in the passed anonymous array
are only used for one method use and do not replace
the values specified by the constructor. The method
assumes that you know what you are doing and will attempt
to use the least three positions specified.  If you pass
an anonymous array of several positions, the list will
be sorted and the lowest three positions will be used.
Positions less than 1 and greater than 9 are silently
ignored.

A terminating 'x' is changed to 'X'.

=item  is_valid

Returns C<Business::ISBN::GOOD_ISBN> if the checksum is valid and the
country and publisher codes are defined.

Returns C<Business::ISBN::BAD_CHECKSUM> if the ISBN does not pass
the checksum test. The constructor accepts invalid ISBN's so that
they might be fixed with C<fix_checksum>.

Returns C<Business::ISBN::INVALID_COUNTRY_CODE> if a country code
could not be determined (relies on a valid checksum).

Returns C<Business::ISBN::INVALID_PUBLISHER_CODE> if a publisher code
could not be determined (relies on a valid checksum and country code).

Returns C<Business::ISBN::BAD_ISBN> if the string has no hope of ever
looking like a valid ISBN.  This might include strings such as C<"abc">,
C<"123456">, and so on.

=item fix_checksum()

Replace the tenth character with the checksum the
corresponds to the previous nine digits.  This does not
guarantee that the ISBN corresponds to the product one
thinks it does, or that the ISBN corresponds to any product
at all.  It only produces a string that passes the checksum
routine.  If the ISBN passed to the constructor was invalid,
the error might have been in any of the other nine positions.

=item as_ean()

Converts the ISBN to the equivalent EAN (European Article Number).
No pricing extension is added.  Returns the EAN as a string.  This
method can also be used as an exportable function since it checks
its argument list to determine what to do.

=item png_barcode()

Creates a PNG image of the EAN13 barcode which corresponds to the
ISBN. Returns the image as a string.

=item xisbn()

Grabs related ISBNs from Online Computer Library Center (OCLC),
L<http://www.oclc.org> using the xISBN project.

In list context, xisbn() returns a list of ISBNs in
descending order based on OCLC WorldCat holdings, minus the
object's ISBN. In scalar context, xisbn() returns an array
reference of the same list. The ISBNs are simply strings,
not object, for the moment.  This may change later.

Terminating x's are changed to X's so they are consistent with the
rest of the module.

You must have LWP installed (it comes with perl5.8).

=back

=head2 EXPORTABLE FUNCTIONS

Some functions can be used without the object interface.  These
do not use object technology behind the scenes.

=over 4

=item is_valid_checksum('1565921496')

Takes the ISBN string and runs it through the checksum
comparison routine.  Returns C<Business::ISBN::GOOD_ISBN>
if the ISBN is valid, C<Business::ISBN::BAD_CHECKSUM> if the
string looks like an ISBN but has an invalid checksum, and
C<Business::ISBN::BAD_ISBN> if the string does not look like
an ISBN.

=item isbn_to_ean('1565921496')

Takes the ISBN string and converts it to the equivalent
EAN string.  This function checks for a valid ISBN and will return
undef for invalid ISBNs, otherwise it returns the EAN as a string.
Uses as_ean internally, which checks its arguments to determine
what to do.

=item ean_to_isbn('9781565921498')

Takes the EAN string and converts it to the equivalent
ISBN string.  This function checks for a valid ISBN and will return
undef for invalid ISBNs, otherwise it returns the EAN as a string.
Uses as_ean internally, which checks its arguments to determine
what to do.

=back

=head1 BUGS

* The new EAN format has two prefixes for ISBNS (978, 979).  The
isbn_to_ean doesn't know which one to use, so it just uses 978

This module is on Sourceforge at http://perl-isbn.sourceforge.net/.
You can download the lastest CVS source, submit bugs and patches,
and watch the development.  Of course, you can always write directly
to the author. :)

=head1 TO DO

* i would like to create the bar codes with the price extension:
	for now:
	https://www.lightningsource.com/LSISecure/PubResources/CoverSpecsEntry.asp

* the ISBN is expanded to 13 numbers in 2007, but we don't suppor that yetmore t/a

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	http://sourceforge.net/projects/perl-isbn/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2001-2007, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=head1 CREDITS

Thanks to Mark W. Eichin C<< <eichin@thok.org> >> for suggestions and
discussions on EAN support.

Thanks to Andy Lester C<< <andy@petdance.com> >> for lots of bug fixes
and testing.

Ed Summers C<< <esummers@cpan.org> >> has volunteered to help with
this module.

=cut
