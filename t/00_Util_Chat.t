use strict;
use warnings;
use Test::More;
use Test::Mojo;


use_ok('Util::Chat')      or BAIL_OUT('unable to load Util::Chat');
use_ok('Util::Chat::Msg') or BAIL_OUT('unable to load Util::Chat::Msg');


subtest 'instantiation' => sub {
    eval { 'Util::Chat'->new };
    ok($@ =~ /expected parameter/, 'new fails with missing args');

    my $chat = new_ok('Util::Chat', [
        name    => 'Test',
        history => 4,
    ]);

    is($chat->{topic}, 'No topic set', 'topic gets default');
};

subtest 'subscription' => sub {
    my $chat = new_ok('Util::Chat', [
        name    => 'Test',
        history => 4,
    ]);

    $chat->subscribe('test');
    ok($chat->is_subscribed('test'), 'subscribe -> is_subscribed');
    is_deeply(['test'], [$chat->subscribed], 'subscribed');
};

subtest 'messages' => sub {
    my $chat = new_ok('Util::Chat', [
        name    => 'Test',
        history => 4,
    ]);

    $chat->subscribe('test 1');
    $chat->subscribe('test 2');

    $chat->post('test 1', 'hello');
    $chat->post('test 2', 'howdy');
    $chat->post('test 1', 'secret', 'test 2');

    ok(my @msgs1 = $chat->get_messages('test 1'), 'get_messages');
    is(scalar @msgs1, 2, 'get_messages');

    is($msgs1[0]->{msg}, 'hello', 'get_messages');
    is($msgs1[0]->{name}, 'test 1', 'get_messages');
    ok(defined $msgs1[0]->{ts}, 'get_messages');

    is($msgs1[1]->{msg}, 'howdy', 'get_messages');
    is($msgs1[1]->{name}, 'test 2', 'get_messages');
    ok(defined $msgs1[1]->{ts}, 'get_messages');

    # make sure no msgs come out again
    ok(!(@msgs1 = $chat->get_messages('test 1')), 'get_messages');

    ok(my @msgs2 = $chat->get_messages('test 2'), 'get_messages');
    is(scalar @msgs2, 3, 'get_messages');

    is($msgs2[0]->{msg}, 'hello', 'get_messages');
    is($msgs2[0]->{name}, 'test 1', 'get_messages');
    ok(defined $msgs2[0]->{ts}, 'get_messages');

    is($msgs2[1]->{msg}, 'howdy', 'get_messages');
    is($msgs2[1]->{name}, 'test 2', 'get_messages');
    ok(defined $msgs2[1]->{ts}, 'get_messages');

    is($msgs2[2]->{msg}, 'secret', 'get_messages');
    is($msgs2[2]->{name}, 'test 1', 'get_messages');
    is($msgs2[2]->{target}, 'test 2', 'get_messages');
    ok(defined $msgs2[2]->{ts}, 'get_messages');
};


done_testing;
