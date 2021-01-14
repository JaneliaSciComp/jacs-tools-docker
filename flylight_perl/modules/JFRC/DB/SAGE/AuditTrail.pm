package JFRC::DB::SAGE::AuditTrail;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'audit_trail',

    columns => [
        id                 => { type => 'bigserial', not_null => 1 },
        table_name         => { type => 'varchar', length => 50, not_null => 1 },
        column_name        => { type => 'varchar', length => 50, not_null => 1 },
        data_type          => { type => 'varchar', length => 50, not_null => 1 },
        primary_identifier => { type => 'bigint', not_null => 1 },
        old_value          => { type => 'text', length => 65535 },
        new_value          => { type => 'text', length => 65535 },
        modify_date        => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

