package jobDatabase::Controller::Delete;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub delete {

    my $self = shift;

    # Render template "mine/delete.html.ep" with message
    $self->render(
        template => "mine/delete"
    );
}

sub data {

    my $self = shift;

    $self->render( json => $self->deleteData->getData() );
}

1;
