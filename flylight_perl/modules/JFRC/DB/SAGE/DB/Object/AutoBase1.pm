package JFRC::DB::SAGE::DB::Object::AutoBase1;

use base 'Rose::DB::Object';

use JFRC::DB::SAGE::DB;

sub init_db { JFRC::DB::SAGE::DB->new() }

1;
