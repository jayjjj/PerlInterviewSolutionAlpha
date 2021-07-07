# PerlInterviewSolutionAlpha

Last year, this company, Alpha(fake), started the interview process and sent me 2 problems to solve. I did submit my code but I failed the panel interview later. I was never good at it and this is somewhere I need to improve. Anyhow, I decided to put everything here to mark this experience.

Here are the 2 problems:

1.  Write a Perl function that takes in a password and checks whether it's valid.  The password should follow the following rule:

    Passwords must be at least 8 characters long.
    Between 8-11: requires mixed case letters, numbers and symbols
    Between 12-15: requires mixed case letters and numbers
    Between 16-19: requires mixed case letters
    20+: any characters desired

 2. Parentheses removal function. Given a string containing an expression, return the expression with unnecessary parentheses removed.

    For example:

    f("1*(2+(3*(4+5)))") ===> "1*(2+3*(4+5))"
    f("2 + (3 / -5)") ===> "2 + 3 / -5"
    f("x+(y+z)+(t+((v+w)))") ===> "x+y+z+t+v+w"

Please write a function that removes unnecessary parenthesis for any given string. You can write this in any language but please provide it in an executable format with instructions.

I started to work on it during the weekend. Later that day, I was able to submit my code together with this email:

...
I used Perl 5.8/5.14/5.20 at work. Today, I found out my old box didn't work anymore. I had to download Perl 5.28 from ActiveState for Windows. I was lucky to make it work.

Not much to say on the first one, password verification. Actually, I do have to mention what I have in mind while I worked on the 2nd one:

1. Not much check is done the input arithmatic expression. I only made sure numbers of '(' and ')' is equal to each other. 
2. While '-' should be an operator or negation symbol to indicate negative number. I didn't treat '+' having 2 meanings, though this can be done easily.
3. Parentheses in expression a+(-b+c) will not be removed to a-b+c

I put on something in the comments on how I approach to resolve this problem. Some of them are outdated and no longer valid as I understood better to the problem. Howeve, I kept them there since I thought they were helpful for viewers to understand the code better.

I do not use captial letters as variable name. This time it is different since I noted it in the comments. Lazy to work on it more since I know the code will be discarded later.

Anyhow, the code runs well under Win10 with ActivePerl. Let me know if you have problems.
...

This is the feedback I got:

...
For problem #1, can you see about solving this using lookahead regular expressions and see if you can get the solution to be more concise?
For problem #2, you covered a lot of cases. Can you share the test cases that you used to verify your work?
There is one small case where the parenthesis were not removed, see:
Input: (5)/(6)
Got: 5/(6)
Expected: 5/6
...

I promised to work on them again during the next weekend. Later, I attached my modified version with this email:

```````````````````
1.
The first change I did was to replace the infinite loop to get input from terminal input to DATA section at the end of the script, for both solutions. Previously, it gave me more freedom to perform some tests manually at will. I can terminate easily the loop anytime if I want. Hope this change is easier for all the cases to be covered. You can paste them in the DATA section to see how it goes.

2.
Regarding the problem 2, I thank you very much for pointing it out to me. I got to know quickly & easily how I missed the case with your example. I thought any parentheses after operator of '/' could not be removed since the formula within this parentheses should be processed first. I neglected the case when there was no operators inside.

This is the code I added:

    if($OPf ne '/') {
        ....
    } else {	#See case D in my note above. Previously, I thought P cannot be removed if OPf is '\'
			#Amy made a good point that P in 3/(-5) or a/(b) should be removed.
			#In order to remove P, no '+' or '*' or '/' operator is allowed in the base unit.
			#Only one '-' is allowed and it has to be the charctor right after the opening P or '('.
			#In this case, '-' is the negation symbol, not an OP.
			#In short, no OP is allowed in this base unit if P is to be removed.
		my $in = index($base, '-', 2);		#'(' is always the first charactor. '-' might be the 2nd. Exclude this case.
		return 1 if ($base !~ /[\+\*\\]/ && $in == -1);
	}

It should cover the case I missed.

3. 

I had planned to change my code according to your suggestion. Suddenly, I lost the desire to do it. My change is very limited:

replace line: 
my $cond1 = ( $pw =~ /[a-z]/ && $pw =~ /[A-Z]/ );
with line:
my $cond1 = ( $pw =~ /(?=[^a-z]*[a-z])(?=[^A-Z]*[A-Z])/ );

There are several reasons:
a.
Readability. Perl has the unfair fame of being hard to be understood. I guess regex, especially extended regex, is part of the reason. It might be easier to the other developers to understand the code to write the code this way.
b.
Performance. Regex could consume a lot of resources if it is not written carefully and thoughtfully. I would try to avoid it if I can.
c.
Structure. This problem needs several conditions respectively. It is pointless to write a long, tedious clause to cover all the cases. I am not a fan of JAPH. This will timid the new developers to learn and use Perl.
d.
Style. Python PEP8 limits maximum line length to 79. Personally, I think it is a over requirement, 100 or 120 might be a better alternative. I agree on the principle in PEP8 and will vote against long lines, especially long line with regex.
e.
Maintenance. Shorter, clearer code will definitely be easy to be maintained.

There is one possible change I agree on:

Reduce the 2-level 'if..else' structure to one level to increase readability and make it this way:

if ($len > 19) {
...
} elsif ($len < 20 && $len > 15) {
...
} elsif ($len < 16 && $len > 11) {
...
...
...

However, I don't think it is too hard to understand the 2-level 'if..else' structure. That is why I keep it that way.  There is a tradeoff between shorter code & readability.

I understand that you want to see if I am able to work with lookahead Regex. Here is it:

print $RULES_FOR_PASSWORD;
return "Good" if($pw =~/\A(?=.{20,}\z)/ ||
   $pw =~/\A(?=.{16,19}\z)(?=[^a-z]*[a-z])(?=[^A-Z]*[A-Z])/ ||
   $pw =~/\A(?=.{12,15}\z)(?=[^a-z]*[a-z])(?=[^A-Z]*[A-Z])(?=\D*\d)/ ||
   $pw =~/\A(?=.{8,11}\z)(?=[^a-z]*[a-z])(?=[^A-Z]*[A-Z])(?=\D*\d)(?=[^\$\%\#]*[\$\%\#])/)

return 'Bad'.

Again, I am voting against this approach.

4. Tests
I did have the experience to use Test::Simple to pass the unit/regression tests quite a while ago. Nowadays, Util 'prove' is being used in our team.

However, for those 2 issues, I think DATA section should be good enough to cover all the test cases. I could make it  return something like 'all tests passed' or 'OK' or 'Not OK' with more code with the avaiable test module in Perl. Don't think it is hard to find one.

````````````````````

The code reviewer seemed happy at what I submitted. However, I was not able to land this position. Good luck to this Alpha company in finding a coder who is good at selling himself/herself.
