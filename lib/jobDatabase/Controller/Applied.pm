package jobDatabase::Controller::Applied;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub applied {

    my $self = shift;

    # Render template "mine/applied.html.ep" with message
    $self->render(
        template => "mine/applied"
    );
}

sub data {

    my $self = shift;

    $self->render( json => $self->appliedData->getData() );
}

1;
