package Util::Chat;

use strict;
use warnings;
use Carp;
use Const::Fast;
use Time::HiRes qw(time);

use Util::Chat::Msg;

#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
const our $DEFAULT_TOPIC => 'No topic set';

#-------------------------------------------------------------------------------
# Class definition
#-------------------------------------------------------------------------------
use fields (
    'name',    # name of the chat room
    'topic',   # chat room topic
    'history', # max number of messages to retain
    'msgs',    # message buffer/queue
    'inbox',   # inboxate messages to the user (hash of name => [])
    'outbox',  # inboxate messages from the user (hash of name => [])
    'push',    # hash of name => marker to track last push
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
    $self->{inbox}   = {};
    $self->{outbox}  = {};
    $self->{push}    = {};

    return $self;
}

#-------------------------------------------------------------------------------
# Subscribes a name to a chat room.
#-------------------------------------------------------------------------------
sub subscribe {
    my ($self, $name) = @_;
    $self->{push}{$name}   = time;
    $self->{inbox}{$name}  = [];
    $self->{outbox}{$name} = [];
}

#-------------------------------------------------------------------------------
# Unsubscribes a person from the chat room.
#-------------------------------------------------------------------------------
sub unsubscribe {
    my ($self, $name) = @_;
    delete $self->{push}{$name};
    delete $self->{inbox}{$name};
    delete $self->{outbox}{$name};
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

    my @msgs = sort {$a->{ts} <=> $b->{ts}} (
        grep { $_->{ts} > $self->{push}{$name} } @{$self->{msgs}},
        @{$self->{inbox}{$name}},
        @{$self->{outbox}{$name}},
    );

    # Clear inboxate inbox
    $self->{inbox}{$name} = [];

    # Update push timestamp
    $self->{push}{$name} = time;

    return @msgs;
}

#-------------------------------------------------------------------------------
# Adds a message to the buffer, trimming any messages necessary to ensure the
# buffer does not grow beyond $self->{history} messages. If $target is
# specified, the message will be a inboxate message to the specified user.
# Croaks if the $target is not subscribed.
#-------------------------------------------------------------------------------
sub post {
    my ($self, $name, $line, $target) = @_;

    my $msg = Util::Chat::Msg->new(
        name   => $name,
        msg    => $line,
        ts     => time,
        target => $target,
    );

    if (defined $target) {
        if ($self->is_subscribed($target)) {
            push @{$self->{inbox}{$target}}, $msg;
            push @{$self->{outbox}{$name}}, $msg;
        } else {
            croak "User $target is not in the room.";
        }
    } else {
        push @{$self->{msgs}}, $msg;
        shift @{$self->{msgs}}
            while scalar(@{$self->{msgs}}) > $self->{history};
    }
}

1;
