package Helpers;
use Modern::Perl '2018';
use Exporter;

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);

@EXPORT = qw(trim ucEach linksort);

sub trim {

    my $s = shift;
    if ( $s ) {

        $s =~ s/^\s+|\s+$//g;
        return $s;
    }
    return "";
}

sub ucEach {

    my $s   = shift;
    my $end = "";

    if ( $s =~ /\n/ ) {

        chomp( $s );
        $end = "\n";
    }

    my %correct = (
        "(it)"     => "(IT)",
        "Aaa"      => "AAA",
        "B.c."     => "B.C.",
        "B4u"      => "B4U",
        "Ek"       => "EK",
        "Inc."     => "Inc",
        "Iot"      => "IoT",
        "It"       => "IT",
        "Itd"      => "ITD",
        "Jst"      => "JST",
        "Llc"      => "LLC",
        "Ltd."     => "Ltd",
        "Mc"       => "MC",
        "Qa"       => "QA",
        "Rv"       => "RV",
        "Ulc"      => "ULC",
    );

    my $check = "^(" . join( "|", keys( %correct ) ) . ")\$";

    if ( $s ) {

        my @subresults = split( / /, $s );

        foreach my $token ( @subresults ) {

            $token = ucfirst( lc( $token ) );

            if ( $token =~ /$check/i ) {

                $token = $correct{ $token };
            }

            if ( $token =~ /(&|-)/ ) {

                my $delim = $1;

                my @parts = split( /$delim/, $token );
                $token = join( $delim, map( ucfirst( lc( $_ ) ), @parts ) )
                  if ( @parts );
            }

            if ( $token =~ /\((.+)/ && !( $token =~ /\(.+\)/ ) ) {
                $token = "(" . ucfirst lc $1;
            }
        }

        my $result = join( " ", @subresults );
        $result =~ s/as well as/as well as/i;

        return $result . $end;
    }
    return "";
}

sub linksort {

    lc( $$a{ 'link' } ) cmp lc( $$b{ 'link' } );
}

sub wagesort {

    $$a{ 'wage' } <=> $$b{ 'wage' }
      || lc( $$a{ 'company' } ) cmp lc( $$b{ 'company' } );
}

1;
