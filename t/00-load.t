#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Algorithm::LimitedRate::Simple' ) || print "Bail out!\n";
}

diag( "Testing Algorithm::LimitedRate::Simple $Algorithm::LimitedRate::Simple::VERSION, Perl $], $^X" );
