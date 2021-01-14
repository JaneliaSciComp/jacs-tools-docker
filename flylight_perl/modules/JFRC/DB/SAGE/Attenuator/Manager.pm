package JFRC::DB::SAGE::Attenuator::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::Attenuator;

sub object_class { 'JFRC::DB::SAGE::Attenuator' }

__PACKAGE__->make_manager_methods('attenuator');

1;

