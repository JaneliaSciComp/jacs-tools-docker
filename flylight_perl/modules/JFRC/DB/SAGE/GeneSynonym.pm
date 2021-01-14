package JFRC::DB::SAGE::GeneSynonym;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'gene_synonym',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        gene_id     => { type => 'integer', not_null => 1 },
        synonym     => { type => 'varchar', length => 767, not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    foreign_keys => [
        gene => {
            class       => 'JFRC::DB::SAGE::Gene',
            key_columns => { gene_id => 'id' },
        },
    ],
);

1;

