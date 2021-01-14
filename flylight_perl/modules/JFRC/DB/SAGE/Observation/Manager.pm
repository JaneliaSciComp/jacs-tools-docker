package JFRC::DB::SAGE::Observation::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::Observation;

sub object_class { 'JFRC::DB::SAGE::Observation' }

__PACKAGE__->make_manager_methods('observation');

1;

