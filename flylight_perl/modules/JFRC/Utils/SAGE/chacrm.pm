# ****************************************************************************
# * POD documentation header start                                           *
# ****************************************************************************

=head1 NAME

JFRC::Utils::SAGE::chacrm

=head1 SYNOPSIS

use JFRC::Utils::SAGE::chacrm

=head1 DESCRIPTION

No routines, just an autoload

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::chacrm;

require Exporter;
our @ISA = qw(Exporter);
# This allows declaration       use Foo::Bar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ();
our @EXPORT_OK = ();
our @EXPORT = ();


# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
our $VERSION = '0.1';

# ****************************************************************************
# * Callable routines                                                        *
# ****************************************************************************

=head2 AUTOLOAD

 Title:       AUTOLOAD
 Parameters:  NONE
 Returns:     NONE

=cut

sub AUTOLOAD
{ return(1); }


1;
