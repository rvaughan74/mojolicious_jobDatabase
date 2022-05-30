package jobDatabase::Model::Calendar;
use Mojo::Base -base;
use Mojo::JSON qw(decode_json);
use File::Slurper qw(read_text);

has "filename";

sub getData {

    my $self = shift;
    my $text = read_text( $self->filename );

    my $scalar = decode_json( $text );
    my @arr =
      map( { "title" => $_->{ "company" }, "start" => $_->{ "applied_date" } },
        @$scalar );

    return \@arr;
}

1;
