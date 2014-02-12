#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
package Chat;

use strict;
use warnings;
use Carp;
use Const::Fast;
use Time::HiRes qw(time);

#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
const our $DEFAULT_TOPIC => 'No topic set';

#-------------------------------------------------------------------------------
# Class definition
#-------------------------------------------------------------------------------
use fields (
    'name',     # name of the chat room
    'topic',    # chat room topic
    'history',  # max number of messages to retain
    'msgs',     # message buffer/queue
    'push',     # hash of name => marker to track last push
);

#-------------------------------------------------------------------------------
# Constructor
#-------------------------------------------------------------------------------
sub new {
    my ($class, %param) = @_;
    my $name    = $param{name}    || croak 'expected parameter "name"';
    my $history = $param{history} || croak 'expected parameter "history"';
    my $topic   = $param{topic}   || $DEFAULT_TOPIC;

    my $self = fields::new($class);
    $self->{name}    = $name;
    $self->{topic}   = $topic;
    $self->{history} = $history;
    $self->{msgs}    = [];
    $self->{push}    = {};

    return $self;
}

#-------------------------------------------------------------------------------
# Subscribes a name to a chat room.
#-------------------------------------------------------------------------------
sub subscribe {
    my ($self, $name) = @_;
    $self->{push}{$name} = time;
}

#-------------------------------------------------------------------------------
# Unsubscribes a person from the chat room.
#-------------------------------------------------------------------------------
sub unsubscribe {
    my ($self, $name) = @_;
    delete $self->{push}{$name};
}

#-------------------------------------------------------------------------------
# Returns true if the name is subscribed.
#-------------------------------------------------------------------------------
sub is_subscribed {
    my ($self, $name) = @_;
    return exists $self->{push}{$name};
}

#-------------------------------------------------------------------------------
# Returns the list of currently subscribed names.
#-------------------------------------------------------------------------------
sub subscribed {
    my $self = shift;
    return sort keys %{$self->{push}};
}

#-------------------------------------------------------------------------------
# Returns messages that have not yet been seen by the name and updates the
# name's push marker.
#-------------------------------------------------------------------------------
sub get_messages {
    my ($self, $name) = @_;
    $self->subscribe($name) unless $self->is_subscribed($name);
    my @msgs = grep { $_->{ts} > $self->{push}{$name} } @{$self->{msgs}};
    $self->{push}{$name} = time;
    return @msgs;
}

#-------------------------------------------------------------------------------
# Adds a message to the buffer, trimming any messages necessary to ensure the
# buffer does not grow beyond $self->{history} messages.
#-------------------------------------------------------------------------------
sub post {
    my ($self, $name, $line) = @_;
    my $msg = Chat::Msg->new(name => $name, msg => $line, ts => time);
    push @{$self->{msgs}}, $msg;
    shift @{$self->{msgs}}
        while scalar(@{$self->{msgs}}) > $self->{history};
}

1;
