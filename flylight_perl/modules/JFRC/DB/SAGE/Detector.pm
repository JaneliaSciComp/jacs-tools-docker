package JFRC::DB::SAGE::Detector;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'detector',

    columns => [
        id                     => { type => 'serial', not_null => 1 },
        track                  => { type => 'varchar', length => 128, not_null => 1 },
        image_channel_name     => { type => 'varchar', length => 128, not_null => 1 },
        num                    => { type => 'integer', not_null => 1 },
        image_id               => { type => 'integer', not_null => 1 },
        detector_voltage       => { type => 'varchar', length => 32 },
        detector_voltage_first => { type => 'varchar', length => 32 },
        detector_voltage_last  => { type => 'varchar', length => 32 },
        amplifier_gain         => { type => 'varchar', length => 32 },
        amplifier_gain_first   => { type => 'varchar', length => 32 },
        amplifier_gain_last    => { type => 'varchar', length => 32 },
        amplifier_offset       => { type => 'varchar', length => 32 },
        amplifier_offset_first => { type => 'varchar', length => 32 },
        amplifier_offset_last  => { type => 'varchar', length => 32 },
        pinhole_diameter       => { type => 'varchar', length => 32 },
        pinhole_name           => { type => 'varchar', length => 128 },
        point_detector_name    => { type => 'varchar', length => 128 },
        filter                 => { type => 'varchar', length => 32 },
        color                  => { type => 'varchar', length => 32 },
        digital_gain           => { type => 'varchar', length => 32 },
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

