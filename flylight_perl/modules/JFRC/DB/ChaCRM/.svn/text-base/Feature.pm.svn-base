package JFRC::DB::ChaCRM::Feature;

use base qw(JFRC::DB::ChaCRM::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'feature',

    columns => [
        feature_id       => { type => 'serial', not_null => 1 },
        dbxref_id        => { type => 'integer' },
        organism_id      => { type => 'integer', not_null => 1 },
        name             => { type => 'varchar', length => 255 },
        uniquename       => { type => 'text', not_null => 1 },
        residues         => { type => 'text' },
        seqlen           => { type => 'integer' },
        md5checksum      => { type => 'character', length => 32 },
        type_id          => { type => 'integer', not_null => 1 },
        is_analysis      => { type => 'boolean', default => 'false', not_null => 1 },
        timeaccessioned  => { type => 'timestamp', default => 'now', not_null => 1 },
        timelastmodified => { type => 'timestamp', default => 'now', not_null => 1 },
        is_obsolete      => { type => 'boolean', default => 'false', not_null => 1 },
    ],

    primary_key_columns => [ 'feature_id' ],

    unique_key => [
                   [ 'organism_id', 'uniquename', 'type_id' ],
                   [ 'name' ],
                  ],

    foreign_keys => [
        cvterm => {
            class       => 'JFRC::DB::ChaCRM::Cvterm',
            key_columns => { type_id => 'cvterm_id' },
        },
    ],

    relationships => [
        featureprop => {
            class      => 'JFRC::DB::ChaCRM::Featureprop',
            column_map => { feature_id => 'feature_id' },
            type       => 'one to many',
        },
    ],
);

1;
