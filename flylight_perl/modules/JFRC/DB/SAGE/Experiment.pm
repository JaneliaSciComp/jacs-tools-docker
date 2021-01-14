package JFRC::DB::SAGE::Experiment;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'experiment',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        name         => { type => 'varchar', length => 255, not_null => 1 },
        type_id      => { type => 'integer', not_null => 1 },
        lab_id       => { type => 'integer', not_null => 1 },
        experimenter => { type => 'varchar', length => 255, not_null => 1 },
        create_date  => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'type_id', 'lab_id' ],

    foreign_keys => [
        lab => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { lab_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],

    relationships => [
        experiment_property => {
            class      => 'JFRC::DB::SAGE::ExperimentProperty',
            column_map => { id => 'experiment_id' },
            type       => 'one to many',
        },

        phase => {
            class      => 'JFRC::DB::SAGE::Phase',
            column_map => { id => 'experiment_id' },
            type       => 'one to many',
        },

        session => {
            class      => 'JFRC::DB::SAGE::Session',
            column_map => { id => 'experiment_id' },
            type       => 'one to many',
        },
    ],
);

1;

