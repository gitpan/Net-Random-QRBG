package Net::Random::QRBG;

=head1 NAME

Net::Random::QRBG - Get random numbers/data from 
Quantum Random Bit Generator Service.

=head1 VERSION

Version 0.01alpha

=cut

our $VERSION = '0.01alpha';


=head1 SYNOPSIS

	use Net::Random::QRBG;
	$qrbg = new Net::Random::QRBG('username', 'password');
	
	@ints = $qrbg->get(4);
	print "Got random integers: @ints\n";
	
	@shorts = $qrbg->get(2, 's');
	print "Got random shorts: @shorts\n";
	
	$bytes = $qrbg->getraw(1024);

=head1 DESCRIPTION

Net::Random::QRBG connects directly to the QRBG Service and retrieves the specified number
of random bytes from the datastream returned.

This is a Perl version client for QRBG Service API,
much like a Perl porting of PHP's QRBG Service Access class.
The OO interface is now borrow from Brandon Checketts' Data::Random::QRBGS,
which is not availiable on CPAN.
In next version I'll fix the OO interface to be compactible with the 
official C++ method names.

=cut

use common::sense;
use Config;
use IO::Socket::INET;

my $user	= '';
my $pass	= '';
my $server	= 'random.irb.hr';
my $port	= '1227';
my $received	= '';

=head1 METHODS

=head2 new

=cut

sub new($$) {
	my $class = shift;
	($user, $pass) = @_;
	
	if (length($user)<1 || length($user)>100) {
		#~ $this->seterror(1,0,0,"Username may not be empty or exceed 100 characters");
		warn "Username may not be empty or exceed 100 characters";
		return undef;
	}
	if (length($pass)<6 || length($pass)>100) {
		#~ $this->seterror(1,0,0,"Password must be at least 6, at most 100 characters long");
		warn "Password must be at least 6, at most 100 characters long";
		return undef;
	}
	
	return bless ({}, ref($class) ? ref($class) : $class);
}

=head2 getraw

=cut

sub getraw($) {
	my($self, $bytes) = @_;
	
	my $sock = IO::Socket::INET->new(
		Proto	=> 'tcp',
		PeerPort	=> $port,
		PeerAddr	=> $server
	) or die "Unable to connect to remote host $server:$port\n";
	
	#~ setup request
	
	#~ Client first (and last) packet:
	#~ Size [B]		Content
	#~ --------------	--------------------------------------------------------
	#~ 1				operation, from OperationCodes enum
	#~ if operation == GET_DATA_AUTH_PLAIN, then:
	#~ 2				content size (= 1 + username_len + 1 + password_len + 4)
	#~ 1				username_len (must be > 0 and <= 100)
	#~ username_len	username (NOT zero padded!)
	#~ 1				password_len (must be >= 6 and <= 100)
	#~ password_len	password in plain 8-bit ascii text (NOT zero padded!)
	#~ 4				bytes of data requested
	
	#~ Server first (and last) packet:
	#~ Size [B]		Content
	#~ --------------	--------------------------------------------------------
	#~ 1				response, from ServerResponseCodes enum
	#~ 1				response details - reason, from RefusalReasonCodes
	#~ 4				data_len, bytes of data that follow
	#~ data_len		data
	
	
	my $req=
		chr(0).		# GET_DATA_AUTH_PLAIN
		pack("n",length($user)+length($pass)+6).
		chr(length($user)).
		$user.
		chr(length($pass)).
		$pass.
		pack("N",$bytes);
	
	
	$sock->send($req);
	
	$received = '';
	while(my $rcv = <$sock>) {
		$received .= $rcv;
	}
	close($sock);
	
	my ($code, $code2, $bytes_returned, $rawdata)  = unpack("ccNa*", $received);
	return $rawdata;
}

=head2 get

=cut

sub get($;$) {
	my ($self, $count, $type) = @_;
	
	## Default to unsigned integers if type was not specified
	$type = $type || 'i';
	
	# Is there a way to determine how many bytes are in a particular type (without Devel::Size)?
	
	my $bytes_each;
	if($type eq 'c' || $type eq 'C') {
		$bytes_each = 1;
	} elsif( $type eq 's' || $type eq 'S') {
		$bytes_each = $Config{shortsize};
	} elsif( $type eq 'n' || $type eq 'v') {
		$bytes_each = 2;
	} elsif( $type eq 'l' || $type eq 'L') {
		$bytes_each = 2;
	} elsif( $type eq 'i' || $type eq 'I') {
		$bytes_each = $Config{intsize};
	} elsif($type eq 'N' || $type eq 'V') {
		$bytes_each = 4;
	} elsif( $type eq 'q' || $type eq 'Q' || $type eq 'l' || $type eq 'L') {
		$bytes_each = 4;
	} else {
		print "Data::Random::QRBG - I don't know the size in byes of type $type\n";
		## How to handle requests for floats?
		return 0;
	}
	
	my $bytes = $bytes_each * $count;
	$self->getraw($bytes);
	
	my ($code, $code2, $bytes_returned, @results)  = unpack("ccN".$type.$count, $received);
	
	return @results;
}

=head1 AUTHOR

BlueT - Matthew Lien - 練喆明, C<< <BlueT at BlueT.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-random-QRBG at rt.cpan.org>, or through
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

L<http://search.cpan.org/dist/Net-Random-QRBG>

=back


=head1 ACKNOWLEDGEMENTS

=item * QRBG: Quantum Random Bit Generator Service

L<http://random.irb.hr/>

=item * Brandon Checketts' Data::Random::QRBGS

L<http://www.brandonchecketts.com/qrbgs.php>

=item * QRBG Service Access class for PHP

L<http://random.irb.hr/download.php?file=qrbg.php>


=head1 COPYRIGHT & LICENSE

Copyright 2010 BlueT - Matthew Lien - 練喆明, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Net::Random::QRBG
