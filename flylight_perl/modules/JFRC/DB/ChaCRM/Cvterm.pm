package JFRC::DB::ChaCRM::Cvterm;

use base qw(JFRC::DB::ChaCRM::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'cvterm',

    columns => [
        cv_id               => { type => 'integer', not_null => 1 },
        cvterm_id           => { type => 'serial', not_null => 1 },
        dbxref_id           => { type => 'integer', not_null => 1 },
        definition          => { type => 'text' },
        is_obsolete         => { type => 'integer', default => '0', not_null => 1 },
        is_relationshiptype => { type => 'integer', default => '0', not_null => 1 },
        name                => { type => 'varchar', length => 1024, not_null => 1 },
    ],

    primary_key_columns => [ 'cvterm_id' ],

    unique_keys => [
        [ 'dbxref_id' ],
        [ 'cv_id', 'name', 'is_obsolete' ],
    ],

    foreign_keys => [
        cv => {
            class       => 'JFRC::DB::ChaCRM::Cv',
            key_columns => { cv_id => 'cv_id' },
        },
    ],

    relationships => [
        feature => {
            class      => 'JFRC::DB::ChaCRM::Feature',
            column_map => { cvterm_id => 'type_id' },
            type       => 'one to many',
        },

        featureprop => {
            class      => 'JFRC::DB::ChaCRM::Featureprop',
            column_map => { cvterm_id => 'type_id' },
            type       => 'one to many',
        },
    ],
);

1;
