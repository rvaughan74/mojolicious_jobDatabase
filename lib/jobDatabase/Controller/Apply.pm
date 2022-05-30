package jobDatabase::Controller::Apply;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub apply {

    my $self = shift;

    # Render template "mine/apply.html.ep" with message
    $self->render(
        template => "mine/apply"
    );
}

sub data {

    my $self = shift;

    $self->render( json => $self->applyData->getData() );
}

1;
