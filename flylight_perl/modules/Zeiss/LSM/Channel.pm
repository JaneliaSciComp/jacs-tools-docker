# ****************************************************************************
# Resource name:  Zeiss::LSM::Channel
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
package Zeiss::LSM::Channel;

use strict;
use warnings;
use base 'Class::Accessor::Fast';

# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
use constant ACCESSORS => qw(color name);


# ****************************************************************************
# * Constructor                                                              *
# ****************************************************************************

sub new
{
  my($class,$params) = @_;
  my $self = {};
  bless($self,$class);
  if ($params) {
    $self->{$_} = $params->{$_} foreach (ACCESSORS);
  }
  return($self);
}


# ****************************************************************************
# * Accessors                                                                *
# ****************************************************************************

__PACKAGE__->mk_ro_accessors(ACCESSORS);

1;

__END__

=head1 NAME

Zeiss::LSM::Channel - encapsulate Zeiss LSM channel information

=head1 SYNOPSIS

  use Zeiss::LSM;
  my $lsm = Zeiss::LSM->new({stack => 'stack.lsm'});
  printf "Channels (%d):\n",$lsm->numChannels;
  print '  ',$_->name,' (',$_->color,")\n" foreach ($lsm->getChannels);

=head1 DESCRIPTION

This module provides a convenient read-only interface to Zeiss
LSM channel information.

=head1 METHODS

=over 4

=item B<new>

Creates a new Zeiss::LSM::Channel object and its accessors.

=item B<color>

The channel color expressed as a hex RGB triplet

=item B<name>

The channel name

=back

=head1 BUGS

None known

=head1 AUTHOR

 Rob Svirskas
 svirskasr@janelia.hhmi.org

=head1 SEE ALSO

L<Zeiss::LSM>
