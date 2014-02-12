use strict;
use warnings;

use Mojolicious::Lite;
use Mojolicious::Plugin::TtRenderer;
use Mojo::IOLoop;
use Const::Fast;

use Util::Chat;

#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
const our $DEFAULT_HISTORY => 100;

#-------------------------------------------------------------------------------
# Plugins
#-------------------------------------------------------------------------------
plugin 'tt_renderer' => {
    template_options => {
        PRE_CHOMP  => 1,
        POST_CHOMP => 1,
        TRIM       => 1,
        DEBUG      => 1,
    },
};

#-------------------------------------------------------------------------------
# App configuration
#-------------------------------------------------------------------------------
app->secrets(['how now brown bureaucrat']);
app->renderer->default_handler('tt');

#-------------------------------------------------------------------------------
# Globals
#-------------------------------------------------------------------------------
my %CHAT = (
    'The Quad' => Util::Chat->new(
        name    => 'The Quad',
        topic   => 'Welcome to the Quad!',
        history => $DEFAULT_HISTORY,
    ),
);

#-------------------------------------------------------------------------------
# Main entrance; asks for name and offers selection of rooms.
#-------------------------------------------------------------------------------
get '/' => sub {
    my $self = shift;
    $self->render('index', rooms => [keys %CHAT]);
};

#-------------------------------------------------------------------------------
# Validates user's name and room, then redirects.
#-------------------------------------------------------------------------------
post '/' => sub {
    my $self = shift;
    my $name = $self->param('name');
    my $room = $self->param('room');

    my @errors;
    push @errors, 'Please enter your name.'     unless $name;
    push @errors, 'Invalid name.'               unless $name ne 'system';
    push @errors, 'Please select a chat room.'  unless $room;
    push @errors, 'That room does not exist.'   unless $room && exists $CHAT{$room};
    push @errors, 'That name is already taken.' if $name && $room && $CHAT{$room}->is_subscribed($name);

    if (@errors) {
        $self->render('index', rooms => [keys %CHAT], errors => \@errors);
    } else {
        # Set the user's name for the selected chat room
        $self->session->{chats} ||= {};
        $self->session->{chats}{$room} = {name => $name};
        $self->redirect_to("/room/$room");
    }
};

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
get '/room/:room' => sub {
    my $self = shift;
    my $room = $self->stash('room');

    unless ($room && exists $CHAT{$room}) {
        $self->render('does_not_exist');
        return;
    }

    my $name = $self->session->{chats}{$room}{name}
        or return $self->redirect_to('/');

    # Subscribe user to chatroom
    $CHAT{$room}->subscribe($name);

    # Construct websocket URL
    my $scheme = $self->req->is_secure ? 'wss' : 'ws';
    my $path   = "/chat/$room/";
    my $url    = $self->req->url->to_abs->scheme($scheme)->path($path);

    $self->render('chat',
        name  => $name,
        url   => "$url",
        room  => $room,
        topic => $CHAT{$room}->{topic},
        users => [ $CHAT{$room}->subscribed ],
    );
};

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
websocket '/chat/:room' => sub {
    my $self = shift;
    my $room = $self->stash('room');

    die 'room not round'
        unless $room && exists $CHAT{$room};

    my $name = $self->session->{chats}{$room}{name}
        or die 'not logged in';

    my $chat = $CHAT{$room};
    $chat->post('system', "$name has entered the room.");

    # Increase timeout for websocket connections
    Mojo::IOLoop->stream($self->tx->connection)->timeout(600);

    my $thread = Mojo::IOLoop->recurring(1 => sub {
        # Send updates
        my @messages = $chat->get_messages($name);
        my @users    = $chat->subscribed;
        my $topic    = $chat->{topic};

        $self->send({
            json => {
                msgs  => [ map { {%$_} } @messages ],
                users => [ @users ],
                topic => $topic,
                room  => $room,
            }
        });
    });

    $self->on(message => sub {
        my ($self, $msg) = @_;
        $chat->post($name, $msg);
    });

    $self->on(finish => sub {
        my ($self, $code, $reason) = @_;
        Mojo::IOLoop->remove($thread);
        $chat->unsubscribe($name);
        $chat->post('system', "$name left the room.");
    });
};

#-------------------------------------------------------------------------------
# Run the app
#-------------------------------------------------------------------------------
app->start;
