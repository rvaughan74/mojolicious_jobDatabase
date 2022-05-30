package jobDatabase::Controller::Calendar;
use Mojo::Base 'Mojolicious::Controller';

sub calendar {

    my $self = shift;

    # Render template "mine/calendar.html.ep" with message
    $self->render(
        template => "mine/calendar"
    );
}

sub data {

    my $self = shift;

    $self->render( json => $self->calendarData->getData() );
}

1;
