package JFRC::DB::ChaCRM::Cv;

use base qw(JFRC::DB::ChaCRM::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'cv',

    columns => [
        cv_id      => { type => 'serial', not_null => 1 },
        name       => { type => 'varchar', length => 255, not_null => 1 },
        definition => { type => 'text' },
    ],

    primary_key_columns => [ 'cv_id' ],

    unique_key => [ 'name' ],

    relationships => [
        cvterm => {
            class      => 'JFRC::DB::ChaCRM::Cvterm',
            column_map => { cv_id => 'cv_id' },
            type       => 'one to many',
        },
    ],
);

1;
