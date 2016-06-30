package OpusVL::FB11::FormFu::RoleFor::Controller;

use Moose::Role;

before create_action => sub {
    my ($self, %args) = @_;

    if ( defined $args{attributes}{FB11Form} ) {
        push @{ $args{attributes}{ActionClass} }, "OpusVL::FB11::FormFu::Action::FB11FormFu";
    }
};

=head2 flag_callback_error

Flags an HTML::FormFu callback error.

Setup a callback constraint on your form,

  - type: Text
    name: project
    label: Project
    constraints:
      - type: Callback
        message: Project is invalid

Then within your controller you can do, 

    $self->flag_callback_error($c, 'project');

This will terminate the processing of the action too, by doing a $c->detach;

=cut

sub flag_callback_error
{
    my ($self, $c, $field_name, $message) = @_;
    return $self->flag_callback_error_ex($c, $field_name, { message => $message });
}

sub flag_callback_error_ex
{
    my ($self, $c, $field_name, $args) = @_;

    $args //= {};
    my $message = $args->{message};
    my $no_detach = $args->{no_detach};

    my $form = $c->stash->{form};
    my $constraint = $form->get_field($field_name)->get_constraint({ type => 'Callback' });
    $constraint->callback(sub { 0});
    $constraint->message($message) if $message;
    $form->process;
    $c->detach unless $no_detach;
}

1;
