# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::fly_light_disk_usage
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

JFRC::Utils::SAGE::fly_light_disk_usage

=head1 SYNOPSIS

use JFRC::Utils::SAGE::fly_light_disk_usage

=head1 DESCRIPTION

There are currently two routines:

=over

experiment

session

observation

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::fly_light_disk_usage;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = (all => [qw(experiment session observation)]);
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
 Parameters:  l:   Rose::DB Line object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub experiment
{
  my($l,$row) = @_;
  $main::BASE_CV = 'light_imagery';
  $main::ES_TYPE = 'disk_usage';
  $row->{$main::EXPERIMENT_KEY} = 'Disk usage ' . $row->{read_datetime};
  return(1);
}


# ****************************************************************************
# * session                                                                  *
# ****************************************************************************

=head2 session

 Title:       session
 Usage:       &session($l,$e,\%row);
 Description: Cause an early exit from the processing loop.
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub session
{
  my($l,$e,$row) = @_;
  $main::BASE_CV = $row->{cv};
  $main::ES_TYPE = $row->{assay};
  return(1);
}


# ****************************************************************************
# * observation                                                              *
# ****************************************************************************

=head2 observation

 Title:       observation
 Usage:       &observation($l,$e,$row);
 Description: This routine will retrieve the session and
              add observations.
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub observation
{

  my($l,$e,$row) = @_;
  my $s = &main::getSession(cv => $main::BASE_CV,
                            cvterm => $main::ES_TYPE,
                            experiment => $e,
                            line => $l,
                            name => $main::ES_TYPE);
  if ($s) {
    $main::BASE_CV = 'disk_usage';
    &main::addGeneral($s,$row,$row->{location},'reading','observation');
  }
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

  perldoc JFRC::Utils::SAGE::fly_light_disk_usage

Copyright 2011 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
