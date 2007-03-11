# $Revision: 2.2 $
# $Id: ISBN10.pm,v 2.2 2007/03/11 20:17:08 comdog Exp $
package Business::ISBN10;
use strict;
use base qw(Business::ISBN);

use Business::ISBN qw(:all);
use Data::Dumper;

use subs qw( 
	_checksum is_valid_checksum
	INVALID_GROUP_CODE
	INVALID_PUBLISHER_CODE
	BAD_CHECKSUM
	GOOD_ISBN
	BAD_ISBN
	);

use vars qw( 
	$VERSION 
	$debug 
	$MAX_GROUP_CODE_LENGTH 
	%ERROR_TEXT 
	);

use Carp qw(carp croak cluck);

my $debug = 0;

($VERSION)   = q$Revision: 2.2 $ =~ m/(\d+\.\d+)\s*$/;

sub _parse_prefix { '' }
sub set_prefix   
	{ 
	croak "Cannot set prefix [$_[1]] on an ISBN-10" if length $_[1];
	
	$_[0]->{prefix} = $_[1];
	}

sub hyphen_positions () { 
	[
	$_[0]->_group_code_length,
	$_[0]->_group_code_length + $_[0]->_publisher_code_length,
	9
	]
	}

sub fix_checksum
	{
	my $self = shift;

	my $last_char = substr($self->isbn, 9, 1);
	my $checksum = $self->_checksum;

	my $isbn = $self->isbn;
	substr($isbn, 9, 1) = $checksum;

	$self->set_isbn( $isbn );
	$self->set_checksum( $checksum );

	$self->_check_validity;

	return 0 if $last_char eq $checksum;
	return 1;
	}

sub as_string
	{
	my $self      = shift;
	my $array_ref = shift;

	#this allows one to override the positions settings from the
	#constructor
	$array_ref = $self->hyphen_positions unless ref $array_ref eq  ref [];

#	print STDERR Data::Dumper->Dump( [$array_ref], [qw(array_ref)] );
#	print STDERR Data::Dumper->Dump( [$self], [qw(self)] );
	
	return unless $self->is_valid eq GOOD_ISBN;
	my $isbn = $self->isbn;

	foreach my $position ( sort { $b <=> $a } @$array_ref )
		{
		next if $position > 9 or $position < 1;
		substr($isbn, $position, 0) = '-';
		}

	return $isbn;
	}

sub as_ean
	{
	my $self = shift;

	my $isbn = ref $self ? $self->as_string([]) : $self->_common_format;

	return unless ( defined $isbn and length $isbn == 10 );

	my $ean = '978' . substr($isbn, 0, 9);

	my $sum = 0;
	foreach my $index ( 0, 2, 4, 6, 8, 10 )
		{
		$sum +=     substr($ean, $index, 1);
		$sum += 3 * substr($ean, $index + 1, 1);
		}

	#take the next higher multiple of 10 and subtract the sum.
	#if $sum is 37, the next highest multiple of ten is 40. the
	#check digit would be 40 - 37 => 3.
	$ean .= ( 10 * ( int( $sum / 10 ) + 1 ) - $sum ) % 10;

	return $ean;
	}

sub is_valid_checksum
	{
	my $self = shift;
	
	cluck "is_valid_checksum: Didn't get object!" unless ref $self;
	
	return GOOD_ISBN if $self->checksum eq $self->_checksum;

	return BAD_CHECKSUM;
	}

sub ean_to_isbn
	{
	my $ean = shift;

	$ean =~ s/[^0-9]//g;

	return unless length $ean == 13;
	return unless substr($ean, 0, 3) =~ /97[98]/;

	my $isbn = new Business::ISBN( substr($ean, 3, 9) . '1' );

	$isbn->fix_checksum;

	return $isbn->as_string([]) if $isbn->is_valid;

	return;
	}


sub isbn_to_ean
	{
	my $isbn = $_[0]->_common_format;

	return unless (defined $isbn and is_valid_checksum($isbn) eq GOOD_ISBN);

	return as_ean($isbn);
	}

