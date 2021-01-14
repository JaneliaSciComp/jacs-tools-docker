package JFRC::DB::SAGE::Image;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'image',

    columns => [
        id             => { type => 'serial', not_null => 1 },
        name           => { type => 'varchar', length => 767, not_null => 1 },
        url            => { type => 'varchar', length => 1000 },
        path           => { type => 'varchar', length => 1000 },
        source_id      => { type => 'integer', not_null => 1 },
        family_id      => { type => 'integer', not_null => 1 },
        line_id        => { type => 'integer', not_null => 1 },
        capture_date   => { type => 'timestamp' },
        representative => { type => 'integer', default => '0', not_null => 1 },
        display        => { type => 'integer', default => 1, not_null => 1 },
        created_by     => { type => 'varchar', length => 1000 },
        create_date    => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'name', 'source_id', 'family_id', 'line_id' ],

    foreign_keys => [
        family => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { family_id => 'id' },
        },

        line => {
            class       => 'JFRC::DB::SAGE::Line',
            key_columns => { line_id => 'id' },
        },

        source => {
            class       => 'JFRC::DB::SAGE::CvTerm',
            key_columns => { source_id => 'id' },
        },
    ],

    relationships => [
        attenuator => {
            class      => 'JFRC::DB::SAGE::Attenuator',
            column_map => { id => 'image_id' },
            type       => 'one to many',
        },

        detector => {
            class      => 'JFRC::DB::SAGE::Detector',
            column_map => { id => 'image_id' },
            type       => 'one to many',
        },

        image_property => {
            class      => 'JFRC::DB::SAGE::ImageProperty',
            column_map => { id => 'image_id' },
            type       => 'one to many',
        },

        laser => {
            class      => 'JFRC::DB::SAGE::Laser',
            column_map => { id => 'image_id' },
            type       => 'one to many',
        },

        secondary_image => {
            class      => 'JFRC::DB::SAGE::SecondaryImage',
            column_map => { id => 'image_id' },
            type       => 'one to many',
        },

        session => {
            class      => 'JFRC::DB::SAGE::Session',
            column_map => { id => 'image_id' },
            type       => 'one to many',
        },
    ],
);

1;

