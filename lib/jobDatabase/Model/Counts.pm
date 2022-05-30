package jobDatabase::Model::Counts;
use Mojo::Base -base;
use Mojo::JSON qw(decode_json);
use File::Slurper qw(read_text);

has "filename";

sub getData {

    my $self = shift;
    my $text = read_text( $self->filename );

    my %count = (
        "ns" => 0,
        "nb" => 0,
        "pe" => 0,
        "nl" => 0,
        "qc" => 0,
        "on" => 0,
        "mb" => 0,
        "sk" => 0,
        "ab" => 0,
        "bc" => 0,
        "yt" => 0,
        "nt" => 0,
        "nu" => 0,
        "vr" => 0,
    );

    my $scalar = decode_json( $text );

    foreach my $item ( @$scalar ) {
        if ( $$item{ "address" } =~ /, ns|, nova/i ) {
            $count{ "ns" }++;
        }
        if ( $$item{ "address" } =~ /, nb|, new/i ) {
            $count{ "nb" }++;
        }
        if ( $$item{ "address" } =~ /, pe|, prince/i ) {
            $count{ "pe" }++;
        }
        if ( $$item{ "address" } =~ /, nl|, newfoundland/i ) {
            $count{ "nl" }++;
        }
        if ( $$item{ "address" } =~ /, qc|, quebec/i ) {
            $count{ "qc" }++;
        }
        if ( $$item{ "address" } =~ /, on|, ontario/i ) {
            $count{ "on" }++;
        }
        if ( $$item{ "address" } =~ /, mb|, manitoba/i ) {
            $count{ "mb" }++;
        }
        if ( $$item{ "address" } =~ /, sk|, saskatchewan/i ) {
            $count{ "sk" }++;
        }
        if ( $$item{ "address" } =~ /, ab|, alberta/i ) {
            $count{ "ab" }++;
        }
        if ( $$item{ "address" } =~ /, bc|, british/i ) {
            $count{ "bc" }++;
        }
        if ( $$item{ "address" } =~ /, yt|, yukon/i ) {
            $count{ "yt" }++;
        }
        if ( $$item{ "address" } =~ /, nt|, northwest/i ) {
            $count{ "nt" }++;
        }
        if ( $$item{ "address" } =~ /, nu|, nunavut/i ) {
            $count{ "nu" }++;
        }
        if ( $$item{ "address" } =~ /, vr|, virtual/i ) {
            $count{ "vr" }++;
        }
    }

    return [
        {
            "province" => "Nova Scotia",
            "count"    => $count{ "ns" }
        },
        {
            "province" => "New Brunswick",
            "count"    => $count{ "nb" }
        },
        {
            "province" => "Prince Edward Island",
            "count"    => $count{ "pe" }
        },
        {
            "province" => "Newfoundland and Labradour",
            "count"    => $count{ "nl" }
        },
        {
            "province" => "Quebec",
            "count"    => $count{ "qc" }
        },
        {
            "province" => "Ontario",
            "count"    => $count{ "on" }
        },
        {
            "province" => "Manitoba",
            "count"    => $count{ "mb" }
        },
        {
            "province" => "Saskatchewan",
            "count"    => $count{ "sk" }
        },
        {
            "province" => "Alberta",
            "count"    => $count{ "ab" }
        },
        {
            "province" => "British Columbia",
            "count"    => $count{ "bc" }
        },
        {
            "province" => "Yukon Territory",
            "count"    => $count{ "yt" }
        },
        {
            "province" => "Northwest Territories",
            "count"    => $count{ "nt" }
        },
        {
            "province" => "Nunavut Territory",
            "count"    => $count{ "nu" }
        },
        {
            "province" => "Virtual Job",
            "count"    => $count{ "vr" }
        }
    ];
}

1;
