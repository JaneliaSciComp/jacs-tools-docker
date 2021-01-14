package JFRC::DB::SAGE::Laser;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'laser',

    columns => [
        id       => { type => 'serial', not_null => 1 },
        name     => { type => 'varchar', length => 128, not_null => 1 },
        image_id => { type => 'integer', not_null => 1 },
        power    => { type => 'varchar', length => 32 },
    ],

    primary_key_columns => [ 'id' ],

    foreign_keys => [
        image => {
            class       => 'JFRC::DB::SAGE::Image',
            key_columns => { image_id => 'id' },
        },
    ],
);

1;

