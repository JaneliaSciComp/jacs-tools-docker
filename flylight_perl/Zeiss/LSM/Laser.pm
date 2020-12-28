# ****************************************************************************
# Resource name:  Zeiss::LSM::Laser
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
package Zeiss::LSM::Laser;

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
  my $class = shift;
  my $self = {};
  bless($self,$class);
  &Zeiss::LSM::_createLevel1Accessors(__PACKAGE__,'OLEDB_LASER')
    unless ($accessors_created++);
  return($self);
}

1;

__END__

=head1 NAME

Zeiss::LSM::Laser - encapsulate Zeiss LSM laser information

=head1 SYNOPSIS

  use Zeiss::LSM;
  my $lsm = Zeiss::LSM->new({stack => 'stack.lsm'});
  print $_->OLEDB_LASER_ENTRY_NAME,"\n" foreach ($lsm->getLasers);

=head1 DESCRIPTION

This module provides a convenient read-only interface to Zeiss
LSM laser information.

=head1 METHODS

=over 4

=item B<new>

Creates a new Zeiss::LSM::Laser object and its accessors.

=back

=head1 BUGS

None known

=head1 AUTHOR

 Rob Svirskas
 svirskasr@janelia.hhmi.org

=head1 SEE ALSO

L<Zeiss::LSM>