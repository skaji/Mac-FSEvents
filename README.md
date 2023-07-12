[![Actions Status](https://github.com/skaji/Mac-FSEvents/actions/workflows/test.yml/badge.svg)](https://github.com/skaji/Mac-FSEvents/actions)

# NAME

Mac::FSEvents - Monitor a directory structure for changes

# SYNOPSIS

    use Mac::FSEvents;

    my $fs = Mac::FSEvents->new(
        path          => '/',         # required, the path(s) to watch
                                      # optionally specify an arrayref of multiple paths
        latency       => 2.0,         # optional, time to delay before returning events
        since         => 451349510,   # optional, return events from this eventId
        watch_root    => 1,           # optional, fire events if the watched path changes
        ignore_self   => 1,           # optional, ignore events from this process
        file_events   => 1,           # optional, fire events on files instead of dirs
    );
    ### OR
    my $fs = Mac::FSEvents->new( '/' ); # Only specify the path

    my $fh = $fs->watch;

    # Select on this filehandle, or use an event loop:
    my $sel = IO::Select->new($fh);
    while ( $sel->can_read ) {
        my @events = $fs->read_events;
        for my $event ( @events ) {
            printf "Directory %s changed\n", $event->path;
        }
    }

    # or use blocking polling:
    while ( my @events = $fs->read_events ) {
        ...
    }

    # stop watching
    $fs->stop;

# DESCRIPTION

This module implements the FSEvents API present in Mac OSX 10.5 and later.
It enables you to watch a large directory tree and receive events when any
changes are made to directories or files within the tree.

Event monitoring occurs in a separate C thread from the rest of your application.

# METHODS

- **new** ( { ARGUMENTS } )
- **new** ( ARGUMENTS )
- **new** ( PATH )

    Create a new watcher. `ARGUMENTS` is a hash or hash reference with the following keys:

    - path

        Required. A plain string or arrayref of strings of directories to watch. All
        subdirectories beneath these directories are watched.

    - latency

        Optional.  The number of seconds the FSEvents service should wait after hearing
        about an event from the kernel before passing it along.  Specifying a larger value
        may result in fewer callbacks and greater efficiency on a busy filesystem.  Fractional
        seconds are allowed.

        Default: 2.0

    - since

        Optional.  A previously obtained event ID may be passed as the since argument.  A
        notification will be sent for every event that has happened since that ID.  This can
        be useful for seeing what has changed while your program was not running.

    - ignore\_self

        (Only available on OS X 10.6 or greater)

        Don't send events triggered by the current process. Useful if you are also modifying
        files in the watch list.

    - file\_events

        (Only available on OS X 10.7 or greater)

        Send events for files. By default, only directory-level events are generated,
        and may be coelesced if they happen simultaneously. With this flag, an event
        will be generated for every change to a file.

    - watch\_root

        Request notifications if the location of the paths being watched change. For example,
        if there is a watch for `/foo/bar`, and it is renamed to `/foo/buzz`, an event will
        be generated with the `root_changed` flag set.

    - flags

        Optional.  Sets the flags provided to [FSEventStreamCreate](https://metacpan.org/pod/FSEventStreamCreate).  In order to
        import the flag constants, you must provide `:flags` to `use Mac::FSEvents`.

        This method of setting flags is discouraged in favor of using the constructor argument,
        above.

        The following flags are supported:

        - NONE

            No flags. The default.

        - WATCH\_ROOT

            Set by the `watch_root` constructor argument.

        - IGNORE\_SELF

            Set by the `ignore_self` constructor argument.

        - FILE\_EVENTS

            Set by the `file_events` constructor argument.

- **watch**

    Begin watching.  Returns a filehandle that may be used with select() or the event loop
    of your choice.

- **read\_events**

    Returns an array of pending events.  If using an event loop, this method should be
    called when the filehandle becomes ready for reading.  If not using an event loop,
    this method will block until an event is available.

    Events are returned as [Mac::FSEvents::Event](https://metacpan.org/pod/Mac%3A%3AFSEvents%3A%3AEvent) objects.

    **NOTE:** Event paths are real file system paths, with all the symbolic links
    resolved. If you are watching a path with a symbolic link, use ["abs\_path" in Cwd](https://metacpan.org/pod/Cwd#abs_path)
    if you need to make comparisons against the event's path.

- **stop**

    Stop watching.

# SEE ALSO

http://developer.apple.com/documentation/Darwin/Conceptual/FSEvents\_ProgGuide

# AUTHOR

Andy Grundman, <andy@hybridized.org>

# COPYRIGHT AND LICENSE

Copyright (C) 2009 by Andy Grundman

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.
