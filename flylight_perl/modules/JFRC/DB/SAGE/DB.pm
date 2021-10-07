package JFRC::DB::SAGE::DB;

our $VERSION = '0.1';

use base qw(Rose::DB);

__PACKAGE__->use_private_registry;
__PACKAGE__->default_domain('production');
__PACKAGE__->default_type('rw');

__PACKAGE__->register_db(domain   => 'production',
                         type     => 'rw',
                         driver   => 'mysql',
                         database => 'sage',
                         host     => 'mysql3.int.janelia.org',
                         username => 'sageApp',
                         password => 'h3ll0K1tty');

__PACKAGE__->register_db(domain   => 'production',
                         type     => 'r',
                         driver   => 'mysql',
                         database => 'sage.int.janelia.org',
                         host     => 'mysql3',
                         username => 'sageRead',
                         password => 'sageRead');

__PACKAGE__->register_db(domain   => 'development',
                         type     => 'rw',
                         driver   => 'mysql',
                         database => 'sage',
                         host     => 'dev-db.int.janelia.org',
                         username => 'sageApp',
                         password => 's@g3App');

__PACKAGE__->register_db(domain   => 'development',
                         type     => 'r',
                         driver   => 'mysql',
                         database => 'sage',
                         host     => 'dev-db.int.janelia.org',
                         username => 'sageRead',
                         password => 'sageRead');
