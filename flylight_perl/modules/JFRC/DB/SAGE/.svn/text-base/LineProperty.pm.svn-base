package JFRC::DB::SAGE::LineProperty;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'line_property',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        line_id     => { type => 'integer', not_null => 1 },
        type_id     => { type => 'integer', not_null => 1 },
        value       => { type => 'text', length => 65535, not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'type_id', 'line_id' ],

    foreign_keys => [
        line => {
            class       => 'JFRC::DB::SAGE::Line',
            key_columns => { line_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],
);

1;

