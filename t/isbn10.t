# $Revision: 2.2 $
use strict;

use Test::More 'no_plan';

use Business::ISBN qw(:all);

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
my $GOOD_ISBN          = "1565922573";
my $GOOD_ISBN_STRING   = "1-56592-257-3";
my $GOOD_EAN           = "9781565922570";
my $COUNTRY            = "English";
my $GROUP_CODE         = "1";
my $PUBLISHER          = "56592";

my $BAD_CHECKSUM_ISBN  = "1565922572";

my $BAD_GROUP_ISBN     = "9990222576";

my $BAD_PUBLISHER_ISBN = "9165022222"; # 91-650-22222-?  Sweden (stops at 649)

my $NULL_ISBN          = undef;

my $NO_GOOD_CHAR_ISBN  = "abcdefghij";

my $SHORT_ISBN         = "156592";


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# test to see if we can construct an object?
my $isbn = Business::ISBN->new( $GOOD_ISBN );
isa_ok( $isbn, 'Business::ISBN10' );
is( $isbn->is_valid, Business::ISBN10::GOOD_ISBN, "$GOOD_ISBN is valid" );

is( $isbn->publisher_code, $PUBLISHER,        "$GOOD_ISBN has right publisher");
is( $isbn->group_code,     $GROUP_CODE,       "$GOOD_ISBN has right country code");
is( $isbn->group,          $COUNTRY,          "$GOOD_ISBN has right country");
is( $isbn->as_string,      $GOOD_ISBN_STRING, "$GOOD_ISBN stringifies correctly");
is( $isbn->as_string([]),  $GOOD_ISBN,        "$GOOD_ISBN stringifies correctly");



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# and bad checksums?
$isbn = Business::ISBN->new( $BAD_CHECKSUM_ISBN );
isa_ok( $isbn, 'Business::ISBN10' );
is( $isbn->error, BAD_CHECKSUM, 
	"Bad checksum [$BAD_CHECKSUM_ISBN] is invalid" );

#after this we should have a good ISBN
$isbn->fix_checksum;
ok( $isbn->is_valid, 
	"Bad checksum [$BAD_CHECKSUM_ISBN] had checksum fixed" );

# bad country code?
$isbn = Business::ISBN->new( $BAD_GROUP_ISBN );
isa_ok( $isbn, 'Business::ISBN10' );
is( $isbn->error, INVALID_GROUP_CODE, 
	"Bad group code [$BAD_GROUP_ISBN] is invalid" );

# bad publisher code?
$isbn = Business::ISBN->new( $BAD_PUBLISHER_ISBN );
isa_ok( $isbn, 'Business::ISBN10' );
is( $isbn->error, INVALID_PUBLISHER_CODE, 
	"Bad publisher [$BAD_PUBLISHER_ISBN] is invalid" );

# convert to EAN?
$isbn = Business::ISBN->new( $GOOD_ISBN );
is( $isbn->as_ean, $GOOD_EAN, "$GOOD_ISBN converted to EAN" );

=pod

# do exportable functions do the right thing?
{
my $SHORT_ISBN = $GOOD_ISBN;
chop $SHORT_ISBN;

my $valid = Business::ISBN10::is_valid_checksum( $SHORT_ISBN );
is( $valid, Business::ISBN10::BAD_ISBN, "Catch short ISBN string" );
}


TODO: {
	local $TODO = "not implemented";
eval {
is( Business::ISBN10::is_valid_checksum( $GOOD_ISBN ),
	Business::ISBN10::GOOD_ISBN, 'is_valid_checksum with good ISBN' );
is( Business::ISBN10::is_valid_checksum( $BAD_CHECKSUM_ISBN ),
	Business::ISBN10::BAD_CHECKSUM, 'is_valid_checksum with bad checksum ISBN' );
is( Business::ISBN10::is_valid_checksum( $NULL_ISBN ),
	Business::ISBN10::BAD_ISBN, 'is_valid_checksum with bad ISBN' );
is( Business::ISBN10::is_valid_checksum( $NO_GOOD_CHAR_ISBN ),
	Business::ISBN10::BAD_ISBN, 'is_valid_checksum with no good char ISBN' );
is( Business::ISBN10::is_valid_checksum( $SHORT_ISBN ),
	Business::ISBN10::BAD_ISBN, 'is_valid_checksum with short ISBN' );
}
}

=cut

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SKIP:
	{
	my $file = "isbns.txt";

	open FILE, $file or 
		skip( "Could not read $file: $!", 1, "Need $file");

	print STDERR "\nChecking ISBNs... (this may take a bit)\n";
	
	my $bad = 0;
	while( <FILE> )
		{
		chomp;
		my $isbn = Business::ISBN->new( $_ );
		
		my $result = $isbn->is_valid;
		my $text   = $Business::ISBN::ERROR_TEXT{ $result };
		
		$bad++ unless $result eq Business::ISBN::GOOD_ISBN;
		print STDERR "$_ is not valid? [ $result -> $text ]\n" 
			unless $result eq Business::ISBN::GOOD_ISBN;	
		}
	
	close FILE;
	
	ok( $bad == 0, "Match good ISBNs" );
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
SKIP:
	{
	my $file = "bad-isbns.txt";

	open FILE, $file or 
		skip( "Could not read $file: $!", 1, "Need $file");

	print STDERR "\nChecking bad ISBNs... (this should be fast)\n";
	
	my $good = 0;
	my @good = ();
	
	while( <FILE> )
		{
		chomp;
		my $valid = eval { Business::ISBN->new( $_ )->is_valid };
		next unless $valid;
		
		push @good, $_;
		
		$good++;	
		}
	
	close FILE;

	{
	local $" = "\n\t";
	ok( $good == 0, "Don't match bad ISBNs" ) || 
		diag( "Matched $good bad ISBNs\n\t@good\n" );
	}
	
	}