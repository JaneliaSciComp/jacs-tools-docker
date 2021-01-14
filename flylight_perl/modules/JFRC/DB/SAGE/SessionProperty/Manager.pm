package JFRC::DB::SAGE::SessionProperty::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::SessionProperty;

sub object_class { 'JFRC::DB::SAGE::SessionProperty' }

__PACKAGE__->make_manager_methods('session_property');

1;

