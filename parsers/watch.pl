#!/usr/bin/perl
#
# monitor AC 60Hz
# determine if it can be used as a clock source
# -samy kamkar

use Time::HiRes;
my $BAUD = 115200;
my $MONITOR = "pmon -b $BAUD";
my $OUTFILE = "hz.log";

open(PMON, "$MONITOR|") || die $!;
open(OUT, ">$OUTFILE") || die $!;

while (<PMON>)
{
	my ($s, $us) = Time::HiRes::gettimeofday();
	print OUT "$s $us $_";
}
close(OUT);