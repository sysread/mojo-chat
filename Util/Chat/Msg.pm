#-------------------------------------------------------------------------------
# Structure holding an individual chat message.
#-------------------------------------------------------------------------------
package Util::Chat::Msg;

use strict;
use warnings;
use Carp;

use fields (
    'ts',     # time stamp
    'name',   # name
    'msg',    # message text
    'target', # recipient
);

sub new {
    my ($class, %param) = @_;
    my $ts     = $param{ts}   || time;
    my $name   = $param{name} || croak 'expected parameter "name"';
    my $msg    = $param{msg}  || croak 'expected parameter "msg"';
    my $target = $param{target};

    my $self = fields::new($class);
    $self->{ts}     = $ts;
    $self->{name}   = $name;
    $self->{msg}    = $msg;
    $self->{target} = $target;

    return $self;
}

1;
