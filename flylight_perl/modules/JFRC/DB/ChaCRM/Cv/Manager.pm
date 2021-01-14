package JFRC::DB::ChaCRM::Cv::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::ChaCRM::Cv;

sub object_class { 'JFRC::DB::ChaCRM::Cv' }

__PACKAGE__->make_manager_methods('cv');

1;

