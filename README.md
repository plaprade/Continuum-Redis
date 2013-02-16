# Continuum::Redis - Continuum wrapper for Mojo::Redis

Continuum::Redis is a
[Continuum](http://github.com/ciphermonk/Continuum) wrapper around the
asynchronous [Mojo::Redis](http://search.cpan.org/perldoc?Mojo::Redis) API. Continuum creates Portals on every
call, which are similar to [AnyEvent](http://search.cpan.org/perldoc?AnyEvent) condition variables but provide
a rich API for handling asynchronous operations.

```perl
    use Continuum::Redis;

    my $redis = Continuum::Redis->new( 
        server => '127.0.0.1:6379'
    );    

    # Blocking call
    my $value = $redis->get( $key )->recv;

    # Non-blocking call
    $redis->get( $key )->then( sub {
        my $value = shift;
    });

    #  Fetch 2 keys in parallel
    $redis->get( $key1 )
        ->merge( $redis->get( $key2 ) )
        ->then( sub {
            my ( $value1, $value2 ) = @_;
        });

    # Fetch list of keys in parallel
    portal( map { $redis->get( $_ ) } @keys )
        ->then( sub {
            my @values = @_;
        });
```

Please head to the [Continuum](http://github.com/ciphermonk/Continuum)
project page for more details. You can get a list of all the Redis
commands at [Mojo::Redis](http://search.cpan.org/perldoc?Mojo::Redis).

The `subscribe` call behaves in the same way as the `subscribe` call
in `Mojo::Redis`. It doesn't return a Portal. The same applies for
the `execute` call. This can be helpful if you need to bypass the
Portals for specific exceptions.

## Bugs

Please report any bugs in the projects bug tracker:

[http://github.com/ciphermonk/Continuum-Redis/issues](http://github.com/ciphermonk/Continuum-Redis/issues)

You can also submit a patch.

## Contributing

We're glad you want to contribute! It's simple:

- Fork Continuum::Redis
- Create a branch `git checkout -b my_branch`
- Commit your changes `git commit -am 'comments'`
- Push the branch `git push origin my_branch`
- Open a pull request

## Installation

This module depends on these other modules:

- [Moose](http://metacpan.org/module/Moose)
=item [Contnuum](https://github.com/ciphermonk/Continuum)
=item [Mojo::Redis](https://metacpan.org/module/Mojo::Redis)
=item [namespace::autoclean](https://metacpan.org/module/namespace::autoclean)

For testing:

- [EV](https://metacpan.org/module/EV)

## Supporting

Like what you see? You can support the project by donating in
[Bitcoins](http://www.weusecoins.com/) to:

__17YWBJUHaiLjZWaCyPwcV8CJDpfoFzc8Gi__
