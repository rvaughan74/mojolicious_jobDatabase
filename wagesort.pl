use Modern::Perl '2018';

BEGIN { $ENV{ PERL_JSON_BACKEND } = 'JSON::PP,JSON::XS'; }

use POSIX;
use JSON;
use File::Slurper qw(read_text write_text);

use lib '.';
use Helpers qw(trim ucEach);

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use vars qw(%DEBUG %DEFAULTS %FILES);

#Set debug flags
$DEBUG{ "CALCULATE" } = 0;
$DEBUG{ "POSITION" }  = 0;
$DEBUG{ "TECH" }      = 0;
$DEBUG{ "FILTER" }    = 0;
$DEBUG{ "OUTPUT" }    = 0;

#DEFAULTS
$DEFAULTS{ "NOW" }       = time;
$DEFAULTS{ "NULL_DATE" } = "0000-00-00";
$DEFAULTS{ "PURGE" }     = { "INDEED" => 1, };
$DEFAULTS{ "MIN_WAGE" }  = 10000;

#Data Files
$FILES{ "APPLY_JSON" }   = "public/json/apply.json";
$FILES{ "APPLIED_JSON" } = "public/json/applied.json";
$FILES{ "DELETE_JSON" }  = "public/json/delete.json";
$FILES{ "TECH_JSON" }    = "public/json/tech.json";

sub dupCheck {

    my ( $check, @list ) = @_;
    my $comp = Dumper( $check );

    foreach my $item ( @list ) {

        if ( $comp eq Dumper( $item ) ) {

            return 1;
        }
    }

    return 0;
}

sub checkPass {

    my $in = shift;

    my $applyCheckPass = 1;
    my ( $year, $month, $day ) = split( '-', $$in{ 'ends' } );
    my @timeparts = ( 59, 59, 23, $day, $month - 1, $year - 1900 );

    if ( difftime( mktime( @timeparts ), $DEFAULTS{ "NOW" } ) < 0 ) {

        return 0;
    }

    if ( $applyCheckPass && $$in{ 'wage' } < $DEFAULTS{ "MIN_WAGE" } ) {

        return 0;
    }

    if ( $DEFAULTS{ "PURGE" }{ "INDEED" } && $$in{ 'listing' } eq "Indeed.com" )
    {

        return 0;
    }

    return 1;
}

my %TECH = ();

my $json = JSON->new();
$json->allow_nonref( 1 );
$json->canonical( 1 );

my $appliedstr = read_text( $FILES{ "APPLIED_JSON" } );
my $jobstr     = read_text( $FILES{ "APPLY_JSON" } );
my $delstr     = read_text( $FILES{ "DELETE_JSON" } );
my $techstr    = read_text( $FILES{ "TECH_JSON" } );

my $scalar   = "";
my @apply    = ();
my @applied  = ();
my @delete   = ();
my @sorted   = ();
my @unsorted = ();
my @jobs     = ();
my @fields   = qw(company ends applied rate hours wage phone link);

$scalar  = $json->decode( $appliedstr );
@applied = @$scalar;
$scalar  = $json->decode( $jobstr );
@jobs    = @$scalar;
$scalar  = $json->decode( $delstr );
@delete  = @$scalar;
$scalar  = $json->decode( $techstr );
%TECH    = %$scalar;

