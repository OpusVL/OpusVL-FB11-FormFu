package OpusVL::FB11::FormFu::RoleFor::Controller;

use Moose::Role;
use File::ShareDir qw/module_dir/;
use Try::Tiny;

before create_action => sub {
    my ($self, %args) = @_;

    if ( defined $args{attributes}{FB11Form} ) {
        push @{ $args{attributes}{ActionClass} }, "OpusVL::FB11::FormFu::Action::FB11FormFu";
    }
};

after COMPONENT => sub {
    my ($class, $app, $args) = @_;
    $args = $class->merge_config_hashes($args, $class->config);

    try {
        my $module_dir = module_dir($class);
        push @{$app->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path}},
            $module_dir . '/root/forms';
    }
    catch {
        $app->log->debug("No module_dir for $class");
    };

    my $real_module = $args->{fb11_myclass} or return;
    try {
        my $module_dir = module_dir($real_module);
        push @{$app->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path}},
            $module_dir . '/root/forms';
    }
    catch {
        $app->log->debug("No module_dir for $real_module, defined on $class");
    };
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
