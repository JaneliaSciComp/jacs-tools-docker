package JFRC::DB::SAGE::Project::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::Project;

sub object_class { 'JFRC::DB::SAGE::Project' }

__PACKAGE__->make_manager_methods('project');

1;

