package OpusVL::FB11::FormFu::RoleFor::Controller;

use Moose::Role;

before create_action => sub {
    my ($self, %args) = @_;

    if ( defined $args{attributes}{FB11Form} ) {
        push @{ $args{attributes}{ActionClass} }, "OpusVL::FB11::FormFu::Action::FB11FormFu";
    }
};

1;
