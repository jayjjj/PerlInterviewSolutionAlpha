#!/user/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

#This problem can be started with the innermost parentheses, the base unit, similar to: 
#( operand1 operator1 operand2 [operator2] [operand3] ...)
#
#For simplicity, 	P:		parentheses,
#				 	OP:		Operator, 
#					OPf:	OP in front of the P,
#				 	OPt:	Op trailing P, 
#					OPx:	Op within the base unit: x OPx y
#
# Assumption: '-' can be used as OP and negation symble while '+' is OP only.
#
# We can generalize this problem this way:
# A. OPf is + and OPt is + or -, P can be removed, unless the first element is negative.
# B. OPf is - and OPx is not + or - (ie.* or / only), P can be removed, unless the first operant is negative
# C. OPf is * and OPx is not + or - (ie * or / only), P can be removed.
# D. P cannot be removed in all the other cases. (!!!Wrong!!!. See the comment in the code, line 120)
#
#Once the base unit is handled, the whole expression can be handled recursively.

my ($expression, $len);

while ($expression = <DATA>) {
	chomp $expression;	
	$expression =~ s/\s+//g;	#remove possible spaces globally
	
	#Make sure numbers of '(' and ')' match
	my $count1 = () = $expression =~ /\(/g;
	my $count2 = () = $expression =~ /\)/g;
	print "\n\nInput $expression: Number of '(' and ')' mismatch." if($count1 != $count2);
	
	#More checks are to be done with $expression:
	#Able to distinguish operand & operator
	#All OP will have 2 operands, one in the front and one in the rear.
	#Sequence of each P pair is correct, no somthing like ')xxx('.
	#...

	$len = length($expression);	
	print "\n\nInput: $expression\tAfter removal: ", process();	
}

sub process {
		
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
	
	return 1 if ($right - $left < 3); #empty parentheses or only one char inside
	
	#Vaue '+' or ' ' is used as a convenience since it have no effect on P removal.
	my $OPf = ($left)? substr($expression, $left-1, 1) : ' ';
	$OPf = ' ' if $OPf eq '(';			#when '(' is in front of this base unit.
	my $OPt = ($right < $len - 1)? substr($expression, $right+1, 1) : '+';
	$OPt = '+' if $OPt eq ')';			#when ')' is right behind the base unit.
	
	
	my $nextchar = substr($expression, $left+1, 1);
	return 1 if(($OPf eq '+') && ($OPt eq '+' or $OPt eq '-') && ($nextchar ne '-'));
	return 1 if(($OPf eq ' ') && ($OPt eq '+' or $OPt eq '-'));
	
	my $base = substr($expression, $left, $right - $left + 1);
	
	#Have to go through $base to make sure if '-' found here is an operators or not.
	#Since $base is enclosed with (), no index overflow when seeking for '-';
	#We do not accept expression similar to 3+-2, a--1. This is to say, if '*', '/' or
	#'(' is followed by '-', this '-' is not an operator, but a negation symbol.
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
			
			#$c might be ' ' if this place was P earlier and P is removed just now.
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
    } else {	#See case D in my note above. Previously, I thought P cannot be removed if OPf is '\'
				#Amy made a good point that P in 3/(-5) or a/(b) should be removed.
				#In order to remove P, no '+' or '*' or '/' operator is allowed in the base unit.
				#Only one '-' is allowed and it has to be the charctor right after the opening P or '('.
				#In this case, '-' is the negation symbol, not an OP.
				#In short, no OP is allowed in this base unit if P is to be removed.
		my $in = index($base, '-', 2);		#'(' is always the first charactor. '-' might be the 2nd. Exclude this case.
		return 1 if ($base !~ /[\+\*\\]/ && $in == -1);
	}
	return 0;
}

__DATA__
(1)
(ab)
((ab)*c)
(a/-5)*4
(a/(-b)*a)/b
a-7+9-(8*b-9/(3))+y
x*(7-a+(y/(-6)+(8/(-a))))
x-(-9)*y+(x-a+(b)/x)
x*y/c+(7b)/9x)
7a-(-9/(-6x)+5b/(-9)
((x+y)*b)-(y/a)
a+(b+c)+(d+(c-f))
z+x/(v+n)
(s*v)+i/h
a+(b-m)+x
(b*c)+c/d
3/(-4)
a/(b)
a/(b-4)
a/(-2*(b-4))