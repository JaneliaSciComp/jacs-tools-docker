# ****************************************************************************
# Resource name:  Zeiss::LSM::CZPrivate
# Written by:     Rob Svirskas
# Revision level: (same as Zeiss::LSM)
# Date released:  (same as Zeiss::LSM)
# Description:    This module uses POD documentation.
# Required resources:
#   Programs:       NONE
#   USEd modules:   strict
#                   warnings
#                   Class::Accessor::Fast
# ****************************************************************************
package Zeiss::LSM::CZPrivate;

use strict;
use warnings;
use base 'Class::Accessor::Fast';

# ****************************************************************************
# * Variables                                                                *
# ****************************************************************************
my $accessors_created = 0;

# ****************************************************************************
# * Constructor                                                              *
# ****************************************************************************

sub new
{
  my($class,$params) = @_;
  my $self = {};
  bless($self,$class);
  &_createAccessors() unless ($accessors_created++);
  return($self);
}


# ****************************************************************************
# * Internal routines                                                        *
# ****************************************************************************

# ****************************************************************************
# * Subroutine:  _createAccessors                                            *
# * Description: This routine will create accessors for all CZ Private tag   *
# *              attributes.                                                 *
# *                                                                          *
# * Parameters:  NONE                                                        *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub _createAccessors
{
  foreach (0..$#Zeiss::LSM::CZ_PRIVATE_TAG) {
    my($key) = %{$Zeiss::LSM::CZ_PRIVATE_TAG[$_]};
    __PACKAGE__->mk_ro_accessors($key);
  }
}

1;

__END__

=head1 NAME

Zeiss::LSM::CZPrivate - encapsulate Zeiss LSM CZ Private tag information

=head1 SYNOPSIS

  use Zeiss::LSM;
  my $lsm = Zeiss::LSM->new({stack => 'stack.lsm'});
  print 'Magic number: ',$lsm->cz_private->MagicNumber,"\n";

=head1 DESCRIPTION

This module provides a convenient read-only interface to Zeiss
LSM CZ Private tag information.

=head1 METHODS

=over 4

=item B<new>

Creates a new Zeiss::LSM::CZPrivate object and its accessors.

=back

=head1 BUGS

None known

=head1 AUTHOR

 Rob Svirskas
 svirskasr@janelia.hhmi.org

=head1 SEE ALSO

L<Zeiss::LSM>