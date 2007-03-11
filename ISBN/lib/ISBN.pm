# $Revision: 2.2 $
# $Id: ISBN.pm,v 2.2 2007/03/11 20:17:08 comdog Exp $
package Business::ISBN;
use strict;

use subs qw( 
	_common_format
	INVALID_GROUP_CODE
	INVALID_PUBLISHER_CODE
	BAD_CHECKSUM
	GOOD_ISBN
	BAD_ISBN
	);
use vars qw( $VERSION @ISA @EXPORT_OK %EXPORT_TAGS $debug %group_data
	$MAX_GROUP_CODE_LENGTH %ERROR_TEXT );

use Carp qw(carp croak);
use Exporter qw( import );

use Business::ISBN::Data 1.09; # now a separate module
# ugh, hack
*group_data = *Business::ISBN::country_data;
sub _group_data { $group_data{ $_[1] } }

sub _max_group_code_length  { $Business::ISBN::MAX_COUNTRY_CODE_LENGTH };
sub _max_publisher_code_length  { 
	10 - $_[0]->_group_code_length - 1 - 1;
	};
sub _publisher_ranges
	{	
	my $self = shift;
	[ @{ $self->_group_data( $self->group_code )->[1] } ];
	}

my $debug = 0;

BEGIN {
	@EXPORT_OK = qw(
		INVALID_GROUP_CODE INVALID_PUBLISHER_CODE
		BAD_CHECKSUM GOOD_ISBN BAD_ISBN 
		INVALID_PREFIX
		%ERROR_TEXT);
	%EXPORT_TAGS = ( 
		'all' => \@EXPORT_OK,	
		);
	};
	
($VERSION)   = q$Revision: 2.2 $ =~ m/(\d+\.\d+)\s*$/;

sub INVALID_PREFIX         () { -4 };
sub INVALID_GROUP_CODE     () { -2 };
sub INVALID_PUBLISHER_CODE () { -3 };
sub BAD_CHECKSUM           () { -1 };
sub GOOD_ISBN              () {  1 };
sub BAD_ISBN               () {  0 };

	
%ERROR_TEXT = (
	 0 => "Bad ISBN",
	 1 => "Good ISBN",
	-1 => "Bad ISBN checksum",
	-2 => "Invalid group code",
	-3 => "Invalid publisher code",
	-4 => "Invalid prefix (must be 978 or 979)",
	);

use Business::ISBN10;
#use Business::ISBN13;

sub new
	{
	my $class       = shift;
	my $common_data = _common_format shift;

	return unless $common_data;
	
	my $self = {};
	
	my $isbn = do {
		if( length( $common_data ) == 10 )
			{
			bless $self, 'Business::ISBN10';
			}
		elsif( length( $common_data ) == 13 )
			{
			bless $self, 'Business::ISBN13';
			}
		else
			{
			return BAD_ISBN;
			}
		};

	$self->_init( $common_data );
	$self->_parse_isbn( $common_data );
		
	return $isbn;
	}

sub _init
	{
	my $self = shift;
	my $common_data = shift;
	
	my $class = ref $self =~ m/.*::(.*)/g;
	
	$self->set_type( $class );
	$self->set_isbn( $common_data );

	# we don't know if we have a valid group code yet
	# so let's assume that we don't
	$self->set_is_valid( INVALID_GROUP_CODE );
	}

{
my @methods = (
	[ qw( prefix         ), INVALID_PREFIX         ],
	[ qw( group_code     ), INVALID_GROUP_CODE     ],
	[ qw( publisher_code ), INVALID_PUBLISHER_CODE ],
	[ qw( article_code   ), BAD_ISBN               ],
	[ qw( checksum       ), BAD_CHECKSUM           ],
	);
	
sub _parse_isbn
	{
	my $self = shift;
	
	foreach my $pair ( @methods )
		{
		my( $method, $error_code ) = @$pair;

		my $parser = "_parse_$method";
		my $result = $self->$parser;
		
		unless( defined $result )
			{
			$self->set_is_valid( $error_code );
			#print STDERR "Got bad result for $method [$$self{isbn}]\n";
			return;
			}
			
		$method = "set_$method";
		$self->$method( $result );
		}
	
	$self->set_is_valid( $self->is_valid_checksum );
	
	return $self;
	}
}

