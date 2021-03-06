package TQApp::Controller::Media;
use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller' }

sub get_media {
    my ( $self, $c, $uuid ) = @_;
    my $media = try {
        $c->model('Media')->fetch( uuid => $uuid );
    }
    catch {
        $c->stash( template => '404.tt' );
        $c->res->status(404);
        return 0;
    } or return;
    if ($media->owner->guid ne $c->user->user->guid) {
        $c->stash( template => '403.tt' );
        $c->res->status(403);
        return 0;
    }
    return $media;
}

sub index : Path : Args(1) {
    my ( $self, $c, $uuid ) = @_;
    $c->authenticate( {}, "tqapp" );
    my $media = $self->get_media( $c, $uuid ) or return;
    $c->stash(
        user             => $c->user->user,
        media            => $media,
        template         => 'media/index.tt',
        has_media_player => TQ::Config::get_app_has_media_player(),
    );
}

sub player : Local : Args(1) {
    my ( $self, $c, $uuid ) = @_;
    $c->authenticate( {}, "tqapp" );
    my $media = $self->get_media( $c, $uuid ) or return;
    $c->stash(
        media        => $media,
        template     => 'media/player.tt',
        current_view => 'TTPlain',
    );
}

__PACKAGE__->meta->make_immutable;

1;
