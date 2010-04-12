#!/usr/bin/perl

use Net::Random::QRBG;
use Data::Dumper;

$qrbgs = new Net::Random::QRBG('username', 'password');

@ints = $qrbgs->get(4);
print "Got random integers: @ints\n";

@shorts = $qrbgs->get(2, 's');
print "Got random shorts: @shorts\n";

$bytes = $qrbgs->getraw(1024);

print "c: ".Dumper($qrbgs->get(1, 'c'))."\n";
print "n: ".Dumper($qrbgs->get(1, 'n'))."\n";
print "N: ".Dumper($qrbgs->get(1, 'N'))."\n";


