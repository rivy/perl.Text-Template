#!perl
#
# test apparatus for Text::Template module
# still incomplete.

use strict;
use warnings;
use Test::More tests => 7;

use_ok 'Text::Template' or exit 1;

Text::Template->import('fill_in_file', 'fill_in_string');

$Q::n = $Q::n = 119;

# (1) Test fill_in_string
my $out = fill_in_string('The value of $n is {$n}.', PACKAGE => 'Q' );
is $out, 'The value of $n is 119.';

# (2) Test fill_in_file
my $TEMPFILE = "tt$$";
open F, "> $TEMPFILE" or die "Couldn't open test file: $!; aborting";
print F 'The value of $n is {$n}.', "\n";
close F or die "Couldn't write test file: $!; aborting";
$R::n = $R::n = 8128; 

$out = fill_in_file($TEMPFILE, PACKAGE => 'R');
is $out, "The value of \$n is 8128.\n";

# (3) Jonathan Roy reported this bug:
open F, "> $TEMPFILE" or die "Couldn't open test file: $!; aborting";
print F "With a message here? [% \$var %]\n";
close F  or die "Couldn't close test file: $!; aborting";
$out = fill_in_file($TEMPFILE, DELIMITERS => ['[%', '%]'],
		    HASH => { "var" => \"It is good!" });
is $out, "With a message here? It is good!\n";

# (4) It probably occurs in fill_this_in also:
$out = 
  Text::Template->fill_this_in("With a message here? [% \$var %]\n",
                      DELIMITERS => ['[%', '%]'],
                      HASH => { "var" => \"It is good!" });
is $out, "With a message here? It is good!\n";

# (5) This test failed in 1.25.  It was supplied by Donald L. Greer Jr.
# Note that it's different from (1)  in that there's no explicit 
# package=> argument.
use vars qw($string $foo $r);
$string='Hello {$foo}';
$foo="Don";
$r = fill_in_string($string);
is $r, 'Hello Don';

# (6) This test failed in 1.25.  It's a variation on (5)
package Q2;
use Text::Template 'fill_in_string';
use vars qw($string $foo $r);
$string='Hello {$foo}';
$foo="Don";
$r = fill_in_string($string);

package main;

is $Q2::r, 'Hello Don';

END { $TEMPFILE && unlink $TEMPFILE }

exit;
