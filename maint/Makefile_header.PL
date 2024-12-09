use strict;
use warnings;

use ExtUtils::Constant ();
use Config ();

if ($^O ne 'darwin') {
    die "OS unsupported\n";
}

my @c_name = qw(
    kFSEventStreamCreateFlagNone
    kFSEventStreamCreateFlagWatchRoot
    kFSEventStreamCreateFlagIgnoreSelf
    kFSEventStreamCreateFlagFileEvents
);

my @name;
for my $c_name (@c_name) {
    my $perl_name = $c_name;
    $perl_name =~ s/kFSEventStreamCreateFlag//; # strip off leading name
    $perl_name =~ s/([a-z])([A-Z])/"$1_$2"/ge;  # convert camel case to underscores
    $perl_name = uc $perl_name;                 # uppercase
    push @name, {
        name  => $perl_name,
        value => $c_name,
        macro => 1,
    };
}

ExtUtils::Constant::WriteConstants(
    NAME => 'Mac::FSEvents',
    NAMES => \@name,
);

my $lddlflags = join " ", grep { length $_ } (
    $Config::Config{lddlflags},
    "-framework CoreServices",
    "-framework CoreFoundation",
);

my %args = (
    LDDLFLAGS => $lddlflags,
);
