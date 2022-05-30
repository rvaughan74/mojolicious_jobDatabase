package jobDatabase::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

sub welcome {

    my $self = shift;

    # Render template "mine/welcome.html.ep" with message
    $self->render(
        template => "mine/welcome",
    );
}

1;
