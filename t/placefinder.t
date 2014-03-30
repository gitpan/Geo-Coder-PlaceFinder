use strict;

use Test::More tests => 3;
use Test::Exception;

my $consumer_key = 'ThisIsNotARealKey';
my $secret_key = 'ThisIsNotARealKey';

BEGIN {
	use_ok( 'Geo::Coder::PlaceFinder' );
};


dies_ok { Geo::Coder::PlaceFinder->new() } 'can not create object without arguments';

my $geocoder = Geo::Coder::PlaceFinder->new( consumer_key => $consumer_key, secret_key => $secret_key );

isa_ok( $geocoder, 'Geo::Coder::PlaceFinder' );


