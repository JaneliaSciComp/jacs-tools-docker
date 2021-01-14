package JFRC::DB::SAGE::Line;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'line',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        name        => { type => 'varchar', length => 767, not_null => 1 },
        lab_id      => { type => 'integer', not_null => 1 },
        gene_id     => { type => 'integer' },
        organism_id => { type => 'integer' },
        genotype    => { type => 'text', length => 65535 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'lab_id' ],

    foreign_keys => [
        gene => {
            class       => 'JFRC::DB::SAGE::Gene',
            key_columns => { gene_id => 'id' },
        },

        lab => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { lab_id => 'id' },
        },

        organism => {
            class       => 'JFRC::DB::SAGE::Organism',
            key_columns => { organism_id => 'id' },
        },
    ],

    relationships => [
        image => {
            class      => 'JFRC::DB::SAGE::Image',
            column_map => { id => 'line_id' },
            type       => 'one to many',
        },

        line_property => {
            class      => 'JFRC::DB::SAGE::LineProperty',
            column_map => { id => 'line_id' },
            type       => 'one to many',
        },

        session => {
            class      => 'JFRC::DB::SAGE::Session',
            column_map => { id => 'line_id' },
            type       => 'one to many',
        },
    ],
);

1;

