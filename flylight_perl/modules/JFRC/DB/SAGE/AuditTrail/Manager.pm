package JFRC::DB::SAGE::AuditTrail::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use JFRC::DB::SAGE::AuditTrail;

sub object_class { 'JFRC::DB::SAGE::AuditTrail' }

__PACKAGE__->make_manager_methods('audit_trail');

1;

