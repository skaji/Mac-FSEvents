use strict;
use warnings;
use Test::More;

use Mac::FSEvents;
use Test::LeakTrace;

no_leaks_ok {
    my $fs = Mac::FSEvents->new(path => "/");
    my $fh = $fs->watch;
    $fs->stop;
};

done_testing;
