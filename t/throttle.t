#!perl
use strict;
use Test::More;
use lib qw(lib);

use Algorithm::LimitedRate::Simple;
use Time::HiRes qw(time usleep);

my $test_options = {
    very_fast => {
        rate => 360,
        sample_rate => 20,
        row_count => 1200
    },
    fast => {
        rate => 120,
        row_count => 900
    },
    medium => {
        rate => 70,
        row_count => 400
    },
    slow_default_sample => {
        rate => 20,
        sample_rate => 10,
        row_count => 200
    },
    slow_default_sample => {
        rate => 20,
        row_count => 200
    },
};


foreach my $test (keys %$test_options) {
    my $i = 0;
    my $options = $test_options->{$test};
    my $limiter = Algorithm::LimitedRate::Simple->new({
        rate => $options->{rate},
        ( $options->{sample_rate} ? ( sample_rate => $options->{sample_rate} ) : ( ) )
    });
    my $set_rate = $options->{rate};
    my $start_time = time();
    while ($i++ < $options->{row_count}) {
        my $row = get_row();
        if ($i % 100 == 0) {
            my $duration = time() - $start_time ;
            my $cur_rate = ($duration ? ($i / $duration  ) * 60 : ( '-' ) );
            ok($cur_rate < $set_rate, 'rate is less than limit');
            ok($cur_rate >= $set_rate * 0.95, 'rate is within 5% of limit' )
        }
        $limiter->apply_rate_limit();
    }
    $limiter->finished;
    ok($limiter->actual_rate < $set_rate, 'rate is less than limit');
    ok($limiter->actual_rate >= $set_rate * 0.95, 'rate is within 5% of limit' )
}

done_ok();

sub get_row {
    my $row = '';
    foreach (0..19) { $row .= "dfsfjksdfhksdjf".$$.time() }
    usleep(45000);
    return $row;
}
