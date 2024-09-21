use strict;
use warnings;

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

load_module('Dist::Build::XS');
load_module('Dist::Build::XS::WriteConstants');

my @extra_compiler_flag = (
    '-Wall',
    '-Wextra',
    '-Werror',
    '-Wno-error=deprecated-declarations',
);

add_xs(
    write_constants => { NAMES => \@name },
    extra_compiler_flags => -d ".git" ? \@extra_compiler_flag : [],
    extra_linker_flags => [qw(-framework CoreServices -framework CoreFoundation)],
);
