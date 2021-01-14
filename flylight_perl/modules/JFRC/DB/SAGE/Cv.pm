package JFRC::DB::SAGE::Cv;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'cv',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        name        => { type => 'varchar', length => 255, not_null => 1 },
        definition  => { type => 'text', length => 65535 },
        version     => { type => 'integer', not_null => 1 },
        is_current  => { type => 'integer', not_null => 1 },
        display_name=> { type => 'text', length => 255 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name' ],

    relationships => [
        cv_relationship => {
            class      => 'JFRC::DB::SAGE::CvRelationship',
            column_map => { id => 'object_id' },
            type       => 'one to many',
        },

        cv_relationship_objs => {
            class      => 'JFRC::DB::SAGE::CvRelationship',
            column_map => { id => 'subject_id' },
            type       => 'one to many',
        },

        cv_term => {
            class      => 'JFRC::DB::SAGE::CvTerm',
            column_map => { id => 'cv_id' },
            type       => 'one to many',
        },

        project_cv => {
            class      => 'JFRC::DB::SAGE::ProjectCv',
            column_map => { id => 'cv_id' },
            type       => 'one to many',
        },
    ],
);

1;

