package JFRC::DB::SAGE::CvTermRelationship::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::CvTermRelationship;

sub object_class { 'JFRC::DB::SAGE::CvTermRelationship' }

__PACKAGE__->make_manager_methods('cv_term_relationship');

1;

