#!/usr/bin/perl
#
# format:
# seconds microseconds mcu-micros
#
# -samy kamkar
#
# ./parse.pl
# ./parse.pl hz.log
# zcat ../logs/hz.log.2.gz | ./parse.pl

use strict;

# no data piped in, use file
if (-t STDIN)
{
	my ($log) = shift || ($0 =~ m|(.*/)[^/]+$|) . "../logs/hz.log";
	#my ($log) = ($0 =~ m|(.*/)[^/]+$|);
	print"log=$log\n";

	open(F, "<", $log) || die $!;
}
else
{
	*F = *STDIN;
}
my (@last, $lastnum, $start, $i, @sums, $first, $total, $add);
my $max = 0;
my $min = ~0;

while (<F>)
{
	next if $. <= 3;
	s/\r$//;
	#print;
	chomp;

	my @nums = split(' ');
	my $float = sprintf("$nums[0].%06d", $nums[1]);
	my $num = int($float * 1_000_000);

	# unsigned long overflow
	$nums[2] += $add;
	if ($nums[2] < $last[2])
	{
		$add += 2**32;
		#print "adding\n";
	}

	$start = ($num - $nums[2]) if !$start;
	$num -= $start;

		
	#print "$num,$nums[2]\n";
	$sums[0] += ($num - $lastnum);
	$sums[1] += ($nums[2] - $last[2]);

	# first time on computer
	#$total = $total ? ($total + $nums[2]) : $float;
	if (++$i % 2 == 0)
	{
		$total += $sums[1];
		$first = $float if !$first;
		my $actual = $float - $first;

		my $delta = ((1/60 * $i/2) - $actual);
		$min = $delta if $delta < $min;
		$max = $delta if $delta > $max;
		print ("\r", $i/2, " cycles = |", (1/60 * $i/2), " secs - $actual secs| = ", abs($delta));
		#print ("\r", $i/2, " cycles = |", (1/60 * $i/2), " secs - $actual secs| = ", abs((1/60 * $i/2) - $actual));
		#print ($i/2, ",$sums[0],$sums[1],$actual,$total,", -($actual-($total/1_000_000)), ",$float,$nums[2]\n");
		@sums = ();
		#print (++$i, ",", ($num - $lastnum), ",", ($nums[2] - $last[2]), "\n" );
	}

	$lastnum = $num;
	@last = @nums;
}

print "\n";
print "min: $min\n";
print "max: $max\n";

__DATA__
1625546324 458163 22230376
1625546324 465282 22237652