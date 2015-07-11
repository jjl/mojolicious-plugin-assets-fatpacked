package Mojolicious::Plugin::Assets::FatPacked;
use Mojo::Base 'Mojolicious::Plugin';
use Try::Tiny;

## ABSTRACT: A Mojolicious plugin that autoroutes assets Packed by C<Asset::Pack>

=head2 load_index($module) -> Hash

  Given a module name (e.g. MyApp::Asset) as a string, loads and returns the contained index

=cut

sub load_index {
  my ($module,) = @_;
  try {
    require $module;
    no strict 'refs';
    %{"${module}::index"}
  } catch {}
}

=head2 map_asset($module, $path, $r) -> Void

  Given a module name and a path, maps the path to the content in the module on r
  r is a C<Mojolicious::Routes> object.

=cut

sub map_asset {
  my ($app, $module, $path, $r) = @_;
  try {
    require $module;
    warn "path: $path";
    $r->get($path => sub {
      my ($c) = @_;
      no strict 'refs';
      $c->render(text => ${"${module}::content"});
    });
  } catch {
    warn "Failed to load asset $module: $_\n";
  }
}

=head2 register($self, $app, $conf) -> Void

  The hook called by Mojolicious to initialise us
  Registers routes for assets packed with Asset::Pack and saves the index
  to $app->{asset_index}

  conf options:
    - mountpount: url to mount the assets at. Default: /assets
    - namespace: module namespace / index module. Default: "${APP_NAME}::Asset"

=cut

sub register {
  my ($self, $app, $conf) = @_;
  warn "REGISTER-------------\n";
  my $prefix = $conf->{mountpoint} || '/assets';
  my $ns = $conf->{namespace} || ((ref $app) . "::Asset");
  my $r = Mojolicious::Routes->new;
  my %index = load_index($ns);
  warn "Running without an index because I couldn't find one.\n"
    unless (%index);
  $app->{asset_index} = {%index};
  while (my ($module, $path) = each %index) {
    map_asset($module, $path);
  }
  $r->under($prefix);
}

1;
__END__

=head1 SYNOPSIS

  

=head1 COPYRIGHT & LICENSE

Copyright (c) 2015 James Laver on time generously donated by Anomalio

This module is licensed under the same terms as perl itself

