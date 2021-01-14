package JFRC::DB::SAGE::Attenuator;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'attenuator',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        track           => { type => 'varchar', length => 128, not_null => 1 },
        num             => { type => 'integer', not_null => 1 },
        image_id        => { type => 'integer', not_null => 1 },
        wavelength      => { type => 'varchar', length => 32 },
        transmission    => { type => 'varchar', length => 32 },
        acquire         => { type => 'integer' },
        detchannel_name => { type => 'varchar', length => 128 },
        power_bc1       => { type => 'float', precision => 32 },
        power_bc2       => { type => 'float', precision => 32 },
        ramp_low_power  => { type => 'float', precision => 32 },
        ramp_high_power => { type => 'float', precision => 32 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'track', 'image_id', 'num' ],

    foreign_keys => [
        image => {
            class       => 'JFRC::DB::SAGE::Image',
            key_columns => { image_id => 'id' },
        },
    ],
);

1;

