package jobDatabase;
use Mojo::Base 'Mojolicious';
use jobDatabase::Model::Applied;
use jobDatabase::Model::Apply;
use jobDatabase::Model::Calendar;
use jobDatabase::Model::Counts;
use jobDatabase::Model::Delete;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Load configuration from hash returned by config file
    my $config = $self->plugin( 'Config' );

    # Configure the application
    $self->secrets( $config->{ secrets } );

    #   M O D E L   H E L P E R S
    $self->helper(
        appliedData => sub {
            state $appliedData = jobDatabase::Model::Applied->new(
                filename => $config->{ applied_json },
                find     => $config->{ find },
                replace  => $config->{ applied_replace }
            );
        }
    );
    $self->helper(
        applyData => sub {
            state $applyData = jobDatabase::Model::Apply->new(
                filename => $config->{ apply_json },
                find     => $config->{ find },
                replace  => $config->{ apply_replace }
            );
        }
    );
    $self->helper(
        calendarData => sub {
            state $calendarData = jobDatabase::Model::Calendar->new(
                filename => $config->{ applied_json } );
        }
    );
    $self->helper(
        countData => sub {
            state $countData =
              jobDatabase::Model::Counts->new(
                filename => $config->{ apply_json } );
        }
    );
    $self->helper(
        deleteData => sub {
            state $deleteData = jobDatabase::Model::Delete->new(
                filename => $config->{ delete_json },
                find     => $config->{ find },
                replace  => $config->{ apply_replace }
            );
        }
    );

    # Router
    my $r = $self->routes;

    #   M A I N
    # Normal route to controller
    $r->get( '/' )->to( 'main#welcome' )->name( "root" );

    #   A P P L I E D
    $r->get( '/applied' )->to( 'applied#applied' )->name( "applied" );
    $r->get( '/json2/applied' )->to( 'applied#data' );

    #   A P P L Y
    $r->get( '/apply' )->to( 'apply#apply' )->name( "apply" );
    $r->get( '/json2/apply' )->to( 'apply#data' );

    #   C A L E N D A R
    $r->get( '/calendar' )->to( 'calendar#calendar' )->name( "calendar" );
    $r->get( '/json2/calendar' )->to( 'calendar#data' );

    #   C O U N T S
    $r->get( '/counts' )->to( 'counts#counts' )->name( "counts" );
    $r->get( '/json2/counts' )->to( 'counts#data' );

    #   D E L E T E
    $r->get( '/delete' )->to( 'delete#delete' );
    $r->get( '/json2/delete' )->to( 'delete#data' );
}

1;
