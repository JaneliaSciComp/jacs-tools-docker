# ****************************************************************************
# Resource name:  Zeiss::LSM::Track::Beamsplitter
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
package Zeiss::LSM::Track::Beamsplitter;

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
  &Zeiss::LSM::Track::_createLevel2Accessors(__PACKAGE__,'BEAMSPLITTER')
    unless ($accessors_created++);
  return($self);
}

1;

__END__

=head1 NAME

Zeiss::LSM::Track::Beamsplitter - encapsulate Zeiss LSM beam splitter
information

=head1 SYNOPSIS

  use Zeiss::LSM;
  foreach my $t ($lsm->getTracks) {
    print "Track ",$t->{TRACK_ENTRY_NAME},"\n";
    print '  ',$_->BEAMSPLITTER_ENTRY_NAME,"\n"
      foreach ($t->getBeamsplitters);
  }

=head1 DESCRIPTION

This module provides a convenient read-only interface to Zeiss
LSM beam splitter information.

=head1 METHODS

=over 4

=item B<new>

Creates a new Zeiss::LSM::Track::Beamsplitter object
and its accessors.

=back

=head1 BUGS

None known

=head1 AUTHOR

 Rob Svirskas
 svirskasr@janelia.hhmi.org

=head1 SEE ALSO

L<Zeiss::LSM::Track>, L<Zeiss::LSM>