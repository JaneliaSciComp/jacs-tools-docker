# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::fly_olympiad_sterility_experimental
# Written by:     Rob Svirskas
# Revision level: 0.1
# Date released:  2009-xx-xx
# Description:    This module uses POD documentation.
# Required resources:
#   Programs:       NONE
#   USEd modules:   strict
#                   warnings
#                   Carp
#                   CGI
#
#                               REVISION HISTORY
# ----------------------------------------------------------------------------
# | revision | name            | date    | description                       |
# ----------------------------------------------------------------------------
#     0.1     Rob Svirskas      09-xx-xx  Initial version
# ****************************************************************************

# ****************************************************************************
# * POD documentation header start                                           *
# ****************************************************************************

=head1 NAME

JFRC::Utils::SAGE::fly_olympiad_sterility_experimental : fly_olympiad_sterility_experimental functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::fly_olympiad_sterility_experimental

=head1 DESCRIPTION

There are currently two routines:

=over

experiment

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::fly_olympiad_sterility_experimental;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = (all => [qw(experiment)]);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});
our @EXPORT = ();


# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
our $VERSION = '0.1';

# ****************************************************************************
# * Callable routines                                                        *
# ****************************************************************************

sub AUTOLOAD
{ return(1); }


# ****************************************************************************
# * experiment                                                               *
# ****************************************************************************

=head2 experiment

 Title:       experiment
 Usage:       &experiment($l,$row);
 Description: Set the experiment
 Parameters:  l:   Rose::DB Line object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub experiment
{
  my($l,$row) = @_;
  my $sname = $row->{$main::SESSION_KEY} = join(' ',$l->{name},
      $row->{cross_barcode},$row->{rep},$row->{tube});
  my $sql = 'SELECT e.name FROM experiment e JOIN session_vw s ON '
            . "(e.id=s.experiment_id AND s.cv='fly_olympiad_sterility' AND "
            . "s.name='$sname')";
  my $ar = $main::dbh->selectcol_arrayref($sql);
  if (scalar @$ar) {
    &main::terminateProgram("Session $sname does not identify a unique experiment")
      if (scalar @$ar > 1);
  }
  else {
    &main::terminateProgram("Session $sname does not identify an experiment");
  }
  $row->{$main::EXPERIMENT_KEY} = $ar->[0];
  return(1);
}


1;

__END__

=head1 AUTHOR

 Rob Svirskas
 svirskasr@janelia.hhmi.org

=head1 BUGS

None known, but give me a chance.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc JFRC::Utils::SAGE::fly_olympiad_sterility_experimental

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
