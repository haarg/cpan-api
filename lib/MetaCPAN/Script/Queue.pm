package MetaCPAN::Script::Queue;

use strict;
use warnings;

use MetaCPAN::Queue ();
use MetaCPAN::Types qw( Dir File );
use Moose;
use Path::Iterator::Rule ();

has dir => (
    is        => 'ro',
    isa       => Dir,
    predicate => '_has_dir',
    coerce    => 1,
);

has file => (
    is        => 'ro',
    isa       => File,
    predicate => '_has_file',
    coerce    => 1,
);

has _minion => (
    is      => 'ro',
    isa     => 'Minion',
    lazy    => 1,
    handles => { _add_to_queue => 'enqueue', stats => 'stats', },
    default => sub { MetaCPAN::Queue->new->minion },
);

with 'MetaCPAN::Role::Script', 'MooseX::Getopt';

sub run {
    my $self = shift;

    if ( $self->_has_dir ) {
        my $rule = Path::Iterator::Rule->new;
        $rule->name(qr{\.(tgz|tbz|tar[\._-]gz|tar\.bz2|tar\.Z|zip|7z)\z});

        my $next = $rule->iter( $self->dir );
        while ( defined( my $file = $next->() ) ) {
            $self->_add_to_queue( index_release => [$file] );
        }
    }

    if ( $self->_has_file ) {
        $self->_add_to_queue( index_release => [ $self->file->stringify ] );
    }
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 SYNOPSIS

    bin/metacpan queue --file https://cpan.metacpan.org/authors/id/O/OA/OALDERS/HTML-Restrict-2.2.2.tar.gz
    bin/metacpan queue --dir /home/metacpan/CPAN/
    bin/metacpan queue --dir /home/metacpan/CPAN/authors/id
    bin/metacpan queue --dir /home/metacpan/CPAN/authors/id/R/RW/RWSTAUNER
    bin/metacpan queue --file /home/metacpan/CPAN/authors/id/R/RW/RWSTAUNER/Timer-Simple-1.006.tar.gz

=cut
