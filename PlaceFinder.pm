package Geo::Coder::PlaceFinder;

our $VERSION = '0.1';

use strict;

use Carp qw(croak);
use Encode;
use JSON;
use LWP::UserAgent;
use Net::OAuth;
use URI;

$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;


sub new {
	my $class = shift;
	my $args = ref( $_[0] ) ? $_[0] : { @_ };

	my $ua = $args->{ua} || LWP::UserAgent->new( agent => __PACKAGE__ . "/$VERSION" );

	my $host = $args->{host} || 'yboss.yahooapis.com';

	unless( exists($args->{consumer_key}) && exists($args->{secret_key}) )
	{
		croak "Required parameter 'consumer_key' and 'secret_key' are required";
	};

	my $self = {
		consumer_key	=> $args->{consumer_key},
		secret_key		=> $args->{secret_key},
		_ua				=> $ua,
		host			=> $host,
	};
	bless $self, $class;

	return( $self );
};


sub geocode {
	my $self = shift;
	my $args = ref( $_[0] ) ? $_[0] : { @_ };

	my $url = 'http://'. $self->{host} .'/geo/placefinder?';

	my $request_args = 
	{
		q		=> Encode::encode_utf8( $args->{location} ),
		flags	=> 'J',
		count	=> 1,
	};
	
    my $request = Net::OAuth->request("request token")->new(
    	consumer_key => $self->{consumer_key},  
        consumer_secret => $self->{secret_key}, 
        request_url => $url, 
        request_method => 'GET', 
        signature_method => 'HMAC-SHA1',
        timestamp => time, 
        nonce => 'jfkr3se3f779gswr',
        callback => 'http://printer.example.com/request_token_ready',
        extra_params => $request_args, 
    );

    $request->sign;

	my $res = $self->{_ua}->get($request->to_url); 

	if( $res->is_error ) {
		die "PlaceFinder API returned error: " . $res->status_line;
	};

	my $data = decode_json( $res->content );

	my $response = $data->{bossresponse}->{placefinder}->{results}->[0];

	my $results = 
	{
		lat		=> $response->{latitude},
		long	=> $response->{longitude},
	};

	wantarray ? @{$results} : $results;
}

1;

__END__

=head1 NAME

Geo::Coder::PlaceFinder - Geocode addresses with the Yahoo! BOSS PlaceFinder API 

=head1 VERSION

Version 0.1

=head1 SYNOPSIS

Provides a thin Perl interface to the PlaceFinder Geocoding API.

	use Geo::Coder::PlaceFinder;

	my $geocoder = Geo::Coder::PlaceFinder->new(
		consumer_key => 'consumer_key_from_api_dashboard',
		secret_key => 'secret_key_from_api_dashboard'
	);

	my $location = $geocoder->geocode( { location => '701 1st Ave, Sunnyvale, CA 94089, USA' } );

=head1 OFFICIAL API DOCUMENTATION

Read more about the API at
L<http://developer.yahoo.com/boss/geo>

=head1 METHOD

=over 4

=head2 new   

Constructs a new C<Geo::Coder::PlaceFinder> object and returns it. Requires 
PlaceFinder consumer and secret keys as arguments.

  KEY					VALUE
  -----------			--------------------
  consumer_key			PlaceFinder Consumer Key
  secret_key			PlaceFinder Secret Key


=head2 geocode

Takes a location in a hashref as an argument and returns the lattitude and
longitude of the specified location.

=head1 AUTHOR

Alistair Francis, http://www.alistairfrancis.com/

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.

=cut
