#!/usr/local/bin/perl

use lib qw(blib/lib);

use Business::ISBN;

@ARGV = @ARGV || qw( 
	0-679-75493-8 
	1-56592-243-3 
	1-861002-96-3
	0-7645-4716-X 
	1-861002-96-4 
	);

my %err_str = (
        Business::ISBN::BAD_CHECKSUM            => "Bad checksum",
        Business::ISBN::INVALID_COUNTRY_CODE    => "Invalid country code",
        Business::ISBN::INVALID_PUBLISHER_CODE  => "Invalid publisher
code",
        Business::ISBN::GOOD_ISBN               => "GOOD",
        );

for my $test ( @ARGV ) 
	{
	print "\n$test --> should be ", Business::ISBN::_checksum($test), "\n";

	my $isbn = new Business::ISBN( $test ) or print "$test --> bad\n", next;
	$rc = $isbn->is_valid();
	$stat = $err_str{$rc};
	print "via is_valid          --> $stat\n";
	}

