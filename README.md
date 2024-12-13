[![Actions Status](https://github.com/raku-community-modules/Email-Notmuch/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Email-Notmuch/actions) [![Actions Status](https://github.com/raku-community-modules/Email-Notmuch/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Email-Notmuch/actions) [![Actions Status](https://github.com/raku-community-modules/Email-Notmuch/actions/workflows/windowst.yml/badge.svg)](https://github.com/raku-community-modules/Email-Notmuch/actions)

NAME
====

Email::Notmuch - Raku binding for NotmuchMail email database

SYNOPSIS
========

```raku
use Email::Notmuch;

my $database = Database.new('/home/goneri/Maildir');
my $query = Query.new($database, 'tag:todo');
my $messages = $query.search_messages();
for $messages.all() -> $message {
    say $message.get_header('from');
    $message.add_tag('seen');
    say $message.get_tags().all();
}
```

DESCRIPTION
===========

Notmuchmail ( https://notmuchmail.org/ ) is a mail indexation tool. This Raku module provides binding for a limited subset of its API.

The library has been tested with Notmuch 0.25 and greater, it does not work anymore with the older versions.

AUTHOR
======

Gonéri Le Bouder

COPYRIGHT AND LICENSE
=====================

Copyright 2015 - 2018 Gonéri Le Bouder

Copyright 2024 Raku Community

The project uses the GPLv3 or greater.

