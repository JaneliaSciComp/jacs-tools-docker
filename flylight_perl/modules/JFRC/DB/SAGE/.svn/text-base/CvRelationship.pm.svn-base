package JFRC::DB::SAGE::CvRelationship;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'cv_relationship',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        type_id     => { type => 'integer', not_null => 1 },
        subject_id  => { type => 'integer', not_null => 1 },
        object_id   => { type => 'integer', not_null => 1 },
        is_current  => { type => 'integer', not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'type_id', 'subject_id', 'object_id' ],

    foreign_keys => [
        object => {
            class       => 'JFRC::DB::SAGE::Cv',
            key_columns => { object_id => 'id' },
        },

        subject => {
            class       => 'JFRC::DB::SAGE::Cv',
            key_columns => { subject_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],
);

1;

