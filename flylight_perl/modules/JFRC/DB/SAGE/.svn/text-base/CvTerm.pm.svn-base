package JFRC::DB::SAGE::CvTerm;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'cv_term',

    columns => [
        id           => { type => 'serial', not_null => 1 },
        cv_id        => { type => 'integer', not_null => 1 },
        name         => { type => 'varchar', length => 255, not_null => 1 },
        definition   => { type => 'text', length => 65535 },
        is_current   => { type => 'integer', not_null => 1 },
        display_name => { type => 'varchar', length => 255 },
        data_type    => { type => 'varchar', length => 255 },
        create_date  => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'cv_id', 'name' ],

    foreign_keys => [
        cv => {
            class       => 'JFRC::DB::SAGE::Cv',
            key_columns => { cv_id => 'id' },
        },
    ],

    relationships => [
        cv_relationship => {
            class      => 'JFRC::DB::SAGE::CvRelationship',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        cv_term_relationship => {
            class      => 'JFRC::DB::SAGE::CvTermRelationship',
            column_map => { id => 'object_id' },
            type       => 'one to many',
        },

        cv_term_relationship_objects => {
            class      => 'JFRC::DB::SAGE::CvTermRelationship',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        cv_term_relationship_objs => {
            class      => 'JFRC::DB::SAGE::CvTermRelationship',
            column_map => { id => 'subject_id' },
            type       => 'one to many',
        },

        experiment => {
            class      => 'JFRC::DB::SAGE::Experiment',
            column_map => { id => 'lab_id' },
            type       => 'one to many',
        },

        experiment_objs => {
            class      => 'JFRC::DB::SAGE::Experiment',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        experiment_property => {
            class      => 'JFRC::DB::SAGE::ExperimentProperty',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        image => {
            class      => 'JFRC::DB::SAGE::Image',
            column_map => { id => 'family_id' },
            type       => 'one to many',
        },

        image_objs => {
            class      => 'JFRC::DB::SAGE::Image',
            column_map => { id => 'source_id' },
            type       => 'one to many',
        },

        image_property => {
            class      => 'JFRC::DB::SAGE::ImageProperty',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        line => {
            class      => 'JFRC::DB::SAGE::Line',
            column_map => { id => 'lab_id' },
            type       => 'one to many',
        },

        line_property => {
            class      => 'JFRC::DB::SAGE::LineProperty',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        observation => {
            class      => 'JFRC::DB::SAGE::Observation',
            column_map => { id => 'term_id' },
            type       => 'one to many',
        },

        observation_objs => {
            class      => 'JFRC::DB::SAGE::Observation',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        phase => {
            class      => 'JFRC::DB::SAGE::Phase',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        phase_property => {
            class      => 'JFRC::DB::SAGE::PhaseProperty',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        phase_score => {
            class      => 'JFRC::DB::SAGE::PhaseScore',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        project => {
            class      => 'JFRC::DB::SAGE::Project',
            column_map => { id => 'lab_id' },
            type       => 'one to many',
        },

        score => {
            class      => 'JFRC::DB::SAGE::Score',
            column_map => { id => 'term_id' },
            type       => 'one to many',
        },

        score_array => {
            class      => 'JFRC::DB::SAGE::ScoreArray',
            column_map => { id => 'term_id' },
            type       => 'one to many',
        },

        score_array_objs => {
            class      => 'JFRC::DB::SAGE::ScoreArray',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        score_objs => {
            class      => 'JFRC::DB::SAGE::Score',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        secondary_image => {
            class      => 'JFRC::DB::SAGE::SecondaryImage',
            column_map => { id => 'product_id' },
            type       => 'one to many',
        },

        session => {
            class      => 'JFRC::DB::SAGE::Session',
            column_map => { id => 'lab_id' },
            type       => 'one to many',
        },

        session_objs => {
            class      => 'JFRC::DB::SAGE::Session',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },

        session_property => {
            class      => 'JFRC::DB::SAGE::SessionProperty',
            column_map => { id => 'type_id' },
            type       => 'one to many',
        },
    ],
);

1;

