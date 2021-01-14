package JFRC::DB::SAGE::ProjectCv;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'project_cv',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        project_id  => { type => 'integer', not_null => 1 },
        cv_id       => { type => 'integer', not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    foreign_keys => [
        cv => {
            class       => 'JFRC::DB::SAGE::Cv',
            key_columns => { cv_id => 'id' },
        },

        project => {
            class       => 'JFRC::DB::SAGE::Project',
            key_columns => { project_id => 'id' },
        },
    ],
);

1;

