package JFRC::DB::SAGE::ScoreArray;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'score_array',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        session_id   => { type => 'integer' },
        phase_id     => { type => 'integer' },
        term_id      => { type => 'integer', not_null => 1 },
        cv_id        => { type => 'integer', not_null => 1 },
        type_id      => { type => 'integer', not_null => 1 },
        value        => { type => 'scalar', length => 16777215, not_null => 1 },
        run          => { type => 'integer', default => '0', not_null => 1 },
        data_type    => { type => 'varchar', length => 255 },
        row_count    => { type => 'integer' },
        column_count => { type => 'integer' },
        create_date  => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    foreign_keys => [
        phase => {
            class       => 'JFRC::DB::SAGE::Phase',
            key_columns => { phase_id => 'id' },
        },

        session => {
            class       => 'JFRC::DB::SAGE::Session',
            key_columns => { session_id => 'id' },
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

