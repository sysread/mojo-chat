=cut

TODO:
    -user name
    -time stamp on msg

=cut
use strict;
use warnings;

use Carp qw(carp cluck confess croak);
use Const::Fast;
use Mojolicious::Lite;
use Mojo::IOLoop;

const our $ROOM_DEFAULT => 'TheQuad';
const our $LINES_MAX    => 100;

my %ROOM = (
    $ROOM_DEFAULT => {
        title => 'Welcome to the Quad',
        lines => ['Welcome to the Quad!'],
    },
);

websocket '/chat' => sub {
    my $self = shift;
    my $room = $self->param('room') // $ROOM_DEFAULT;

    # Increase timeout for websocket connections
    Mojo::IOLoop->stream($self->tx->connection)->timeout(600);

    # Add push messages
    my $push_id;
    $push_id = Mojo::IOLoop->recurring(1 => sub {
        if (defined $self->tx && $self->tx->is_websocket) {
            $self->send({json => {
                title => $ROOM{$room}{title},
                lines => $ROOM{$room}{lines},
            }});
        } else {
            # Stop interval if websocket is disconnected
            Mojo::IOLoop->remove($push_id);
        }
    });

    $self->on(message => sub {
        my ($self, $msg) = @_;
        push @{$ROOM{$room}{lines}}, $msg;
        while (@{$ROOM{$room}{lines}} > $LINES_MAX) {
            shift @{$ROOM{$room}{lines}};
        }
    });
};

get '/' => sub {
    my $self  = shift;
    my $room  = $self->param('room') // $ROOM_DEFAULT;
    my $rooms = [keys %ROOM];

    $self->render(template => 'index',
        room  => $room,
        rooms => $rooms,
        title => $ROOM{$room}{title},
    );
};

app->start;
