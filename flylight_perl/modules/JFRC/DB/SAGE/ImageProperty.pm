package JFRC::DB::SAGE::ImageProperty;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'image_property',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        image_id    => { type => 'integer', not_null => 1 },
        type_id     => { type => 'integer', not_null => 1 },
        value       => { type => 'text', length => 65535, not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'type_id', 'image_id' ],

    foreign_keys => [
        image => {
            class       => 'JFRC::DB::SAGE::Image',
            key_columns => { image_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],
);

1;

