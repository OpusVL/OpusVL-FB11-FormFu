package OpusVL::FB11::FormFu::Action::FB11FormFu;

use Moose;
use namespace::autoclean;
use MRO::Compat; 
use List::MoreUtils qw/uniq/;

extends 'Catalyst::Action';

=head2 execute

Method called when an action is requested that has the 'FB11Form' attribute.

=cut

sub execute 
{
    my $self = shift;
    my ($controller, $c, @args) = @_;

    die("Failed to pull form from controller. Ensure your Controller 'extends' Catalyst::Controller::HTML::FormFu")
        unless $controller->can('form');
    my $form = $controller->form;

    # Configure the form to generate IDs automatically
    $form->auto_id("formfield_%n_%r_%c");
    # The action attribute should point the path of the config file...
    my $config_file = $self->attributes->{FB11Form}->[0];

    my $path = '';
    # ... build the rest of the path..
    if ( defined $config_file )
    {
        $path .= $config_file;
    }
    else
    {
        $path .= $self->reverse . '.yml';
    }

    $c->log->debug("FB11Form Loading config: $path \n" );

    $self->load_config_file( $c, $form, $path );
    my $new_formfu = $form->can('auto_container_comment_class');
    $form->auto_container_error_class('has-error');
    if($c->config->{old_formfu_classes})
    {
        # I can't really see why you'd need this in our new Bootstrap'd world...
        $form->auto_container_class('%t');
        $form->auto_container_label_class('label');
        $form->auto_container_comment_class('comment');
        $form->auto_comment_class('comment');
        $form->auto_container_error_class('error');
        $form->auto_container_per_error_class('error_%s_%t');
        $form->auto_error_class('error_message error_%s_%t');
    }

    my $previous_indicator = $form->indicator;
    $form->indicator(sub 
    {
        my $self = shift;
        my $query = shift;
        if(uc $form->method eq 'POST') {
            unless(uc $c->req->method eq 'POST')
            {
                # check form is a post, if not return false.
                return 0;
            }
        }
        if($previous_indicator) 
        {
            return $query->param($previous_indicator);
        }
        else
        {
            my @names = uniq grep {defined} map { $_->nested_name } @{ $self->get_fields };
            return grep { defined $query->param($_) } @names;
        }
    });

    $self->process( $form );

    # .. stash it..
    $c->stash->{form} = $form;

    $self->next::method(@_);
}

sub load_config_file
{
    my $self = shift;
    my $c = shift;
    my $form = shift;
    my $form_file = shift;

    $form->load_config_file ( $form_file );
}

sub process
{
    my $self = shift;
    my $form = shift;
    # this is here so that other classes/roles can hook this method.
    # .. process it..
    $form->process;
}

1;

=head1 NAME

OpusVL::FB11::Action::FB11Form - Action class for OpusVL::FB11 FormConfig Loading

=head1 SYNOPSIS

    package TestX::CatalystX::ExtensionA::Controller::ExtensionA 
    sub formpage :Local :FB11Form("admin/users/userform.yml")
    {
        my ($self, $c) = @_;
        $self->stash->{form}
        $c->stash->{template} = 'formpage.tt';
    }

=head1 DESCRIPTION

Finds the FormFu YAML form named in the attribute's parameter and stashes a
FormFu object constructed therefrom.

The YAML name is taken relative to the L<File::ShareDir> module directory,
normally C<lib/auto/Module/Name/forms>.

=head1 SEE ALSO

=over

=item L<Catalyst>

=item L<OpusVL::FB11::Base::Controller::GUI>

=back

=cut
