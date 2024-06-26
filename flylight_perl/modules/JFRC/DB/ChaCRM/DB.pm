package JFRC::DB::ChaCRM::DB;

our $VERSION = '0.1';

use base qw(Rose::DB);

__PACKAGE__->use_private_registry;
__PACKAGE__->default_domain('production');

__PACKAGE__->register_db(domain   => 'production',
                         driver   => 'Pg',
                         database => 'chacrm',
                         host     => 'chacrm.int.janelia.org',
                         username => 'apollo',
                         password => 'apollo');
                         
__PACKAGE__->register_db(domain   => 'development',
                         driver   => 'Pg',
                         database => 'chacrm',
                         host     => 'dev-db.int.janelia.org',
                         username => 'apollo',
                         password => 'apollo');
                         
