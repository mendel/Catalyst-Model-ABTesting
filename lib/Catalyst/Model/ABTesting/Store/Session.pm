package Catalyst::Model::ABTesting::Store::Session;

use Moose::Role;
use namespace::autoclean;

use Readonly;

=head1 NAME

Catalyst::Model::ABTesting::Store::Session - Storage plugin for Catalyst::Model::ABTesting::Store based on the session storage

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

Readonly our $session_storage_key => '_' . __PACKAGE__;


=head1 SYNOPSIS

This module provides a storage for the A/B testing variables - it stores them
in the session storage provided by L<Catalyst::Plugin::Session>.

=head1 DISCLAIMER

This is ALPHA SOFTWARE. Use at your own risk. Features may change.

=head1 DESCRIPTION

=head1 METHODS

=cut


=head2 fetch_current_value

Overridden (with an an C<around> modifier) from
L<Catalyst::Model::ABTesting::Store>.

Fetches the value of the variable from the session storage. If the variable had
no value stored, generates a new value randomly (according to the
probabilities, see L</variable_probabilities>). If there was no session it
returns undef.

Note: Calling this method will NOT create a new session if there was no session
already.

=cut

around fetch_current_value => sub {
  my ($self) = (shift, @_);

  return undef unless $self->application_context->session_is_valid;

  my $storage = $self->application_context->session->{$session_storage_key};

  my $variable_name = $self->variable_name;
  
  if (!exists $storage->{$variable_name}) {
    $storage->{$variable_name} = $self->generate_value;
  }

  return $storage->{$variable_name};
};


=head1 AUTHOR

Norbert Buchmüller, C<< <norbi at nix.hu> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Norbert Buchmüller, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::Model::ABTesting::Store::Session
