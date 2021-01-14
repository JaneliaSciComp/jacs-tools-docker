package JFRC::DB::SAGE::Project;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'project',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        name        => { type => 'varchar', length => 255, not_null => 1 },
        lab_id      => { type => 'integer', not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'lab_id' ],

    foreign_keys => [
        lab => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { lab_id => 'id' },
        },
    ],

    relationships => [
        project_cv => {
            class      => 'JFRC::DB::SAGE::ProjectCv',
            column_map => { id => 'project_id' },
            type       => 'one to many',
        },
    ],
);

1;

