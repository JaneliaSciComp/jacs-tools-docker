package JFRC::DB::SAGE::Experiment::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::Experiment;

sub object_class { 'JFRC::DB::SAGE::Experiment' }

__PACKAGE__->make_manager_methods('experiment');

1;

