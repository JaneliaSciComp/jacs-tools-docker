package JFRC::DB::SAGE::PhaseScore;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'phase_score',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        phase_id    => { type => 'integer', not_null => 1 },
        type_id     => { type => 'integer', not_null => 1 },
        value       => { type => 'scalar', length => 64 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    foreign_keys => [
        phase => {
            class       => 'JFRC::DB::SAGE::Phase',
            key_columns => { phase_id => 'id' },
        },

        type => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { type_id => 'id' },
        },
    ],
);

1;

