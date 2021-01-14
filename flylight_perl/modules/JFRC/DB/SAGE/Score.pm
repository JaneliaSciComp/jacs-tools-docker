package JFRC::DB::SAGE::Score;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'score',

    columns => [
        id             => { type => 'serial', not_null => 1 },
        session_id     => { type => 'integer', not_null => 1 },
        phase_id       => { type => 'integer', not_null => 1 },
        experiment_id  => { type => 'integer', not_null => 1 },
        term_id        => { type => 'integer', not_null => 1 },
        type_id        => { type => 'integer', not_null => 1 },
        value          => { type => 'scalar', length => 64, not_null => 1 },
        run            => { type => 'integer', default => '0', not_null => 1 },
        create_date    => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'session_id', 'type_id', 'run', 'term_id' ],

    foreign_keys => [
        session => {
            class       => 'JFRC::DB::SAGE::Session',
            key_columns => { session_id => 'id' },
        },

        phase => {
            class       => 'JFRC::DB::SAGE::Phase',
            key_columns => { phase_id => 'id' },
        },

        experiment => {
            class       => 'JFRC::DB::SAGE::Experiment',
            key_columns => { experiment_id => 'id' },
        },

        term => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { term_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],
);

1;

