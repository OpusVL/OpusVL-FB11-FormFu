use strict;
use warnings;
package OpusVL::FB11::FormFu;

our $VERSION = '0.02';

1;

=head1 NAME

OpusVL::FB11::FormFu - FormFu compatibility roles.

=head1 DESCRIPTION

This provides the role required to support HTML::FormFu in OpusVL::FB11.

This is intended to allow older modules to be converted more simply over to FB11
without a complete rewrite.

See L<OpusVL::FB11::FormFu::RoleFor::Controller> and L<OpusVL::FB11::FormFu::Action::FB11FormFu>
