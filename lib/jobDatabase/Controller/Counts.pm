package jobDatabase::Controller::Counts;
use Mojo::Base 'Mojolicious::Controller';

sub counts {

    my $self = shift;

    # Render template "mine/counts.html.ep" with message
    $self->render(
        template => "mine/counts"
    );
}

sub data {

    my $self = shift;

    $self->render( json => $self->countData->getData() );
}

1;
