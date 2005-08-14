use Test::More tests => 7;

use Business::ISBN;

my $GOOD_ISBN          = "9992701579";
my $GOOD_ISBN_STRING   = "99927-0-157-9";
my $COUNTRY            = "Albania";
my $COUNTRY_CODE       = "99927";
my $PUBLISHER          = "0";

# test to see if we can construct an object?
my $isbn = Business::ISBN->new( $GOOD_ISBN );
isa_ok( $isbn, 'Business::ISBN' );
is( $isbn->is_valid, Business::ISBN::GOOD_ISBN, "$GOOD_ISBN is valid" );

is( $isbn->publisher_code, $PUBLISHER,          "$GOOD_ISBN has right publisher");
is( $isbn->country_code,   $COUNTRY_CODE,       "$GOOD_ISBN has right country code");
is( $isbn->country,        $COUNTRY,            "$GOOD_ISBN has right country");
is( $isbn->as_string,      $GOOD_ISBN_STRING,   "$GOOD_ISBN stringifies correctly");
is( $isbn->as_string([]),  $GOOD_ISBN,          "$GOOD_ISBN stringifies correctly");
