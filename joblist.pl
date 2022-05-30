use Modern::Perl '2018';
BEGIN { $ENV{ PERL_JSON_BACKEND } = 'JSON::PP,JSON::XS'; }

use POSIX;
use JSON;
use File::Slurper qw(read_text write_text);
use Web::Query;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use lib '.';
use Helpers qw(trim ucEach);

use vars qw(%DEBUG %DEFAULTS);

#Set debug flags
$DEBUG{ "linkfile" } = 0;
$DEBUG{ "scrape" }   = 0;
$DEBUG{ "joblist" }  = 0;
$DEBUG{ "output" }   = 0;
$DEBUG{ "input" }    = 0;

#Defaults if scraping of the appropriate data fails
$DEFAULTS{ "wage" }  = 50000;
$DEFAULTS{ "hours" } = 40;
$DEFAULTS{ "rate" }  = ( 50000 / 52 ) / 40;
$DEFAULTS{ "flatfile" } =
  "public/json/apply.json";    #Flatfile we're adding new job listings to.

#Load in JSON flat file data
my $json = JSON->new();
$json->allow_nonref( 1 );
$json->canonical( 1 );

my $jobstr = "[]";

unless ( $DEBUG{ "input" } ) {

    $jobstr = read_text( $DEFAULTS{ "flatfile" } );
}

my $scalar = $json->decode( $jobstr );
my @jobs   = @$scalar;

#Lookup for if we've already scraped an application
my %exists = map { $_->{ 'link' } => 1 } @jobs;

my $base = qx(pwd);
chomp( $base );

#Scan for newly saved files
my @input = ();
my @dirs  = qw(ab bc mb nb nl ns nt nu on pe qc sk vr yt);
foreach my $dir ( @dirs ) {

    my @in = `ls public/APPLY/$dir/*.html 2>/dev/null`;
    chomp( @in );
    push( @input, @in );
}

my @files = ();

if ( $DEBUG{ "joblist" } ) {

    say Dumper( \@input );
}

