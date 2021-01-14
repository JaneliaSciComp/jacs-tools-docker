package JFRC::DB::SAGE::PhaseProperty::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::PhaseProperty;

sub object_class { 'JFRC::DB::SAGE::PhaseProperty' }

__PACKAGE__->make_manager_methods('phase_property');

1;

