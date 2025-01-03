use nqp;
use NativeCall;

constant NOTMUCH_STATUS_SUCCESS = 0;
constant NOTMUCH_STATUS_OUT_OF_MEMORY = 1;
constant NOTMUCH_STATUS_READ_ONLY_DATABASE = 2;
constant NOTMUCH_STATUS_XAPIAN_EXCEPTION = 3;
constant NOTMUCH_STATUS_FILE_ERROR = 4;
constant NOTMUCH_STATUS_FILE_NOT_EMAIL = 5;
constant NOTMUCH_STATUS_DUPLICATE_MESSAGE_ID = 6;
constant NOTMUCH_STATUS_NULL_POINTER = 7;
constant NOTMUCH_STATUS_TAG_TOO_LONG = 8;
constant NOTMUCH_STATUS_UNBALANCED_FREEZE_THAW = 9;
constant NOTMUCH_STATUS_UNBALANCED_ATOMIC = 10;
constant NOTMUCH_STATUS_UNSUPPORTED_OPERATION = 11;
constant NOTMUCH_STATUS_UPGRADE_REQUIRED = 12;
constant NOTMUCH_STATUS_PATH_ERROR = 13;


class Tags is repr('CPointer') {
    sub notmuch_tags_valid(Tags)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_tags_get(Tags)
        returns Str
        is native('notmuch.5')
        {*};
    sub notmuch_tags_destroy(Tags)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_tags_move_to_next(Tags)
        is native('notmuch.5')
        {*};

    method all() {
        gather {
            while self.valid() {
                take self.get();
                self.move_to_next();
            }
        }
    }

    method destroy() {
        notmuch_tags_destroy(self)
    }

    method get() {
        return unless self.valid();
        notmuch_tags_get(self)
    }
    method move_to_next() {
        notmuch_tags_move_to_next(self)
    }
    method valid() {
        notmuch_tags_valid(self)
    }
}

class Message is repr('CPointer') {
    sub notmuch_message_destroy(Message)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_message_get_filename(Message)
        returns Str
        is native('notmuch.5')
        {*};
    sub notmuch_message_get_header(Message, Str $header)
        returns Str
        is native('notmuch.5')
        {*};
    sub notmuch_message_get_tags(Message)
        returns Tags
        is native('notmuch.5')
        {*};
    sub notmuch_message_add_tag(Message, Str $tag)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_message_remove_tag(Message, Str $tag)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_message_get_message_id(Message)
        returns Str
        is native('notmuch.5')
        {*};
    sub notmuch_message_get_thread_id(Message)
        returns Str
        is native('notmuch.5')
        {*};

    method destroy() {
        notmuch_message_destroy(self)
    }
    method get_filename() {
        notmuch_message_get_filename(self)
    }
    method get_header(Str $header) {
        notmuch_message_get_header(self, $header)
    }
    method get_tags() {
        notmuch_message_get_tags(self)
    }
    method add_tag(str $tag) {
        notmuch_message_add_tag(self, $tag)
    }
    method remove_tag(str $tag) {
        notmuch_message_remove_tag(self, $tag)
    }
    method get_message_id() {
        notmuch_message_get_message_id(self)
    }
    method get_thread_id() {
        notmuch_message_get_thread_id(self)
    }
}

class Thread is repr('CPointer') {
    sub notmuch_thread_destroy(Thread)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_thread_get_tags(Thread)
        returns Tags
        is native('notmuch.5')
        {*};
    sub notmuch_thread_get_messages(Thread)
        returns Tags
        is native('notmuch.5')
        {*};
    sub notmuch_thread_get_thread_id(Thread)
        returns Str
        is native('notmuch.5')
        {*};

    method destroy() {
        notmuch_thread_destroy(self)
    }
    method get_tags() {
        notmuch_thread_get_tags(self)
    }
    method get_thread_id() {
        notmuch_thread_get_thread_id(self)
    }
    method get_thread_get_messages() {
        my $messages = notmuch_thread_get_messages(self);
    }

}

class Database is repr('CPointer') {
    sub notmuch_database_create_verbose(Str $path, CArray[long] $database, CArray[Str] $error_message)
        returns int32
        is native('notmuch.5', v4)
        {*};
    sub notmuch_database_create(Str $path, CArray[long] $database)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_database_open_verbose(Str $path, int32 $mode, CArray[long] $database, CArray[Str] $error_message)
        returns int32
        is native('notmuch.5', v4)
        {*};
    sub notmuch_database_open(Str $path, int32 $mode, CArray[long] $database)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_database_get_all_tags(Database)
        returns Tags
        is native('notmuch.5')
        {*};
    sub notmuch_database_add_message(Database, Str $filename, CArray[long] $message)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_database_find_message(Database, Str $id, CArray[long] $message)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_database_find_message_by_filename(Database, Str $filename, CArray[long] $message)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_database_get_version(Database)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_database_close(Database)
        returns int32
        is native('notmuch.5')
        {*};
    sub notmuch_database_destroy(Database)
        returns bool
        is native('notmuch.5')
        {*};

