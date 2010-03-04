package Catalyst::Model::ABTesting;

use 5.008;

use Moose;
use namespace::autoclean;

=head1 NAME

Catalyst::Model::ABTesting - Simple A/B(/N) testing framework for Catalyst

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module implements a simple framework for A/B (or A/B/N) testing
(L<http://en.wikipedia.org/wiki/Ab_testing>). (In fact this is more of a
multivariate testing (L<http://en.wikipedia.org/wiki/Multivariate_testing>) as
it implements multiple independent A/B or A/B/N tests simultaneously.)

    # in MyApp/Model/ABTesting.pm
    package MyApp::Model::ABTesting;

    use strict;
    use warnings;

    use base 'Catalyst::Model::ABTesting';

    1;

    # in your application configuration
      ...
      'Model::ABTesting' => {
        foo => {                      # a simple A/B test
          store => 'RequestHash',
          values => {
            A => 1,
            B => 1,
          },
        },
        bar => {                      # an A/B/N test with N=4
          store => 'RequestHash',
          values => {
            A => 1,
            B => 2,
            C => 2,
            D => 1,
          },
        },
      },
      ...

    # in any controller action

    # a simple A/B test for the 'foo' variable
    if ($c->model('ABTesting', 'foo')->is_currently('A')) {
      # the 'foo' variable is 'A' (base)
    }
    else {
      # the 'foo' variable is 'B'
    }

    # an A/B/N test for the 'bar' variable
    my $bar_value = $c->model('ABTesting', 'bar')->current_value;
    my $color_code = qw(#FF0000 #00FF00 #0000FF #FFFFFF)[$bar_value];


=head1 DISCLAIMER

This is ALPHA SOFTWARE. Use at your own risk. Features may change.

=head1 DESCRIPTION

=head1 CONFIGURATION

The package looks for its configuration under the C<'Model::ABTesting'> key.
The value for that key is a hashref where each key describes one independent
sample variable. The corresponding value is a hashref with the following keys:

=head2 store

  store => $store_plugin_relative_name

The name of the store plugin (that is responsible for storing the value of the
A/B variable for the given user).

=head2 values

  values => \%probabilities_of_values

A hashref, where each key is a possible value of the sample variable and the
value is the relative probability of that value.

=head2 debug

  debug => $boolean

If set to a true value, the plugin logs more verbosely (using C<<
$c->log->debug(...) >>).

=head1 METHODS

=cut


=head2 ACCEPT_CONTEXT

  ACCEPT_CONTEXT($c, $variable_name);

The calling convention is thus:

  my $model_for_variable = $c->model($model_name, $variable_name);

Returns instances of L<Catalyst::Model::ABTesting::Store>.

If no configuration is found for C<$variable_name> then what happens depends on
whether the application is running in debug mode or not (see
L<Catalyst/debug>). If it's in debug mode it throws an exception, but in live
mode it just logs the error and returns a dummy model instance that always
returns 'A'.

Overridden (wrapped with an C<after> modified) from
L<Catalyst::Component/ACCEPT_CONTEXT>.

=cut

after ACCEPT_CONTEXT => sub {
  my ($c, $variable_name) = (shift, @_);

  my $config_for_variable = $self->config->{$variable_name}
    or do {
      my $message = "Cannot find configuration for variable '$variable_name'";
      if ($c->debug) {
        die $message;
      }
      else {
        $c->log->error($message);
      }
    };
  
  my $model = (__PACKAGE__ . '::Store')->new(
    probability_of_values => $config_for_variable->{values},
  );
  $model->load_plugin($config_for_variable->{store}) if $config_for_variable;

  return $model;
};


=head1 AUTHOR

Norbert Buchmüller, C<< <norbi at nix.hu> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-model-abtesting at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Model-ABTesting>.  I
will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Model::ABTesting

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Model-ABTesting>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Model-ABTesting>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Model-ABTesting>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Model-ABTesting/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Norbert Buchmüller, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::Model::ABTesting
