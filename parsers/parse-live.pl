#!/usr/bin/perl
#
# format:
# seconds microseconds mcu-micros

use strict;

open(F, "<hz.log") || die $!;
my (@last, $lastnum, $start, @sums, $first, $total, $add, $worst);
my $i = -2;

$|++;
my $last;
while (1)
{

	while (<F>)
	{
		$last .= $_;

		# if we're missing data (still writing to disk), skip and buffer
		if (index($_, "\n") == -1)
		{
			next;
		}

		$_ = $last;
		$last = "";
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
			my $expected = (1/60 * $i/2);
			my $delta = abs($actual-$expected);
			$expected = 0.0000001 if $expected == 0; # prevent divide by 0
			my $daydelta = ((24 * 60 * 60 / $expected) * $delta);

			#print " act=$actual exp=$expected\n" if $daydelta > $worst && $i/2 > 100;
			$worst = $delta if $delta > $worst;# && $i/2 > 15 * 60 * 60;

			printf("\r%d cycles = %0.2fs actual vs %0.2fs expected (%0.2fhr); ∆ = %0.5fs (max %0.2fs); 24 hr ∆ = %0.5fs",
				$i/2, $actual, $expected, $actual / (60 * 60), $delta, $worst, $daydelta
			);
			#print ("\r", $i/2, " cycles = |", (1/60 * $i/2), " secs - $actual secs| = ", abs((1/60 * $i/2) - $actual));
			#print ($i/2, ",$sums[0],$sums[1],$actual,$total,", -($actual-($total/1_000_000)), ",$float,$nums[2]\n");
			@sums = ();
			#print (++$i, ",", ($num - $lastnum), ",", ($nums[2] - $last[2]), "\n" );
		}

		$lastnum = $num;
		@last = @nums;
	}

	# tail -f
	seek(F, 0, 1);
}

__DATA__
1625546324 458163 22230376
1625546324 465282 22237652