#!/user/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

print "Input password to verify:";

while (1) {
	my $pw = <STDIN>;
	chomp $pw;
	
	my $result = checkpw($pw);
	
	print $result;
	print "\n input next password(Enter to exit): ";
}

sub checkpw{
	my $pw = shift;
	my $len = length($pw);
	exit unless ($pw);
	
	my $cond1 = ( $pw =~ /[a-z]/ && $pw =~ /[A-Z]/ );
	my $cond2 = ( $pw =~ /[0-9]/ );
	
	my @symb = qw(! @ $ % ^ & * _ - = ~ ; : < > ? / . [ ] { }); #almost all symbols here
	push @symb, ('(', ')', '\\', '#');  #add some special symbols this way
	
	my $cond3 = ( grep { index($pw, $_) != -1} @symb );
	
	#the above is my first try. However, later I realized this could be done this way:
	# my $s = join ('\\', @symb);
	# my $cond3 = ($pw =~ /[$s]/);
	
	if($len < 8) {
		print "Too short, 8 minimum\n";
	} else {
		if ($len < 12) {
			if($cond1 && $cond2 && $cond3) {
				return 'Good';
			} else {
				print "If length is between 8 ~ 12, it has to contain mixed case letters, numbers and symbols\n";
			}
		} elsif ($len < 16) {
			if ($cond1 && $cond2) {
				return 'Good';
			} else {
				print "If length is between 12 ~ 15, it has to contain mixed case letters and numbers\n";
			}
		} elsif ($len < 20) {
			if ($cond1) {
				return 'Good';
			} else {
				print "if length is between 16 ~ 20, it has to contain mixed case letters\n"
			}
		} else {
			return "Good";
		}
	}
	return "Bad";
}
	