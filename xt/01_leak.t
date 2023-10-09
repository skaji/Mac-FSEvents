use strict;
use warnings;
use Test::More;

use Mac::FSEvents;
use Test::LeakTrace;
use File::Temp 'tempdir';
use IO::Select;

my $tempdir = tempdir CLEANUP => 1;

my $pid = fork // die;
if ($pid == 0) {
    for my $i (1..20) {
        select undef, undef, undef, 0.1;
        open my $fh, ">", "$tempdir/$i.txt" or die;
        print {$fh} "$i\n";
        close $fh;
    }
    exit;
}

no_leaks_ok {
    my $fs = Mac::FSEvents->new(path => $tempdir, latency => 0.1);
    my $fh = $fs->watch;
    my @fh = IO::Select->new($fh)->can_read;
    die if @fh != 1;
    my @event = $fs->read_events;
    $fs->stop;
};

wait;

done_testing;
