# $Revision: 1.1 $

use Test::More tests => 21;

use Business::ISBN;

my $GOOD_ISBN          = "1565922573";
my $GOOD_ISBN_STRING   = "1-56592-257-3";
my $GOOD_EAN           = "9781565922570";
my $COUNTRY            = "1";
my $PUBLISHER          = "56592";
my $BAD_CHECKSUM_ISBN  = "1565922572";
my $BAD_COUNTRY_ISBN   = "9990222576";
my $BAD_PUBLISHER_ISBN = "1456922572";
my $NULL_ISBN          = undef;
my $NO_GOOD_CHAR_ISBN  = "abcdefghij";
my $SHORT_ISBN         = "156592";

# test to see if we can construct an object?
my $isbn = Business::ISBN->new( $GOOD_ISBN );
isa_ok( $isbn, 'Business::ISBN' );
is( $isbn->is_valid, Business::ISBN::GOOD_ISBN, "$GOOD_ISBN is valid" );
is( $isbn->publisher_code, $PUBLISHER, "$GOOD_ISBN has right publisher");
is( $isbn->country_code, $COUNTRY, "$GOOD_ISBN has right country");
is( $isbn->as_string, $GOOD_ISBN_STRING, "$GOOD_ISBN stringifies correctly");
is( $isbn->as_string([]), $GOOD_ISBN, "$GOOD_ISBN stringifies correctly");

# and bad checksums?
$isbn = Business::ISBN->new( $BAD_CHECKSUM_ISBN );
isa_ok( $isbn, 'Business::ISBN' );
is( $isbn->is_valid, Business::ISBN::BAD_CHECKSUM, 
	"$BAD_CHECKSUM_ISBN is invalid" );

#after this we should have a good ISBN
$isbn->fix_checksum;
is( $isbn->is_valid, Business::ISBN::GOOD_ISBN, 
	"$BAD_CHECKSUM_ISBN had checksum fixed" );

# bad country code?
$isbn = Business::ISBN->new( $BAD_COUNTRY_ISBN );
isa_ok( $isbn, 'Business::ISBN' );
is( $isbn->is_valid, Business::ISBN::INVALID_COUNTRY_CODE, 
	"$BAD_COUNTRY_ISBN is invalid" );

# bad publisher code?
$isbn = Business::ISBN->new( $BAD_PUBLISHER_ISBN );
isa_ok( $isbn, 'Business::ISBN' );
is( $isbn->is_valid, Business::ISBN::INVALID_PUBLISHER_CODE, 
	"$BAD_PUBLISHER_ISBN is invalid" );

# convert to EAN?
$isbn = Business::ISBN->new( $GOOD_ISBN );
is( $isbn->as_ean, $GOOD_EAN, "$GOOD_ISBN converted to EAN" );

# do exportable functions do the right thing?
{
my $SHORT_ISBN = $GOOD_ISBN;
chop $SHORT_ISBN;

my $valid = Business::ISBN::is_valid_checksum( $SHORT_ISBN );
is( $valid, Business::ISBN::BAD_ISBN, "Catch short ISBN string" );
}

is( Business::ISBN::is_valid_checksum( $GOOD_ISBN ),
	Business::ISBN::GOOD_ISBN, 'is_valid_checksum with good ISBN' );
is( Business::ISBN::is_valid_checksum( $BAD_CHECKSUM_ISBN ),
	Business::ISBN::BAD_CHECKSUM, 'is_valid_checksum with bad checksum ISBN' );
is( Business::ISBN::is_valid_checksum( $NULL_ISBN ),
	Business::ISBN::BAD_ISBN, 'is_valid_checksum with bad ISBN' );
is( Business::ISBN::is_valid_checksum( $NO_GOOD_CHAR_ISBN ),
	Business::ISBN::BAD_ISBN, 'is_valid_checksum with no good char ISBN' );
is( Business::ISBN::is_valid_checksum( $SHORT_ISBN ),
	Business::ISBN::BAD_ISBN, 'is_valid_checksum with short ISBN' );


SKIP:
	{
	open FILE, "isbns.txt" or 
		skip( "Could not read $file: $!", 1, 'Need isbns.txt');

	print STDERR "\nChecking ISBNs... (this may take a bit)\n";
	
	my $bad = 0;
	while( <FILE> )
		{
		chomp;
		my $isbn = Business::ISBN->new( $_ );
		
		my $result = $isbn->is_valid;
		$bad++ unless $result eq Business::ISBN::GOOD_ISBN;
		print STDERR "$_ is not valid? [$result]\n" 
			unless $result eq Business::ISBN::GOOD_ISBN;	
		}
	
	close FILE;
	
	ok( $bad == 0, "Match ISBNs" );
	}
