package JFRC::DB::SAGE::Organism;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'organism',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        abbreviation => { type => 'varchar', length => 255, not_null => 1 },
        genus        => { type => 'varchar', length => 255, not_null => 1 },
        species      => { type => 'varchar', length => 255, not_null => 1 },
        common_name  => { type => 'varchar', length => 255, not_null => 1 },
        taxonomy_id  => { type => 'integer', not_null => 1 },
        create_date  => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
    
    unique_key => [ 'genus', 'species' ],

    relationships => [
        gene => {
            class      => 'JFRC::DB::SAGE::Gene',
            column_map => { id => 'organism_id' },
            type       => 'one to many',
        },

        line => {
            class      => 'JFRC::DB::SAGE::Line',
            column_map => { id => 'organism_id' },
            type       => 'one to many',
        },
    ],
);

1;

