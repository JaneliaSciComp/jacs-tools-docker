package JFRC::DB::SAGE::SecondaryImage::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::SecondaryImage;

sub object_class { 'JFRC::DB::SAGE::SecondaryImage' }

__PACKAGE__->make_manager_methods('secondary_image');

1;

