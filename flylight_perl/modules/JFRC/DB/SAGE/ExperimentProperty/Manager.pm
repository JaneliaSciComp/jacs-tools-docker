package JFRC::DB::SAGE::ExperimentProperty::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::ExperimentProperty;

sub object_class { 'JFRC::DB::SAGE::ExperimentProperty' }

__PACKAGE__->make_manager_methods('experiment_property');

1;

