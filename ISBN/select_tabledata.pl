#!/bin/perl
#
#	Extract table date from www.isbn-international.org/converter/ranges.htm
#	and create perl hash array for usage in Business::ISBN::Data
#
   use HTML::TableExtract;

   my ($infile, $outfile) = @ARGV;

   open (FPI, $infile)      || die "Can't open $infile";
   open (FPO, "> $outfile") || die "Can't open $outfile";

   my @lines = <FPI>;
   my $text  = join "", @lines;
   my $te    = new HTML::TableExtract ();
#  headers => [ "Group Number", "Valid Publisher Numbers"]);
   $te->parse ($text);

   foreach $ts ($te->table_states) {
      foreach $row ($ts->rows) {
	 next if ($row->[0] =~ /Group/);
	 @range = split /\n/, $row->[2];
	 next if ($#range < 0);
	 $row->[1] =~ s/\'//g;
	 $row->[1] =~ s/speaking area//;
	 $row->[1] =~ s/\s+$//;
	 printf FPO "%5s => [ '%s', [ ", $row->[0], $row->[1];
	 foreach $r (@range) {
	    ($from, $to) = split / - /, $r;
	    printf FPO "'%s' => '%s', ", $from, $to;
	  }
	 printf FPO "] ],\n";
       }
    }

   close FPI;
   close FPO;
