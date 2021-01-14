package JFRC::DB::SAGE::AnnotationSymbol;

use strict;

use base qw(JFRC::DB::SAGE::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
    table   => 'annotation_symbol',

    columns => [
        id                => { type => 'serial', not_null => 1 },
        annotation_symbol => { type => 'varchar', length => 255, not_null => 1 },
        symbol            => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

