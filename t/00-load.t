#!/usr/bin/env perl -T

use strict;
use warnings;

use Test::Most;

BEGIN {
	use_ok( 'Catalyst::Model::ABTesting' );
	use_ok( 'Catalyst::Model::ABTesting::Store::RequestHash' );
	use_ok( 'Catalyst::Model::ABTesting::Store::Session' );
	use_ok( 'Catalyst::Model::ABTesting::Store::UserObj::DBIC' );
}

diag( "Testing Catalyst::Model::ABTesting $Catalyst::Model::ABTesting::VERSION, Perl $], $^X" );

done_testing;
