=cut

TODO:
    -user name
    -time stamp on msg

=cut
use strict;
use warnings;

use Const::Fast;
use Mojolicious::Lite;
use Mojo::IOLoop;
use JSON::XS;

const our $ROOM_DEFAULT => 'TheQuad';
const our $LINES_MAX    => 100;

my %ROOM = (
    $ROOM_DEFAULT => {
        title => 'Welcome to the Quad',
        lines => [
            { time => time, msg => 'Welcome to the Quad!' },
        ],
    },
);

websocket '/chat' => sub {
    my $self = shift;
    my $room = $self->param('room') // $ROOM_DEFAULT;
    my $json = JSON::XS->new();

    # Increase timeout for websocket connections
    Mojo::IOLoop->stream($self->tx->connection)->timeout(600);

    # Add push messages
    my $push_id;
    $push_id = Mojo::IOLoop->recurring(1 => sub {
        if (defined $self->tx && $self->tx->is_websocket) {
            # Send message updates
            $self->send({json => {
                title => $ROOM{$room}{title},
                lines => $ROOM{$room}{lines},
            }});
        } else {
            # Stop interval if websocket is disconnected
            Mojo::IOLoop->remove($push_id);
        }
    });

    # Install message handler for websocket
    $self->on(message => sub {
        my ($self, $data) = @_;
        my $msg = eval { $json->decode($data) };

        if ($@) {
            warn $@;
            $self->send({json => { error => 'There was an error decoding your message.' }});
        } else {
            $self->send({json => { error => 0 }});
            push @{$ROOM{$room}{lines}}, {
                msg  => $msg->{msg},
                time => ($msg->{time} // time),
            };

            while (@{$ROOM{$room}{lines}} > $LINES_MAX) {
                shift @{$ROOM{$room}{lines}};
            }
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
