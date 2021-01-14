package JFRC::DB::SAGE::Gene;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'gene',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        name        => { type => 'varchar', length => 767, not_null => 1 },
        organism_id => { type => 'integer', not_null => 1 },
        description => { type => 'text', length => 65535 },
        chromosome  => { type => 'varchar', length => 50 },
        cyto_start  => { type => 'varchar', length => 10 },
        cyto_end    => { type => 'varchar', length => 10 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'organism_id' ],

    foreign_keys => [
        organism => {
            class       => 'JFRC::DB::SAGE::Organism',
            key_columns => { organism_id => 'id' },
        },
    ],

    relationships => [
        gene_synonym => {
            class      => 'JFRC::DB::SAGE::GeneSynonym',
            column_map => { id => 'gene_id' },
            type       => 'one to many',
        },

        line => {
            class      => 'JFRC::DB::SAGE::Line',
            column_map => { id => 'gene_id' },
            type       => 'one to many',
        },
    ],
);

1;