foreach my $file ( @input ) {

    my $link = "file://" . $base . "/" . $file;

    say "LINK:$link" if ( $DEBUG{ "linkfile" } );
    say "FILE:$file" if ( $DEBUG{ "linkfile" } );

    my $hr = "Hiring Manager";

    if ( !$exists{ $link } ) {    #Continue processing if we have a new file.

        #Ensure the file is an html file.
        #TODO: new file listing doesn't drag in xhtml files, consider removing.
        if ( $file =~ /\.html/ ) {

            my $q    = Web::Query->new_from_file( $file );
            my $find = "";

            my $list = "";

            #Process file depending on the job board it came from.
            #TODO: jobbank.gc.ca is the only job board being processed now.
            #      Consider removing.
            if ( $file =~ /Job posting - Job Bank/ ) {

                $list = "jobbank.gc.ca";

                my @addressParts = ();

                #Data scraping - Generic
                my @selectors = (
                    "[property='addressLocality']",
                    "[property='addressRegion']",
                    "[property='streetAddress']",
                    "[property='postalCode']",
"span[property='hiringOrganization'] > span[property='name']",
                    "span[property='title']",
                    "[property='unitText']",
                    "[property='validThrough']",
                    "[property='minValue']",
                    "[property='maxValue']",
                    "[property='workHours']",
                    ".city"
                );
                my %scrape = map { $_ => "" } @selectors;

                foreach my $key ( keys( %scrape ) ) {

                    $scrape{ $key } = trim( $q->find( $key )->text() );
                    if ( !defined $scrape{ $key } ) {
                        $scrape{ $key } = "";
                    }
                    say "$key:$scrape{$key}" if $DEBUG{ "scrape" };
                }

                #TODO: Refactor this mess out and use %scrape directly.
                my $city = $scrape{ "[property='addressLocality']" };
                my $company =
                  $scrape{
"span[property='hiringOrganization'] > span[property='name']"
                  };
                my $ends     = $scrape{ "[property='validThrough']" };
                my $position = $scrape{ "span[property='title']" };
                my $postal   = $scrape{ "[property='postalCode']" };
                my ( $prov ) =
                  ( $scrape{ "[property='addressRegion']" } =~ /(.{2})$/ );
                my $street   = $scrape{ "[property='streetAddress']" };
                my $wageType = $scrape{ "[property='unitText']" };

                if ( !$city ) {
                    ( $city ) = ( $scrape{ ".city" } =~ /based in (.+),/ );
                }

                if ( !$prov ) {
                    ( $prov ) = ( $scrape{ ".city" } =~ /based in .+, (..)/ );
                }

                my $location = "$city, $prov";

                my $address =
                  trim( join( "\n", ( $street, $location, $postal ) ) );

                #Reference Number scraping.
                #Why couldn't they put a selector on the relevant tag...
                $find = "#howtoapply";
                my $hta_html   = $q->find( $find )->html();
                my $hta_text   = $q->find( $find )->text();
                my $howtoapply = "";
                if (   $hta_text
                    && $hta_text =~
                    /Include this reference number in your application/ )
                {
                    $hta_html =~ /application<\/h4>\s*?<p>(?<ref>.+?)<\/p>/;
                    $howtoapply = $+{ ref };
                }

                #Wage scraping and calculation

                #Common
                my ( $rate, $wage ) = ( 0, 0 );

                my $min     = $scrape{ "[property='minValue']" };
                my $max     = $scrape{ "[property='maxValue']" };
                my $str     = $scrape{ "[property='workHours']" };
                my @results = ( $str =~ /(\d+\.?\d*)/g );
                my $hours   = $results[ $#results ];

                #According to $wageType

                if ( !defined $wageType || $wageType eq "" ) {

                    #Account for the lack of information from external
                    #job boards.

                    $wageType = "HOUR";
                    $hours    = $DEFAULTS{ "hours" };
                    $max      = $DEFAULTS{ "rate" };
                }

                #Calculate Yearly earnings, Pay Rate, etc from scraped data.

                #HOURLY
                if ( $wageType eq 'HOUR' ) {

                    my $payPeriod = 52;

                    $rate = $min;
                    if ( $max ne "" ) {
                        $rate = $max;
                    }

                    if ( $str =~ /bi-weekly/i ) {
                        $rate  /= 2;
                        $hours /= 2;
                    }

                    $wage = $hours * $rate * $payPeriod;
                    say "Wage:$wage Hours:$hours Rate:$rate"
                      if ( $DEBUG{ "scrape" } );
                }

                #DAILY
                if ( $wageType eq 'DAY' ) {

                    my $payPeriod = 52;
                    my $payDays   = 5;

                    $rate = $min;
                    if ( $max ne "" ) {
                        $rate = $max;
                    }

                    if ( $str =~ /bi-weekly/i ) {
                        $rate  /= 2;
                        $hours /= 2;
                    }

                    my $dayHours = $hours / $payDays;
                    $rate = $rate / $dayHours;

                    $wage = $hours * $rate * $payPeriod;
                    say "Wage:$wage Hours:$hours Rate:$rate"
                      if ( $DEBUG{ "scrape" } );
                }

                #MONTHLY
                if ( $wageType eq 'MONTH' ) {

                    my $payPeriod = 12;
                    my $weeks     = 52;

                    $wage =~ s/,//;
                    $wage *= $payPeriod;

                    $rate = $wage / $weeks / $hours;
                    say "Wage:$wage Hours:$hours Rate:$rate"
                      if ( $DEBUG{ "scrape" } );
                }

                #YEARLY
                if ( $wageType eq 'YEAR' ) {

                    my $payPeriod = 52;

                    $wage = $min;
                    if ( $max ne "" ) {
                        $wage = $max;
                    }

                    $wage =~ s/,//;

                    $rate = $wage / $payPeriod / $hours;

                    if ( $str =~ /bi-weekly/i ) {
                        $rate  /= 2;
                        $hours /= 2;
                    }

                    say "Wage:$wage Hours:$hours Rate:$rate"
                      if ( $DEBUG{ "scrape" } );
                }

                $rate = sprintf( "%.2f", $rate );

                say "$file" if ( $DEBUG{ "linkfile" } );

                #Add data to output stream
                my %hash = (
                    "address"      => $address,
                    "applied"      => 0,
                    "applied_date" => "0000-00-00",
                    "city"         => $location,
                    "company"      => $company,
                    "ends"         => $ends,
                    "hours"        => $hours,
                    "hr_manager"   => $hr,
                    "link"         => $link,
                    "listing"      => $list,
                    "phone"        => "",
                    "position"     => $position,
                    "rate"         => $rate,
                    "reference"    => $howtoapply,
                    "tech"         => 0,
                    "wage"         => $wage,
                    "wagetype"     => $wageType
                );

                push( @files, \%hash );
            }
        }
    }
}

#Change Province/Territory abbreviation to full name.
my %fix = (
    ', ab$' => ', Alberta',
    ', bc$' => ', British Columbia',
    ', mb$' => ', Manitoba',
    ', nb$' => ', New Brunswick',
    ', nl$' => ', Newfoundland',
    ', ns$' => ', Nova Scotia',
    ', on$' => ', Ontario',
    ', pe$' => ', Prince Edward Island',
    ', qc$' => ', Quebec',
    ', sk$' => ', Saskatchewan',
    ', yt$' => ', Yukon',
    ', nt$' => ', Northwest Territories',
    ', nu$' => ', Nunavut'
);

foreach my $file ( @files ) {

    foreach my $key ( keys %fix ) {
        if ( $$file{ 'address' } =~ /$key/i ) {
            $$file{ 'address' } =~ s/$key/$fix{$key}/i;
        }
    }

    if ( !$$file{ 'listing' } ) {
        $$file{ 'listing' } = "jobbank.gc.ca";
    }
}

#Done get the results.
#Put already existing files into our output.
if ( $DEBUG{ "output" } ) {

    say $json->pretty->encode( [ @jobs, @files ] );
}
else {

    write_text( $DEFAULTS{ "flatfile" },
        $json->pretty->encode( [ @jobs, @files ] ) );
}
