package JFRC::DB::SAGE::SessionProperty;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'session_property',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        session_id  => { type => 'integer', not_null => 1 },
        type_id     => { type => 'integer', not_null => 1 },
        value       => { type => 'text', length => 65535, not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'type_id', 'session_id' ],

    foreign_keys => [
        session => {
            class       => 'JFRC::DB::SAGE::Session',
            key_columns => { session_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],
);

1;

