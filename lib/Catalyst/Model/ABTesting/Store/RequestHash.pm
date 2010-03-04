package Catalyst::Model::ABTesting::Store::RequestHash;

#FIXME check if bits are less than the number of bits in the hash
#FIXME check if bits do not overlap
#FIXME check if the probabilities are integers
#FIXME check if the cumulative number of probabilities sums up to exactly the number representable by the bits (no more - cannot represent it - and no less - there's no 'neither' value of the variable)

use Moose::Role;
use namespace::autoclean;

use Digest::SHA1 qw(sha1);

=head1 NAME

Catalyst::Model::ABTesting::Store::RequestHash - Storage plugin for Catalyst::Model::ABTesting::Store using a hash of the request

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module provides a virtual storage for the A/B testing variables - the
variables are not stored in reality, just their values are predicted from a
hash of some parts of the request.

    # in your application configuration
      ...
      'Model::ABTesting' => {
        foo => {
          store => 'RequestHash',
          values => {
            A => 1,
            B => 1,
          },
          bits => [0], # bit 0 of the hash is used for variable 'foo'
        },
        bar => {
          store => 'RequestHash',
          values => {
            A => 1,
            B => 1,
            C => 1,
            D => 1,
          },
          bits => [1, 2], # bits 1 and 2 of the hash are used for variable 'bar'
        },
        quux => {
          store => 'RequestHash',
          values => {
            A => 1,
            B => 2,
            C => 2,
            D => 3,
          },
          bits => [3..5], # bits 3..5 of the hash are used for variable 'quux'
        },
      },
      ...


=head1 DISCLAIMER

This is ALPHA SOFTWARE. Use at your own risk. Features may change.

=head1 DESCRIPTION

FIXME describe how it works (ie. hashing the IP and user-agent string and
using certain bits)

=head1 METHODS

=cut


=head2 value_to_hash

The value that more-or-less identifies the user. Currently it returns the IP
address of the client and the user-agent string concatenated.

You can override it if you want to include other parts of the request.

=cut

#FIXME find a better name..
sub value_to_hash
{
  my ($self) = (shift, @_);

  my $request = $self->application_context->req;

  return $req->address . $req->user_agent;
}


=head2 fetch_current_value

Overridden (with an an C<around> modifier) from
L<Catalyst::Model::ABTesting::Store>.

In theory this method fetches the value of the variable from the virtual
storage. In fact there's no such storage, but it calculates the value of the
variable from some bits of the hash of some parts of the request.

FIXME better wording..

=cut

around fetch_current_value => sub {
  my ($self) = (shift, @_);

  my $hash = sha1($self->value_to_hash);

  #FIXME implement deduction of $offset and $bits from $self->probability_of_values

  return vec $hash, $offset, $bits;
};


=head1 AUTHOR

Norbert Buchmüller, C<< <norbi at nix.hu> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Norbert Buchmüller, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::Model::ABTesting::Store::RequestHash
