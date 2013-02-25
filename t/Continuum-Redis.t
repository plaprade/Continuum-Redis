use strict;
use warnings;

use EV;
use Test::More;
use Data::Dumper;

BEGIN { 
    use_ok( 'Continuum::Redis' ); 
    use_ok( 'Continuum' ); 
};

my $redis = Continuum::Redis->new( 
    server => '127.0.0.1:6379'
);    

$redis->hset( _perl_test => 'a' => 13 )->recv;

cmp_ok( $redis->hget( _perl_test => 'a' )->recv, '==', 13,
    'hget and hset' );

$redis->hdel( _perl_test => 'a' )->recv;

is( $redis->hget( _perl_test => 'a' )->recv, undef,
    'hdel and hget' );

portal( map { 
    $redis->hset( _perl_test => $_ => $_ ) 
} 1..10 )->recv;

is_deeply(
    [ portal( 
        map { $redis->hget( _perl_test => $_ ) } 1..10 
    )->recv ],
    [ 1..10 ],
    'portal hget and hset',
);

portal( map { 
    $redis->hdel( _perl_test => $_ ) 
} 1..10 )->recv;

is_deeply(
    [ portal( 
        map { $redis->hget( _perl_test => $_ ) } 1..10 
    )->recv ],
    [ map { undef } 1..10 ],
    'portal hdel and hget',
);

$redis->del( '_perl_test' )->recv;

is( $redis->get( '_perl_test' )->recv, undef,
    'del and get _perl_test' );

my $cv = AnyEvent->condvar;

my $sub = $redis->subscribe( 'test_channel' );

$sub->on( message => sub {
    my ( $sub, $message, $channel ) = @_;
    is( $message, 'test_message',
        'subscribe channel' );
    is( $channel, 'test_channel',
        'test channel' );
    $cv->send;
});

# Wait to give time to subscribe
portal->wait( 1 )->then( sub {
    $redis->publish( test_channel => 'test_message' )
        ->then( sub {
            pass( 'publish succeeded' );
        });
})->recv;

$cv->recv;

done_testing();


