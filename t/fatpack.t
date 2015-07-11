use Test::More;
use Test::Mojo;
use Asset::Pack;
use Path::Tiny qw(path);

{
  package Test::MPAF;
  use Mojolicious::Lite;
  plugin 'Assets::FatPacked' => {namespace => 'Test::Asset'};
  app->start;
}

find_and_pack('test-data', 'Test::Asset', 'lib');

my $t = Test::Mojo->new;
# Test me harder
$t->get_ok('/assets/lavitanuova.txt')
  ->status_is(200)
  ->content_is(path('test-data/lavitanuova.txt')->slurp);

done_testing;
__END__
