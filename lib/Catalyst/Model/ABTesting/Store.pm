package Catalyst::Model::ABTesting::Store;

use 5.008;

use Moose;
use namespace::autoclean;

use List::Util qw(sum);

with 'MooseX::Object::Pluggable';

=head1 NAME

Catalyst::Model::ABTesting::Store - Simple A/B(/N) testing framework for Catalyst - storage class

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Instances of this module are returned by C<< $c->model($ab_testing_model_name)
>>. See L<Catalyst::Mode::ABTesting>.

=head1 DISCLAIMER

This is ALPHA SOFTWARE. Use at your own risk. Features may change.

=head1 DESCRIPTION

=head1 METHODS

=cut


=head2 application_context

  $c = $self->application_context;

Returns the application context (aka. "C<$c>").

=cut

has application_context => (
  isa           => class_type('Catalyst'),
  is            => 'ro',
  required      => 1,
  weak_ref      => 1,
  documentation => 'The application context',
);


=head2 probability_of_values

  %probabilities = %{ $self->probability_of_values };

The probabilities by value for the variable.

=head2 possible_values

Returns the list of the possible values of the variable.

=head2 all_probabilities

Returns the list of the probability values of the variable.

=head2 probability_of

  $probability = $self->probability_of($value);

The probability of C<$value> for the variable.

=cut

has probability_of_values => (
  isa           => 'HashRef[Num]',
  is            => 'ro',
  required      => 1,
  traits        => ['Hash'],
  handles       => {
    probability_of    => 'get',
    possible_values   => 'keys',
    all_probabilities => 'values',
  },
  documentation => 'The probabilities by value for the variable',
);


=head2 variable_name

Returns the value of the given variable in the current request.

=cut

has variable_name => (
  isa           => 'Str',
  is            => 'ro',
  required      => 1,
  documentation =>
    'The current value of the given variable in the current request',
);


=head2 current_value

Returns the value of the given variable in the current request.

=head2 has_value

Returns true iff the given variable has a value.

=cut

has current_value => (
  isa           => 'Any',
  is            => 'ro',
  lazy          => 1,
  builder       => 'fetch_current_value',
  predicate     => 'has_value',
  documentation =>
    'The current value of the given variable in the current request',
);


=head2 fetch_current_value

  $current_value = $self->fetch_current_value;

Fetches the value of the variable for the current request.

=cut

sub fetch_current_value
{
  my ($self) = (shift, @_);

  # always the same value ('A') in fallback-mode if no config found
  return (sort $self->possible_values)[0];
}


=head2 generate_value

  $new_value = $self->generate_value;

Generates a new random value for the variable, in accordance with the
probabilities of the values (L</probability_of_values>).

=cut

sub generate_value
{
  my ($self) = (shift, @_);

  my $total_probability = sum $self->all_probabilities;

  my $random_number = rand $total_probability;

  my $cumulative_probability = 0;
  while (my ($value, $probability) = each %{ $self->probability_of_values }) {
    $cumulative_probability += $probability;
    if ($random_number < $cumulative_probability) {
      return $value;
    }
  }
}


=head2 is_currently

  $bool = $self->is_currently($value);

Returns true iff the value of the given variable in the given request is
C<$value>.

=cut

sub is_currently
{
  my ($self, $value) = (shift, @_);

  if ($self->probability_of($value) == 0) {
    my $message = "Value of variable " . $self->variable_name . " cannot "
      ." be '$value' (the configured probability for it is 0)";
    if ($c->debug) {
      die $message;
    }
    else {
      $c->log->error($message);
      return 0;
    }
  };

  return $self->has_value && $self->current_value eq $value;
}


=head1 AUTHOR

Norbert Buchmüller, C<< <norbi at nix.hu> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Norbert Buchmüller, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1; # End of Catalyst::Model::ABTesting::Store
