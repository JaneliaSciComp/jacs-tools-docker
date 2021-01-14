package JFRC::DB::SAGE::NamespaceSequenceNumber;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'namespace_sequence_number',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        namespace       => { type => 'varchar', length => 767, not_null => 1 },
        sequence_number => { type => 'integer', not_null => 1 },
        create_date     => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'namespace' ],
);

1;

