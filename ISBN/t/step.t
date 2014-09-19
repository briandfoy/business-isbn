use Test::More 0.95;
use Test::ISBN;

use strict;
use warnings;

my $class       = 'Business::ISBN';
my @methods     = qw( increment decrement _step_article_code );
my $isbn_string = '978-1-4493-9311-3'; # Mastering Perl

my $isbn;

subtest setup => sub {
	use_ok( $class );
	can_ok( $class, @methods );
	isbn_ok( $isbn_string );
	};

subtest make_isbn => sub {
	$isbn = $class->new( $isbn_string );
	isa_ok( $isbn, $class );
	can_ok( $class, @methods );	
	};

subtest one_more => sub {
	my $isbn     = $class->new( '978-1-4493-9311-3' );
	isbn_ok( $isbn );
	my $one_more = $class->new( '978-1-4493-9312-3' );
	isbn_ok( $one_more );

	my $isbn_one_more = $isbn->increment;
	isbn_ok( $isbn_one_more );
	
	is( $one_more->as_string, $isbn_one_more->as_string, 'One more matches' );
	};


subtest one_less => sub {
	my $isbn     = $class->new( '978-1-4493-9311-3' );
	isbn_ok( $isbn );
	my $one_less = $class->new( '978-1-4493-9310-3' );
	isbn_ok( $one_less );

	my $isbn_one_less = $isbn->increment;
	isbn_ok( $isbn_one_less );
	
	is( $one_less->as_string, $isbn_one_less->as_string, 'One more matches' );
	};

done_testing();
