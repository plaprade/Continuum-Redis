package Continuum::Redis;

use v5.14;

use Moose;
use namespace::autoclean;

use Continuum;
use Mojo::Redis;

use version; our $VERSION = version->declare("v0.0.2"); 

has redis => (
    is => 'ro',
    isa => 'Mojo::Redis',
);

sub BUILDARGS {
    my $self = shift;
    +{ redis => Mojo::Redis->new( @_ ) }
}

# Builds a Portal from a Redis call
# Usage: $redis->get( $key )->then( ... )
sub AUTOLOAD {
    my ( $self, @args ) = @_;
    my ( $method ) = our $AUTOLOAD =~ m/::(\w+)$/;
    $method =~ s/_//g;
    portal( sub {
        my $jump = $jump;
        $self->redis->$method( @args, sub {
            my ( $redis, @results ) = @_;
            $jump->( @results );
        })
    });
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 Continuum::Redis - Continuum wrapper for Mojo::Redis

Continuum::Redis is a
L<Continuum|http://github.com/ciphermonk/Continuum> wrapper around the
asynchronous L<Mojo::Redis> API. Continuum creates Portals on every
call, which are similar to L<AnyEvent> condition variables but provide
a rich API for handling asynchronous operations.

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

Please head to the L<Continuum|http://github.com/ciphermonk/Continuum>
project page for more details. You can get a list of all the Redis
commands at L<Mojo::Redis>.

=head2 Bugs

Please report any bugs in the projects bug tracker:

L<http://github.com/ciphermonk/Continuum-Redis/issues>

You can also submit a patch.

=head2 Contributing

We're glad you want to contribute! It's simple:

=over

=item * 
Fork Continuum::Redis

=item *
Create a branch C<git checkout -b my_branch>

=item *
Commit your changes C<git commit -am 'comments'>

=item *
Push the branch C<git push origin my_branch>

=item *
Open a pull request

=back

=head2 Supporting

Like what you see? You can support the project by donating in
L<Bitcoins|http://www.weusecoins.com/> to:

B<17YWBJUHaiLjZWaCyPwcV8CJDpfoFzc8Gi>

=cut

