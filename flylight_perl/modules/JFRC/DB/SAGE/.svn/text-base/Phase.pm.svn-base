package JFRC::DB::SAGE::Phase;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'phase',

    columns => [
        id            => { type => 'serial', not_null => 1 },
        experiment_id => { type => 'integer', not_null => 1 },
        name          => { type => 'varchar', length => 255, not_null => 1 },
        type_id       => { type => 'integer', not_null => 1 },
        create_date   => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'type_id', 'experiment_id' ],

    foreign_keys => [
        experiment => {
            class       => 'JFRC::DB::SAGE::Experiment',
            key_columns => { experiment_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],

    relationships => [
        phase_property => {
            class      => 'JFRC::DB::SAGE::PhaseProperty',
            column_map => { id => 'phase_id' },
            type       => 'one to many',
        },

        phase_score => {
            class      => 'JFRC::DB::SAGE::PhaseScore',
            column_map => { id => 'phase_id' },
            type       => 'one to many',
        },

        score_array => {
            class      => 'JFRC::DB::SAGE::ScoreArray',
            column_map => { id => 'phase_id' },
            type       => 'one to many',
        },

        session => {
            class      => 'JFRC::DB::SAGE::Session',
            column_map => { id => 'phase_id' },
            type       => 'one to many',
        },
    ],
);

1;

