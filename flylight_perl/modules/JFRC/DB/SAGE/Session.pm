package JFRC::DB::SAGE::Session;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'session',

    columns => [
        id            => { type => 'serial', not_null => 1 },
        name          => { type => 'varchar', length => 767, not_null => 1 },
        type_id       => { type => 'integer', not_null => 1 },
        line_id       => { type => 'integer', not_null => 1 },
        image_id      => { type => 'integer' },
        experiment_id => { type => 'integer' },
        phase_id      => { type => 'integer' },
        annotator     => { type => 'varchar', default => '', length => 255, not_null => 1 },
        lab_id        => { type => 'integer', not_null => 1 },
        create_date   => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'line_id', 'type_id', 'lab_id', 'phase_id', 'experiment_id', 'image_id' ],

    foreign_keys => [
        image => {
            class       => 'JFRC::DB::SAGE::Image',
            key_columns => { image_id => 'id' },
        },

        experiment => {
            class       => 'JFRC::DB::SAGE::Experiment',
            key_columns => { experiment_id => 'id' },
        },

        lab => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { lab_id => 'id' },
        },

        line => {
            class       => 'JFRC::DB::SAGE::Line',
            key_columns => { line_id => 'id' },
        },

        phase => {
            class       => 'JFRC::DB::SAGE::Phase',
            key_columns => { phase_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],

    relationships => [
        observation => {
            class      => 'JFRC::DB::SAGE::Observation',
            column_map => { id => 'session_id' },
            type       => 'one to many',
        },

        score => {
            class      => 'JFRC::DB::SAGE::Score',
            column_map => { id => 'session_id' },
            type       => 'one to many',
        },

        score_array => {
            class      => 'JFRC::DB::SAGE::ScoreArray',
            column_map => { id => 'session_id' },
            type       => 'one to many',
        },

        session_property => {
            class      => 'JFRC::DB::SAGE::SessionProperty',
            column_map => { id => 'session_id' },
            type       => 'one to many',
        },
    ],
);

1;