sub _parse_group_code
	{
	my $self = shift;
	
	my $trial;  # try this to see what we get
	my $group_code_length = 0;

	my $count = 1;
	
	GROUP_CODE:
	while( defined( $trial= substr($self->isbn, $self->_prefix_length, $count++) ) )
		{
		if( defined $self->_group_data( $trial ) )
			{
			return $trial;
			last GROUP_CODE;
			}

		# if we've past the point of finding a group
		# code we're pretty much stuffed.
		return if $count > $self->_max_group_code_length;
		}
	
	return; #failed if I got this far
	}

sub _parse_publisher_code
	{
	my $self = shift;
	
	my $pairs = $self->_publisher_ranges;

	# get the longest possible publisher code
	# I'll try substrs of this to get the real one
	my $longest = substr(
		$self->isbn, 
		$self->_prefix_length + $self->_group_code_length,
		length( $self->isbn ) 
			- $self->_prefix_length - $self->_group_code_length - 2
		);
	
	#print STDERR "Trying to parse publisher: longest [$longest]\n";
	while( @$pairs )
		{
		my $lower  = shift @$pairs;
		my $upper  = shift @$pairs;
		
		my $trial  = substr( $longest, 0, length $lower ); 
		#print STDERR "Trying [$trial] with $lower <-> $upper [$$self{isbn}]\n";
		
		# this has to be a sring comparison because there are
		# possibly leading 0s
		if( $trial ge $lower and $trial le $upper )
			{
			#print STDERR "Returning $trial\n";
			return $trial;
			}
		
		}
		
	return; #failed if I got this far	
	}
	
sub _parse_article_code
	{
	my $self = shift;
	
	my $head = $self->_prefix_length + 
		$self->_group_code_length + 
		$self->_publisher_code_length;
	my $length = length( $self->isbn ) - $head - 1;
	
	substr( $self->isbn, $head, $length );
	}
	
sub _parse_checksum
	{
	my $self = shift;
	
	substr( $self->isbn, -1, 1 );
	}
	
#it's your fault if you muck with the internals yourself
# none of these take arguments
sub isbn ()                  {   $_[0]->{'isbn'}                              }

sub error                    {   $_[0]->{'valid'}                             }
sub is_valid ()              {   $_[0]->{'valid'} eq GOOD_ISBN                }

sub prefix                   {   $_[0]->{'prefix'}                            }
sub _prefix_length           { length $_[0]->{'prefix'}                       }

sub group_code ()            {   $_[0]->{'group_code'}                        }
sub group()                  {   $_[0]->_group_data( $_[0]->group_code )->[0] }
sub _group_code_length   { 
	length(
		defined $_[0]->{'group_code'} ? $_[0]->{'group_code'} : ''    
		);
	}

sub publisher_code ()        {   $_[0]->{'publisher_code'}                    }
sub _publisher_code_length   { 
	length(
		defined $_[0]->{'publisher_code'} ? $_[0]->{'publisher_code'} : ''    
		);
	}

sub article_code ()          {   $_[0]->{'article_code'}                      }
sub checksum ()              {   $_[0]->{'checksum'}                          }
sub type                     {   $_[0]->{'type'}                              }

sub hyphen_positions ()      { croak "hyphen_positions() must be implemented in Business::ISBN subclass" }


sub set_isbn ()             {   $_[0]->{'isbn'}           = $_[1];   }
sub set_is_valid ()         {   $_[0]->{'valid'}          = $_[1];   }
sub set_prefix ()           {   croak "set_prefix() must be implemented in Business::ISBN subclass" }
sub set_group_code ()       {   $_[0]->{'group_code'}     = $_[1];   }
sub set_group()             {   $_[0]->{'group'}          = $_[1];   }
sub set_publisher_code ()   {   $_[0]->{'publisher_code'} = $_[1];   }
sub set_article_code ()     {   $_[0]->{'article_code'}   = $_[1];   }
sub set_checksum ()         {   $_[0]->{'checksum'}       = $_[1];   }
sub set_type                {   $_[0]->{'type'}           = $_[1];   }

	
#internal function.  you don't get to use this one.
sub _common_format
	{
	#we want uppercase X's
	my $data = uc shift;

	#get rid of everything except decimal digits and X
	$data =~ s/[^0-9X]//g;

	return $1 if $data =~ m/
	        \A   	         #anchor at start
	        (?:97[89])?
			(\d{9}[0-9X])
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
