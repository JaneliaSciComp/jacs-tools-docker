package JFRC::DB::SAGE::Image::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::Image;

sub object_class { 'JFRC::DB::SAGE::Image' }

__PACKAGE__->make_manager_methods('image');

1;