sub png_barcode
	{
	my $self = shift;

	my $ean = isbn_to_ean( $self->as_string([]) );

	eval "use GD::Barcode::EAN13";
	if( $@ )
		{
		carp "Need GD::Barcode::EAN13 to use png_barcode!";
		return;
		}

	my $image = GD::Barcode::EAN13->new($ean)->plot->png;

	return $image;
	}

sub xisbn
	{
	my $self = shift;

	my $data = $self->_get_xisbn;
	$data =~ tr/x/X/;

	my @isbns = $data =~ m|<isbn>(.*?)</isbn>|ig;
	shift @isbns;
	wantarray ? @isbns : \@isbns;
	}

sub _get_xisbn
	{
	my $self = shift;

	eval "use LWP::Simple";
	if( $@ ) { carp "You need LWP::Simple to use xisbn()"; return; }

	my $data = LWP::Simple::get( $self->_xisbn_url );

	carp "Could not fetch xISBN data" unless defined $data;

	return $data;
	}

sub _xisbn_url
	{
	my $self = shift;
	my $isbn = $self->as_string([]);

	return "http://labs.oclc.org/xisbn/$isbn";
	}

#internal function.  you don't get to use this one.
sub _check_validity
	{
	my $self = shift;

	if( $self->is_valid_checksum  eq GOOD_ISBN and
		defined $self->group_code
	    and defined $self->publisher_code )
	    {
	    $self->set_is_valid( GOOD_ISBN );
	    }
	else
		{
		$self->set_is_valid( INVALID_PUBLISHER_CODE )
			unless defined $self->publisher_code;
		$self->set_is_valid( INVALID_GROUP_CODE )
			unless defined $self->group_code;
		$self->set_is_valid( GOOD_ISBN )
			 unless $self->is_valid_checksum ne GOOD_ISBN;
		}
	}

#internal function.  you don't get to use this one.
sub _checksum
	{
	my $data = $_[0]->isbn;

	return unless defined $data;

	my @digits = split //, $data;
	my $sum    = 0;

	foreach( reverse 2..10 )
		{
		$sum += $_ * (shift @digits);
		}

	#return what the check digit should be
	my $checksum = (11 - ($sum % 11))%11;

	$checksum = 'X' if $checksum == 10;

	return $checksum;
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

	#print the group code or publisher code
	print $isbn->group_code;
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

The constructor attempts to determine the group
code and the publisher code.  If these data cannot
be determined, the constructor sets C<$obj-E<gt>is_valid>
to something other than C<GOOD_ISBN>.
An object is still returned and it is up to the program
to check C<$obj-E<gt>is_valid> for one of five values (which
may be exported on demand). The actual values of these
symbolic versions are the same as those from previous
versions of this module which used literal values.


	Business::ISBN::INVALID_PUBLISHER_CODE
	Business::ISBN::INVALID_GROUP_CODE
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

=item group_code

Returns the group code or C<undef> if no group code
was found.

=item group

Returns the group group (which may not be an actual group
name (e.g. "English")) or C<undef> if no group code
was found.

=item article_code

Returns the article code or C<undef> if no article code
was found

=item checksum

Returns the checksum (last character) or C<undef> if no 
checksum was found or it could not be computed.

=item hyphen_positions

Returns the list of hyphen positions as determined from the
group and publisher codes.  the C<as_string> method provides
a way to temporarily override these positions and to even
forego them altogether.

=item as_string(),  as_string([])

Return the ISBN as a string.  This function takes an
optional anonymous array (or array reference) that specifies
the placement of hyphens in the string.  An empty anonymous array
produces a string with no hyphens. An empty argument list
automatically hyphenates the ISBN based on the discovered
group and publisher codes.  An ISBN that is not valid may
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
group and publisher codes are defined.

Returns C<Business::ISBN::BAD_CHECKSUM> if the ISBN does not pass
the checksum test. The constructor accepts invalid ISBN's so that
they might be fixed with C<fix_checksum>.

Returns C<Business::ISBN::INVALID_GROUP_CODE> if a group code
could not be determined (relies on a valid checksum).

Returns C<Business::ISBN::INVALID_PUBLISHER_CODE> if a publisher code
could not be determined (relies on a valid checksum and group code).

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
