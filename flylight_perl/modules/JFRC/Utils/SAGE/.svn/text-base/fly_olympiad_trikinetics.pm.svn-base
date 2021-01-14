# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::fly_olympiad_trikinetics
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

JFRC::Utils::SAGE::fly_olympiad_trikinetics : fly_olympiad_trikinetics functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::fly_olympiad_trikinetics

=head1 DESCRIPTION

There are currently three routines:

=over

session

observation

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::fly_olympiad_trikinetics;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = (all => [qw(transform experiment session)]);
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
 Description: Set the experimenter, experiment date/time, and file system path
 Parameters:  l:   Rose::DB Line object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub experiment
{
  my($l,$row) = @_;
  foreach (qw(exp_datetime incubator)) {
    unless ($row->{$_}) {
      print STDERR "  Line $l->{name} has no $_\n";
      &main::submitJIRATicket({summary => "Missing $_ for ".$l->{name},
          description => "Line $l->{name} has no $_"})
        if ($main::JIRA_PID);
      return(0);
    }
  }
  $row->{$main::EXPERIMENT_KEY} = $row->{exp_datetime} . ' ' . $row->{incubator};
  $row->{flag_legacy} = 0;
  $main::ALT_CV{$_} = 'fly_olympiad_qc' foreach (qw(manual_pf automated_pf));
  return(1);
}


my %session_count;

# ****************************************************************************
# * session                                                                  *
# ****************************************************************************

=head2 session

 Title:       session
 Usage:       &session($l,$row);
 Description: Set the appropriate session name using a run number
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub session
{
  my($l,$e,$row) = @_;
  foreach (qw(behavior_monitor start_channel channels_filled)) {
    unless ($row->{$_}) {
      print STDERR "  Line $l->{name} has no $_\n";
      &main::submitJIRATicket({summary => "Missing $_ for ".$l->{name},
          description => "Line $l->{name} has no $_"})
        if ($main::JIRA_PID);
      return(0);
    }
  }
  my $monitor = $row->{behavior_monitor};
  my $start = $row->{start_channel};
  my $num_channels = $row->{channels_filled};
  foreach my $channel (1..$num_channels) {
    my $name = sprintf 'Monitor %d Channel %d',$monitor,$start+$channel-1;
    my $s = &main::getSession(cv => $main::BASE_CV,
                              cvterm => 'crossings',
                              experiment => $e,
                              line => $l,
                              name => $name);

    # Check for missing session properties
    my @missing;
    foreach (@main::SESSION) {
      push @missing,$_
        if ($main::REQUIRED{$_} && (!exists($row->{$_}) || !length($row->{$_})));
    }
    if (scalar @missing) {
      print STDERR "  Session $s->{name} has null fields: ",
                   join(', ',@missing),"\n";
      &submitJIRATicket({summary => "Null fields for " . $l->{name},
          description => "Session $s->{name} has null fields: "
                         . join(', ',@missing)})
        if ($main::JIRA_PID);
      $main::count{incomplete}++;
      return;
    }
    # Add session properties
    $row->{num_flies_dead} = $row->{sprintf 'num_flies_dead_%d',$channel};
    $row->{automated_pf} = $row->{manual_pf} = 'U';
    &main::addGeneral($s,$row,($_)x2,'sessionprop') foreach (@main::SESSION);
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

  perldoc JFRC::Utils::SAGE::fly_olympiad_trikinetics

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