foreach my $job ( @jobs ) {

    if ( !$$job{ 'wage' } || $$job{ 'wage' } eq "0.00" ) {

        $$job{ 'wage' } = $$job{ 'rate' } * $$job{ 'hours' } * 52;
        say "WAGE:$$job{'company'}\tWage:$$job{'wage'}\tRate:$$job{'rate'}"
          if $DEBUG{ "CALCULATE" };
    }
    else {
        $$job{ 'rate' } =
          sprintf( "%.2f", $$job{ 'wage' } / $$job{ 'hours' } / 52 );

        say "WAGE:$$job{'company'}\tWage:$$job{'wage'}\tRate:$$job{'rate'}"
          if $DEBUG{ "CALCULATE" };
    }

    $$job{ 'company' } = ucEach( $$job{ 'company' } );

    if ( !$$job{ 'position' } ) {

        $$job{ 'position' } = "Example";
        say "POSITION:$$job{ 'position' }" if $DEBUG{ "POSITION" };
    }
    else {

        $$job{ 'position' } = join( " ", ucEach( $$job{ 'position' } ) );
        say "POSITION:$$job{ 'position' }" if $DEBUG{ "POSITION" };

        if ( $$job{ 'position' } eq "Developer, Software" ) {

            $$job{ 'position' } = "Software Developer";
        }

        if ( $$job{ 'position' } eq "Game Developer, Computer" ) {

            $$job{ 'position' } = "Computer Game Developer";
        }

        if ( $$job{ 'position' } eq "Programmer, Web" ) {

            $$job{ 'position' } = "Web Programmer";
        }

        say "POSITION:$$job{ 'position' }" if $DEBUG{ "POSITION" };
    }

    if ( !$$job{ 'reference' } ) {

        $$job{ 'reference' } = "";
    }

    if ( !$$job{ 'tech' } ) {

        $$job{ 'tech' } = 0;

        if ( $TECH{ $$job{ 'position' } } ) {

            $$job{ 'tech' } = 1;
        }
    }
    say "TECH:$$job{ 'tech' }" if $DEBUG{ "TECH" };

    #Filter into appropriate list
    if (   $$job{ 'applied' }
        || $$job{ 'applied_date' } ne $DEFAULTS{ "NULL_DATE" } )
    {

        #If applied to the job filter to applied list only.
        say "APPLIED" if $DEBUG{ "FILTER" };

        if (   $$job{ 'applied' }
            && $$job{ 'applied_date' } eq $DEFAULTS{ "NULL_DATE" } )
        {

            #If applied to with no date set, set the date to NOW.

            my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )
              = localtime( $DEFAULTS{ "NOW" } );
            $year += 1900;
            $mon++;
            $mon  = sprintf( "%02d", $mon );
            $mday = sprintf( "%02d", $mday );
            $$job{ 'applied_date' } = "$year-$mon-$mday";
            say "APPLIED:$$job{ 'applied_date' }" if $DEBUG{ "FILTER" };
        }
        $$job{ 'applied' } = 1;    #Ensure applied is true...
        push( @applied, $job );
    }
    else {

        #Check if we need to add to the delete list

        if ( checkPass( $job ) && !dupCheck( $job, @apply ) ) {

            push( @apply, $job );
            say "APPLY" if $DEBUG{ "FILTER" };
        }
        else {

            push( @delete, $job );
            say "DELETE" if $DEBUG{ "FILTER" };
        }
    }
}

#Ensure all floating point fields are set to %.2f
foreach my $job ( @apply, @applied, @delete ) {

    $$job{ 'wage' }  = sprintf( "%.2f", $$job{ 'wage' } );
    $$job{ 'rate' }  = sprintf( "%.2f", $$job{ 'rate' } );
    $$job{ 'hours' } = sprintf( "%.2f", $$job{ 'hours' } );

    if ( !$$job{ 'city' } ) {
        $$job{ 'city' } = $$job{ 'address' };
    }

    if ( !$$job{ 'ends' } ) {
        $$job{ 'ends' } = "";
    }
}

#Convert data structures to JSON
my $applied_str = $json->pretty->encode( \@applied );
my $apply_str   = $json->pretty->encode( \@apply );
my $delete_str  = $json->pretty->encode( \@delete );

if ( $DEBUG{ "OUTPUT" } ) {

    say "APPLIED:$applied_str\n";
    say "APPLY:$apply_str\n";
    say "DELETE:$delete_str";
}
else {

    #Data Storage

    write_text( $FILES{ "APPLIED_JSON" }, $applied_str );
    write_text( $FILES{ "APPLY_JSON" },   $apply_str );
    write_text( $FILES{ "DELETE_JSON" },  $delete_str );
}
