package Catalyst::Model::ABTesting::Store::UserObj::DBIC;

use Moose::Role;
use namespace::autoclean;

=head1 NAME

Catalyst::Model::ABTesting::Store::UserObj::DBIC - Storage plugin for Catalyst::Model::ABTesting::Store based on DBIx::Class

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module provides a storage for the A/B testing variables - it stores them
in the session storage provided by L<Catalyst::Plugin::Session>.

=head1 DISCLAIMER

This is ALPHA SOFTWARE. Use at your own risk. Features may change.

=head1 DESCRIPTION

=head1 METHODS

=cut

#FIXME doc
has dbic_relationship => (
  isa      => 'Str',
  is       => 'ro',
  required => 1,
  default  => 'ab_testing',   #FIXME make it configurable
);

#FIXME doc
has dbic_variable_name_column => (
  isa      => 'Str',
  is       => 'ro',
  required => 1,
  default  => 'variable',     #FIXME make it configurable
);

#FIXME doc
has dbic_value_column => (
  isa      => 'Str',
  is       => 'ro',
  required => 1,
  default  => 'value',        #FIXME make it configurable
);


=head2 fetch_current_value

Overridden (with an an C<around> modifier) from
L<Catalyst::Model::ABTesting::Store>.

Fetches the value of the variable from a L<DBIx::Class> resultset accessible
through the L<DBIx::Class::Row> instance returned by C<< $c->user->obj >> (see
L<Catalyst::Plugin::Authentication/user>). If the variable had no value stored,
generates a new value randomly (according to the probabilities, see
L</variable_probabilities>).

=cut

around fetch_current_value => sub {
  my ($self) = (shift, @_);

  my $user = $self->application_context->user;

  return undef unless $user;

  my $storage_row = $user->obj->find_or_new_related($self->dbic_relationship,
    {
      $self->dbic_variable_name_column => $self->variable_name,
    }
  );

  if (!$storage_row->in_storage) {
    $storage_row->set_columns({
      $self->dbic_value_column => $self->generate_value
    });

    $storage_row->insert;
  }

  return $storage_row->get_column( $self->dbic_value_column );
};


=head1 AUTHOR

Norbert Buchmüller, C<< <norbi at nix.hu> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Norbert Buchmüller, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::Model::ABTesting::Store::UserObj::DBIC
