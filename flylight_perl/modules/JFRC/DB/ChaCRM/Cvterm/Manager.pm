package JFRC::DB::ChaCRM::Cvterm::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::ChaCRM::Cvterm;

sub object_class { 'JFRC::DB::ChaCRM::Cvterm' }

__PACKAGE__->make_manager_methods('cvterm');

1;

