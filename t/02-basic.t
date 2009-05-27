#!perl -T

use Test::More tests => 7;

BEGIN {
	use Net::Random::QRBG;
}

my $obj = Net::Random::QRBG->new(user => "NRQRBG", pass => "NRQRBG");
isa_ok($obj,"Net::Random::QRBG");

my ($user,$pass) = $obj->credentials();
cmp_ok($user,'eq','NRQRBG', 'User Credential');
cmp_ok($pass,'eq','NRQRBG', 'Pass Credential');

($user,$pass) = $obj->credentials('newuser','newpass');
cmp_ok($user,'eq','newuser', 'Set User Credential');
cmp_ok($pass,'eq','newpass', 'Set Pass Credential');

my $csize = $obj->setCache();
cmp_ok( $csize, '==', 4096, 'Cachesize');

$csize = $obj->setCache(5);
cmp_ok( $csize, '==', 5, 'SetCachesize');
