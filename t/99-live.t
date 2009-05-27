#!perl -T

use Test::More tests => 3;

BEGIN {
	use Net::Random::QRBG;
}

my $obj = Net::Random::QRBG->new(user => "NRQRBG", pass => "NRQRBG");
isa_ok($obj,"Net::Random::QRBG");

my $char = $obj->getInt();
cmp_ok( $char, '!=', 0, '');

my $error = $obj->errstr();
cmp_ok( $error, 'eq', '', 'ErrorString');
