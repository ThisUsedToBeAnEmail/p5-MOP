package MOP::Slot::Initializer;
# ABSTRACT: A representation of a class slot initializer

use strict;
use warnings;

use Carp ();

use UNIVERSAL::Object;

use MOP::Internal::Util;

our $VERSION   = '0.09';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        default  => sub {},
        required => sub {},
        # ... private
        _initializer => sub {},
    )
}

sub BUILDARGS {
    my $class = shift;
    my $args  = $class->SUPER::BUILDARGS( @_ );

    Carp::confess('Cannot have both a default and be required in the same initializer')
        if $args->{default} && $args->{required};

    return $args;
}

sub CREATE {
    my ($class, $args) = @_;

    my $code;
    if ( my $message = $args->{required} ) {
        $code = eval 'sub { die \''.$message.'\' }';
    }
    else {
        $code = $args->{default} || eval 'sub { undef }';
    }

    return $code;
}

sub BUILD {
    my ($self, $params) = @_;

    MOP::Internal::Util::SET_COMP_STASH_FOR_CV( $self, $params->{within_package} )
        if $params->{within_package};
}

1;

__END__

=pod

=head1 DESCRIPTION

Initializer objects for the MOP

=head1 CONSTRUCTORS

=over 4

=item C<new( %args )>

=back

=head1 METHODS

=over 4

=item C<to_code>

=back

=cut
