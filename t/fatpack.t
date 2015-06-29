use Test::More;
use Test::Mojo;

{
  package Test::MPAF;
  use Mojolicious::Lite;
  plugin 'Assets::FatPacked' => {};
  app->start;
}

my $t = Test::Mojo->new;
# Test me harder
$t->get_ok('/')->status_is(200)->content_is('');
__END__

done_testing;