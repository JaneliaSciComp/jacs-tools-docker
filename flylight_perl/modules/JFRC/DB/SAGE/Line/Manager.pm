package JFRC::DB::SAGE::Line::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::Line;

sub object_class { 'JFRC::DB::SAGE::Line' }

__PACKAGE__->make_manager_methods('line');

1;

