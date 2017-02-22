package Algorithm::LimitedRate::Simple;
use strict;

=head1 NAME

Algorithm::LimitedRate::Simple - Very simple rate limiting

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use Time::HiRes qw(time sleep);

=head1 DESCRIPTION

Simple rate limiting class

=head1 SYNOPSIS

    use Algorithm::LimitedRate::Simple;

    my $limiter = Algorithm::LimitedRate::Simple->new({rate=>120});

    while ( .. ) {
      $limiter->apply_rate_limit();
      ... stuff ...
    }

    $limiter->finished;

    my $rate_achieved = $limiter->actual_rate;
    print "rate : $rate_achieved";

=head1 ATTRIBUTES

=head2 rate

Maximum rate per minute, required.

For less than 1 per minute, can be floating point

=head2 sample_rate

Sampling rate (calls between checks), optional. Default 10.

=cut

has rate => (
    required => 1,
    is => 'ro'
);

has sample_rate => (
    is => 'ro',
    lazy => 1,
    default => '10'
);

has _last_tick => (
    is => 'rw',
    lazy => 1,
    default => sub { time() }
);

has _start_time => (
    is => 'rw',
    lazy => 1,
    default => sub { time() }
);

has _count_since_start => (
    is => 'rw',
    lazy => 1,
    default => sub { 0 }
);

has _count_since_tick => (
    is => 'rw',
    lazy => 1,
    default => sub { 0 }
);

=head1 METHODS

=head2 new

Class constructor method, takes hashref of attributes, returns object.

=head2 apply_rate_limit

Object method, check rate, blocking wait if over limit.

=cut

sub apply_rate_limit {
    my $self = shift;
    my $wait = 0;
    $self->_count_since_tick($self->_count_since_tick + 1);
    my $duration = time() - $self->_last_tick;
    if ($duration > 60) {
        my $excess_duration = int($duration / 60) ;
        warn "excess duration : $excess_duration";
        $duration -= 60 * $excess_duration;
        $self->_count_since_tick($self->_count_since_tick - (int($self->rate * $excess_duration)) );
        $self->_last_tick($self->_last_tick + (60 * $excess_duration) );
        $self->_count_since_tick(0) if ($self->_count_since_tick < 1 );
    }

    my $current_rate = 0;
    if ($duration) {
        $current_rate = ( $self->_count_since_tick / $duration ) * 60;
    }

    if ($self->_count_since_tick > $self->sample_rate or $duration > 5) {
        if ($current_rate > $self->rate) {
            my $rate_limit = ( $self->rate / 60 ) * $duration;
            my $excess_count = $self->_count_since_tick - $rate_limit;
            $wait += $excess_count / ( $self->rate / 60 );
        }
    }

    if ($wait) {
        sleep $wait;
        $self->_tick_reset;
    }

    if ( ( time() - $self->_last_tick ) > 60) {
        $self->_tick_reset;
    }

    return;
}

=head2 actual_rate

Object accessor method.

Returns current rate achieved since last tick, call finished at end to ensure final sample taken.

=cut

sub actual_rate {
    my $self = shift;
    my $duration = time() - $self->_start_time;
    my $rate = ( $self->_count_since_start / $duration ) * 60;
    return $rate;
}

=head2 finished

Object mutator method, tell the object to take final sample, and update actual rate.

=cut

sub finished {
    shift->_tick_reset;
}

####

sub _tick_reset {
    my $self = shift;
    $self->_count_since_start($self->_count_since_start + $self->_count_since_tick);
    $self->_count_since_tick(0);
    $self->_last_tick(time());
}

=head1 AUTHOR

Aaron Trevena, C<< <teejay at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-algorithm-limitedrate-simple at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Algorithm-LimitedRate-Simple>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::LimitedRate::Simple


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-LimitedRate-Simple>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-LimitedRate-Simple>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-LimitedRate-Simple>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-LimitedRate-Simple/>

=item * Github

L<https://github.com/hashbangperl/Algorithm-LimitedRate-Simple/>

=back

=head1 SEE ALSO

=over 4

=item Algorithm::FloodControl

=item Algorithm::LeakyBucket

=item Sub::Throttle

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Aaron Trevena.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Algorithm::LimitedRate::Simple
