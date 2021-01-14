package JFRC::DB::SAGE::ScoreArray::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::ScoreArray;

sub object_class { 'JFRC::DB::SAGE::ScoreArray' }

__PACKAGE__->make_manager_methods('score_array');

1;

