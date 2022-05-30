package jobDatabase::Model::Delete;
use Mojo::Base -base;
use Mojo::JSON qw(decode_json);
use File::Slurper qw(read_text);

has "filename";    # => (is => 'ro', isa => 'Str');
has "find";        # => (is => 'ro', isa => 'Str');
has "replace";     # => (is => 'ro', isa => 'Str');

sub getData {

    my $self = shift;
    my $text = read_text( $self->filename );

    if ( $text =~ /file:\/\/\// ) {

        my $find    = $self->find;
        my $replace = $self->replace;
        $text =~ s/$find/$replace/g;
    }

    my $out = decode_json( $text );
    return $out;
}

1;