    method create(Str $path) {
        my $buf = CArray[long].new;
        my $err = CArray[Str].new;
        $buf[0] = 0;
        notmuch_database_create($path, $buf);
        fail "create has failed" unless $buf[0];
        # TODO(Gonéri): I guess there is better way to do that ^^
        nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Database)
    }

    method open(Str $path, Str $mode='r') {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        my $binmode = $mode eq 'w' ?? 1 !! 0;
        notmuch_database_open($path, $binmode, $buf);
        fail "open has failed" unless $buf[0];
        # TODO(Gonéri): I guess there is better way to do that ^^
        nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Database)
    }

    method add_message(Str $filename) {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        notmuch_database_add_message(self, $filename, $buf);
        fail "add_message has failed" unless $buf[0];
        my $message = nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Message);
        return $message;
    }

    method find_message(Str $id) {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        notmuch_database_find_message(self, $id, $buf);
        fail "find_message has failed" unless $buf[0];
        my $message = nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Message);
        return $message;
    }

    method find_message_by_filename(Str $filename) {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        notmuch_database_find_message_by_filename(self, $filename, $buf);
        fail "find_message_by_filename has failed" unless $buf[0];
        my $message = nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Message);
        return $message;
    }

    method get_version() {
        notmuch_database_get_version(self);
    }

    method close() {
        if notmuch_database_destroy(self) != NOTMUCH_STATUS_SUCCESS {
            die "Failed to close the DB";
        }
    }

}

class Messages is repr('CPointer') {
    sub notmuch_messages_valid(Messages)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_messages_get(Messages)
        returns Message
        is native('notmuch.5')
        {*};
    sub notmuch_messages_destroy(Messages)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_messages_move_to_next(Messages)
        is native('notmuch.5')
        {*};

    method all() {
        gather {
            while self.valid() {
                take self.get();
                self.move_to_next();
            }
        }
    }

    method destroy() {
        notmuch_messages_destroy(self)
    }

    method get() {
        return unless self.valid();
        my $message = notmuch_messages_get(self);
        return $message;
    }
    method move_to_next() {
        notmuch_messages_move_to_next(self)
    }
    method valid() {
        notmuch_messages_valid(self)
    }
}

class Threads is repr('CPointer') {
    sub notmuch_threads_valid(Threads)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_threads_get(Threads)
        returns Thread
        is native('notmuch.5')
        {*};
    sub notmuch_threads_destroy(Threads)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_threads_move_to_next(Threads)
        is native('notmuch.5')
        {*};


    method all() {
        gather {
            while self.valid() {
                take self.get();
                self.move_to_next();
            }
        }
    }

    method destroy() {
        notmuch_threads_destroy(self)
    }

    method get() {
        return unless self.valid();
        my $thread = notmuch_threads_get(self);
        return $thread;
    }
    method move_to_next() {
        notmuch_threads_move_to_next(self)
    }
    method valid() {
        notmuch_threads_valid(self)
    }
}

class Query is repr('CPointer') {
    sub notmuch_query_create(Database $database, Str $query_string)
        returns Query
        is native('notmuch.5')
        {*};
    sub notmuch_query_destroy(Query)
        returns bool
        is native('notmuch.5')
        {*};
    sub notmuch_query_search_messages(Query, CArray[long] $threads)
        returns int32
        is native('notmuch.5')
       {*};
    sub notmuch_query_search_threads(Query, CArray[long] $threads)
        returns int32
        is native('notmuch.5')
       {*};

    method new(Database $database, Str $query_string) {
        my $query = notmuch_query_create($database, $query_string);
        return $query;
    }

    method destroy() {
        notmuch_query_destroy(self);
    }

    method search_messages() {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        my $messages = notmuch_query_search_messages(self, $buf);
        nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Messages)
    }
    method search_threads() {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        notmuch_query_search_threads(self, $buf);
        nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Threads)
    }

}

=begin pod

=head1 NAME

Email::Notmuch - Raku binding for NotmuchMail email database

=head1 SYNOPSIS

=begin code :lang<raku>

use Email::Notmuch;

my $database = Database.new('/home/goneri/Maildir');
my $query = Query.new($database, 'tag:todo');
my $messages = $query.search_messages();
for $messages.all() -> $message {
    say $message.get_header('from');
    $message.add_tag('seen');
    say $message.get_tags().all();
}

=end code

=head1 DESCRIPTION

Notmuchmail ( https://notmuchmail.org/ ) is a mail indexation tool.
This Raku module provides binding for a limited subset of its API.

The library has been tested with Notmuch 0.25 and greater, it does
not work anymore with the older versions.

=head1 AUTHOR

Gonéri Le Bouder

=head1 COPYRIGHT AND LICENSE

Copyright 2015 - 2018 Gonéri Le Bouder

Copyright 2024 Raku Community

The project uses the GPLv3 or greater.

=end pod

# vim: expandtab shiftwidth=4
