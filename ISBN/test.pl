# $Revision: 1.1 $
# $Id: test.pl,v 1.1 2001/08/13 06:38:02 comdog Exp $
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $^W = 1; $test = 1; $| = 1; print "1..19\n"; }
END {print "not ok 1\n" unless $loaded;}
use Business::ISBN;
$loaded = 1;
&print_ok;

my $VERBOSE = $ENV{ISBN_DEBUG};

sub print_ok { print "ok ", $test++, "\n"; }

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $GOOD_ISBN          = "1565922573";
my $GOOD_ISBN_STRING   = "1-56592-257-3";
my $GOOD_EAN           = "9781565922570";
my $COUNTRY            = "1";
my $PUBLISHER          = "56592";
my $BAD_CHECKSUM_ISBN  = "1565922572";
my $BAD_COUNTRY_ISBN   = "9990122572";
my $BAD_PUBLISHER_ISBN = "1456922572";
my $NULL_ISBN          = undef;
my $NO_GOOD_CHAR_ISBN  = "abcdefghij";
my $SHORT_ISBN         = "156592";

# test to see if we can construct an object?
{
my $isbn = Business::ISBN->new( $GOOD_ISBN );

print "not " unless ref $isbn;
print "not " unless ( ref $isbn 
	and $isbn->is_valid eq Business::ISBN::GOOD_ISBN );
print_ok;

print "not " unless ( $isbn->publisher_code eq $PUBLISHER );
print_ok;

print "not " unless ( $isbn->country_code eq $COUNTRY );
print_ok;
}

# can we make strings correctly?
{
my $isbn = Business::ISBN->new( $GOOD_ISBN );

my $string = $isbn->as_string;
print "not " unless $string eq $GOOD_ISBN_STRING;
print_ok;

$string = $isbn->as_string([]);
print "not " unless $string eq $GOOD_ISBN;
print_ok;
} 

# and bad checksums?
{
my $isbn = Business::ISBN->new( $BAD_CHECKSUM_ISBN );

print STDERR "valid is ", $isbn->is_valid, "\n" if $VERBOSE;

print "not " unless ref $isbn;
print "not " if ( ref $isbn and 
	$isbn->is_valid != Business::ISBN::BAD_CHECKSUM );
print_ok;

#after this we should have a good ISBN
$isbn->fix_checksum;

print "not " unless $isbn->is_valid eq Business::ISBN::GOOD_ISBN;
print_ok;
}

# bad country code?
{
my $isbn = Business::ISBN->new( $BAD_COUNTRY_ISBN );

print "not " unless ref $isbn;
print "not " if ( ref $isbn and
	$isbn->is_valid != Business::ISBN::INVALID_COUNTRY_CODE );
print_ok;
print STDERR "is_valid is ", $isbn->is_valid, "\n" if $VERBOSE;
print STDERR "country is ", $isbn->country_code, "\n" if $VERBOSE;
print "not " if defined $isbn->country_code;
print_ok;
}

# bad publisher code?
{
my $isbn = Business::ISBN->new( $BAD_PUBLISHER_ISBN );

print "not " unless ref $isbn;
print "not " if ( ref $isbn and
	$isbn->is_valid != Business::ISBN::INVALID_PUBLISHER_CODE );
print_ok;
print STDERR "is valid is ", $isbn->is_valid, "\n" if $VERBOSE;
print STDERR "publisher is ", $isbn->publisher_code, "\n" if $VERBOSE;

print "not " if defined $isbn->publisher_code;
print_ok;
}

# convert to EAN?
{
my $isbn = Business::ISBN->new( $GOOD_ISBN );

print "not " unless $isbn->as_ean eq $GOOD_EAN;
print_ok;
}

# do exportable functions do the right thing?
{
my $SHORT_ISBN = $GOOD_ISBN;
chop $SHORT_ISBN;

my $valid = Business::ISBN::is_valid_checksum( $SHORT_ISBN );

print "not " unless $valid eq Business::ISBN::BAD_ISBN;
print_ok;

$valid = Business::ISBN::is_valid_checksum( $GOOD_ISBN );

print "not " unless $valid eq Business::ISBN::GOOD_ISBN;
print_ok;

$valid = Business::ISBN::is_valid_checksum( $BAD_CHECKSUM_ISBN );

print "not " unless $valid eq Business::ISBN::BAD_CHECKSUM;
print_ok;

# the following three tests check is_valid_checksum's behaviour
# with bad data.
$valid = Business::ISBN::is_valid_checksum( $NULL_ISBN );

print "not " unless $valid eq Business::ISBN::BAD_ISBN;
print_ok;

$valid = Business::ISBN::is_valid_checksum( $NO_GOOD_CHAR_ISBN );

print "not " unless $valid eq Business::ISBN::BAD_ISBN;
print_ok;

$valid = Business::ISBN::is_valid_checksum( $SHORT_ISBN );
 
print "not " unless $valid eq Business::ISBN::BAD_ISBN;
print_ok;

}

