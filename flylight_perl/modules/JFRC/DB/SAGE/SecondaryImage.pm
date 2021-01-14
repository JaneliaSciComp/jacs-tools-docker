package JFRC::DB::SAGE::SecondaryImage;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'secondary_image',

    columns => [
        id          => { type => 'serial', not_null => 1 },
        name        => { type => 'varchar', length => 767, not_null => 1 },
        image_id    => { type => 'integer', not_null => 1 },
        product_id  => { type => 'integer', not_null => 1 },
        path        => { type => 'varchar', length => 1000, not_null => 1 },
        url         => { type => 'varchar', length => 1000, not_null => 1 },
        create_date => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'image_id' ],

    foreign_keys => [
        image => {
            class       => 'JFRC::DB::SAGE::Image',
            key_columns => { image_id => 'id' },
        },

        product => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { product_id => 'id' },
        },
    ],
);

1;

