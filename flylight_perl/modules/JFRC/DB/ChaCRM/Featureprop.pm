package JFRC::DB::ChaCRM::Featureprop;

use base qw(JFRC::DB::ChaCRM::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'featureprop',

    columns => [
        featureprop_id => { type => 'serial', not_null => 1 },
        feature_id     => { type => 'integer', not_null => 1 },
        type_id        => { type => 'integer', not_null => 1 },
        value          => { type => 'text' },
        rank           => { type => 'integer', default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'featureprop_id' ],

    unique_key => [ 'feature_id', 'type_id', 'rank' ],

    foreign_keys => [
        cvterm => {
            class       => 'JFRC::DB::ChaCRM::Cvterm',
            key_columns => { type_id => 'cvterm_id' },
        },

        feature => {
            class       => 'JFRC::DB::ChaCRM::Feature',
            key_columns => { feature_id => 'feature_id' },
        },
    ],
);

1;
