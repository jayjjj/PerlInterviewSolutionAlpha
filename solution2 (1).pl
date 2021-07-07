#!/user/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

#This problem can be generalized as how to handle the simplest unit: the innermost
#parentheses, the base unit, similar to: ( operand operator operand ...)
#For simplicity, P-> parentheses, OP->Operator, OPf->Op in front of the P,
#				 OPt->Op trailing P, OPx->Op in the base unit: x OP y
#
# There are several cases to consider:
# a. OPf is + and OPt is * or /, P cannot be removed.
# b. OPf is - and OPx is + or -, P cannot be removed.
# c. OPf is * and OPx is + or -, P cannot be removed.
# d. OPf is /, P cannot be removed.
# e. P can be removed in all the other cases.
#
# Or we can think it this way:
# A. OPf is + and OPt is + or -, P can be removed.
# B. OPf is - and OPx is not + or - (ie.* or / only), P can be removed.
# C. OPf is * and OPx is not + or - (ie * or / only), P can be removed.
# D. P cannot be removed in all the other cases.
#
#Once the base unit is handled, the whole expression can be handled recursively.

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#The above note is written before I started to code. Now I realize that I have to
#to handle '-' as negation instead of the minus operator '-'. More notes are written
#as the comment within the code. The above logic is no longer valid.
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

print "Input the expression to remove P:";

my ($expression, $len);

while (1) {
	while ($expression = <STDIN>) {
		chomp $expression;	
		$expression =~ s/\s+//g;
		
		my $count1 = () = $expression =~ /\(/g;
		my $count2 = () = $expression =~ /\)/g;

		last if($count1 == $count2);
		print "\nNumber of '(' & ')' unmatches. Please retry:";
	}

	$len = length($expression);	
	print 'After removal:', process();
	
	print "\nInput next one to process(Enter to exit): ";
}

sub process {
	
	exit unless ($expression);	
	
	solve(0);
	
	$expression =~ s/\s//g;
	return $expression;
}

sub solve {
	my $index = shift;
	
	my ($left, $right);
	while ($index < $len) {
		my $ch = substr($expression, $index, 1);
		return $index if ($ch eq ')');
		
		if($ch eq '(') {
			$left = $index;
			$right = solve($index + 1);
			$index = $right;
			if(pcheck($left, $right)){
				substr($expression, $left, 1, ' ');
				substr($expression, $right, 1, ' ');
			}
		}
		$index++;
	}
}

sub pcheck{
	my ($left, $right) = @_;
	
	return 1 if ($right - $left < 2); #empty parentheses or only a char inside
	
	#'+' & ' ' is used as a convenience since '+' have no effect on P removal.
	my $OPf = ($left)? substr($expression, $left-1, 1) : ' ';
	$OPf = ' ' if $OPf eq '(';
	my $OPt = ($right < $len - 1)? substr($expression, $right+1, 1) : '+';
	$OPt = '+' if $OPt eq ')';
	
	
	my $nextchar = substr($expression, $left+1, 1);	
	return 1 if(($OPf eq '+') && ($OPt eq '+' or $OPt eq '-') && ($nextchar ne '-'));
	return 1 if(($OPf eq ' ') && ($OPt eq '+' or $OPt eq '-'));
	
	my $base = substr($expression, $left, $right - $left + 1);
	
	#Have to go through $base to make sure if '-' found here is operators or not.
	#Since $base is enclosed with (), no overflow when seeking for '-';
	#We do not accept expression as 3+-2, a--1. This is to say, if '*', '/' or
	#'(' is followed by '-', this '-' is not an operator.
	# 3*-5, 3/-5+(2+1): those are the 2 cases of allowed negations.
	#Please be aware, with a+(-3/5+2)+1, the P is regarded necessary and will stay.
	
	#If we want to handle case like 3+(3/+5), we can do the same with '+' 
	#as we do towards '-'.
	#For now, we don't handle this case though it can be done easily.
	
	if ( $OPf ne '/' ){
		my $offset = 0;
		my $flag = 0;
		my $ind = index($base, '-');
		while ($ind != -1) {
			my $i = 1;
			my $c = substr($base, $ind - $i, 1);
			#$c might be ' ' if this place was P removed just now.
			while ($c eq ' ') {
				$i += 1;
				$c = substr($base, $ind - $i, 1);
			}
			
			#print Dumper "left: $left, right: $right, opf: $OPf, opt: $OPt, Char: $c";
			
			$flag = 1 if (($c ne '/') && ($c ne '*') && (($OPf eq '-') or ($OPf eq '+')));
			$flag = 1 if (($c ne '/') && ($c ne '*') && ($c ne '(') && (($OPf eq '*') or ($OPf eq ' ')));			
			
			last if($flag);
			$offset = $ind + 1;
			$ind = index($base, '-', $offset);
		}
		return 1 if (($base !~ /\+/) && !$flag);
    }
	return 0;
}
