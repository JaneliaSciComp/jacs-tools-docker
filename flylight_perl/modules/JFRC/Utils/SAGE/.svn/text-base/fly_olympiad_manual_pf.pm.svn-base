# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::fly_olympiad_manual_pf
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

JFRC::Utils::SAGE::fly_olympiad_manual_pf : fly_olympiad_curation

=head1 SYNOPSIS

use JFRC::Utils::SAGE::fly_olympiad_manual_pf

=head1 DESCRIPTION

There are currently two routines:

=over

transform

session

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::fly_olympiad_manual_pf;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = (all => [qw(transform session)]);
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
# * transform                                                                *
# ****************************************************************************

=head2 transform

 Title:       transform
 Usage:       &transform($row);
 Description: Set curation data
 Parameters:  row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub transform
{
  my $row = shift;
  $row->{manual_pf} = uc($row->{manual_pf});
  if ($row->{manual_pf} eq 'U' || !length($row->{manual_pf})) {
    $main::EARLY_EXIT = 1;
    return(0);
  }
  unless ($row->{manual_pf} =~ /^[PFU]$/) {
    print STDERR 'Illegal entry (',$row->{manual_pf},") for manual_pf\n";
    &main::submitJIRATicket({summary => 'Illegal manual_pf entry for '
                                        . $row->{line},
        description => 'Illegal manual_pf entry (' . $row->{manual_pf}
                       . ') for ' . $row->{line}})
      if ($main::JIRA_PID);
    return(0);
  }
  $row->{manual_curator} = $main::username
    if (!$row->{manual_curator} && $main::username);
  return(1);
}


# ****************************************************************************
# * session                                                                  *
# ****************************************************************************

=head2 session

 Title:       session
 Usage:       &session(\%row);
 Description: Cause an early exit from the processing loop.
 Parameters:  row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub session
{
  $main::EARLY_EXIT = 1;
  return(0);
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

  perldoc JFRC::Utils::SAGE::fly_olympiad_manual_pf

Copyright 2011 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
