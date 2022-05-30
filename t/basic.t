use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new( 'jobDatabase' );
$t->get_ok( '/' )->status_is( 200 );

#   A P P L I E D
$t->get_ok( '/applied' )->status_is( 200 );
$t->get_ok( '/json2/applied' )->status_is( 200 );

#   A P P L Y
$t->get_ok( '/apply' )->status_is( 200 );
$t->get_ok( '/json2/apply' )->status_is( 200 );

#   C A L E N D A R
$t->get_ok( '/calendar' )->status_is( 200 );
$t->get_ok( '/json2/calendar' )->status_is( 200 );

#   C O U N T S
$t->get_ok( '/counts' )->status_is( 200 );
$t->get_ok( '/json2/counts' )->status_is( 200 );

#   D E L E T E
$t->get_ok( '/delete' )->status_is( 200 );
$t->get_ok( '/json2/delete' )->status_is( 200 );

done_testing();
