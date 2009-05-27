package Net::Random::QRBG;

use warnings;
use strict;

=head1 NAME

Net::Random::QRBG - Gather random data from the QRBG Service

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Carp ();
use IO::Socket::INET;
use List::Util qw(max);
use bytes;

=head1 SYNOPSIS

Module retrieves random data from the QRBG Service

    use Net::Random::QRBG;

    my $foo = Net::Random::QRBG->new();
    ...

=head1 FUNCTIONS

=head2 new

=cut

sub new {
	my ($package, %params) = @_;
	
	my $user = delete $params{user};
	$user ||= 'nulluser';

	my $pass = delete $params{pass};
	$pass ||= 'nullpass';
	
	my $server = delete $params{server};
	$server ||= 'random.irb.hr';

	my $port = delete $params{port};
	$port ||= '1227';

	my $cache_size = delete $params{cache_size};
	$cache_size ||= 4096;

	my $cache = '';

	my $self = bless {
				server		=> $server,
				port		=> $port,
				user		=> $user,
				pass		=> $pass,
				cache_size	=> $cache_size,
				cache		=> $cache,
				}, $package;

	unless( $self->_fillCache ) {
		Carp::croak $self->errstr;
	}
	return $self;	
}

=head2 credentials( $user, $pass )

Get/Set user login details

=cut

sub credentials {
	my $self = shift;
	if (@_) {
		my ($user, $pass) = @_;
		$self->{user} = $user;
		$self->{pass} = $pass;
	}
	return ($self->{user}, $self->{pass});
}

=head2 setCache( $cache_size )

Get/Set the cacheSize

=cut

sub setCache {
	my ($self) = shift;
	if (@_) {
		my $new_size = shift;
		$self->{cache_size} = $new_size;
	}
	return $self->{cache_size};
}

=head2 getChar( )

Returns one byte

=cut

sub getChar {
	my $self = shift;
	return $self->_acquireBytes(1);
}

=head2 getInt ( )

Return unsigned integer

=cut 

sub getInt {
	my $self = shift;
	my $i = $self->_acquireBytes(4);
	return 0 unless $i;
	return unpack("i4",$i);
}

sub _fillCache {
	my ($self) = @_;
	return $self->_getMoreBytes( $self->{cache_size} );
}

sub _acquireBytes {
	my ($self, $count) = @_;
	if ( ( bytes::length($self->{cache}) < $count ) && !$self->_getMoreBytes( max( $self->{cache_size}, $count ) ) ) {
		return 0;
	}
	my $r = substr( $self->{cache}, 0, $count );
	$self->{cache} = substr( $self->{cache}, $count );
	return $r;
}

sub _getMoreBytes {
	my ($self, $count) = @_;
	
	my $sock = IO::Socket::INET->new(
		Proto		=> 'tcp',
		PeerPort	=> $self->{port},
		PeerAddr	=> $self->{server}
	) or die "Unable to create socket: $!\n";

	my $un_length = length( $self->{user} );
	my $pw_length = length( $self->{pass} );
	my $content_size = 6 + $un_length + $pw_length;

	my $pcode = "xnca$un_length"."ca$pw_length"."N";
	my $data = pack( $pcode, $content_size, $un_length, $self->{user}, $pw_length, $self->{pass}, $count );
	
	$sock->send($data);

	my $received = '';
	while( my $rcv = <$sock> ) {
		$received .= $rcv;
	}
	close($sock);

	my ($code, $code2, $bytes_returned, $rawdata) = unpack("ccNa*", $received);

	if( $code || $code2 ) {
		$self->_seterror($code, $code2);
		return 0;
	}
	
	$self->{cache} .= $rawdata;
	return 1;
}

sub _seterror {
	my ( $self, $c1, $c2 ) = @_;
	
	my @service_errors = (
		"OK",
		"Service was shutting down",
		"Server was/is experiencing internal errors",
		"Service said we have requested some unsupported operation",
		"Service said we sent an ill-formed request packet",
		"Service said we were sending our request too slow",
		"Authentication failed",
		"User quota exceeded" );
	my @service_fixes = (
		"None",
		"Try again later",
		"Try again later",
		"Upgrade your client software",
		"Upgrade your client software",
		"Check your network connection",
		"Check your login credentials",
		"Try again later, or contact Service admin to increase your quota(s)" );

	$self->{error} = $service_errors[$c1] . ": " . $service_fixes[$c2];
}

=head2 errstr( )

Return last error

=cut

sub errstr {
	my $self = shift;
	return $self->{error} || "";
}
	
=head1 AUTHOR

Brent Garber, C<< <overlordq at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-random-qrbg at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Random-QRBG>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Random::QRBG


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Random-QRBG>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Random-QRBG>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Random-QRBG>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Random-QRBG/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Brent Garber, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Net::Random::QRBG
