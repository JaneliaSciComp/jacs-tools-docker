package JFRC::DB::SAGE::Laser::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::Laser;

sub object_class { 'JFRC::DB::SAGE::Laser' }

__PACKAGE__->make_manager_methods('laser');

1;

