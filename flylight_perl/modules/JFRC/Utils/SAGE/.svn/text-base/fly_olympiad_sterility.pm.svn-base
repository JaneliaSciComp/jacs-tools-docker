# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::fly_olympiad_sterility
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

JFRC::Utils::SAGE::fly_olympiad_sterility : fly_olympiad_sterility functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::fly_olympiad_sterility

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

package JFRC::Utils::SAGE::fly_olympiad_sterility;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = (all => [qw(transform experiment session score)]);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});
our @EXPORT = ('score');


# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
our $VERSION = '0.1';

my @REQUIRED = qw(exp_datetime experimenter humidity temperature);

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
 Description: Convert date/times
 Parameters:  row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub transform
{
  my $row = shift;
  # If we just get a date, make it a date/time
  foreach (qw(exp_datetime cross_date)) {
    unless (length($row->{$_})) {
      print STDERR "  Field $_ is null for line ",$row->{line},"\n";
      &main::submitJIRATicket({summary => "Field $_ is null for line "
                                          . $row->{line},
          description => "Field $_ is null for " . $row->{line}})
        if ($main::JIRA_PID);
      return();
    }
    $row->{$_} .= 'T000000' if ($row->{$_} =~ /^\d{8}$/);
  }
  $row->{flip_date} =
    &JFRC::Utils::SAGE::calculateFlipDate($row->{cross_date},$row->{flip_used});
  unless ($row->{flip_date}) {
    print STDERR "  Could not calculate flip_date\n";
    &main::submitJIRATicket({summary => 'Could not calculate flip date for '
                                        . $row->{line},
        description => 'Could not calculate flip date for ' . $row->{line}
                       . '  cross_date=' . $row->{cross_date} . ', flip_used='
                       . $row->{flip_used}})
      if ($main::JIRA_PID);
    return();
  }
  $row->{automated_pf} = ($row->{flag_redo}) ? 'F' : 'P';
  $row->{manual_pf} = 'U';
  $row->{archived} = 0;
  return(1);
}


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
  my @invalid;
  foreach (@REQUIRED) {
    push @invalid,$_ unless (length($row->{$_}));
  }
  if (scalar @invalid) {
    print STDERR "  Line $l->{name} has null fields: ",join(', ',@invalid),"\n";
    &main::submitJIRATicket({summary => "Null fields for " . $l->{name},
        description => "Experiment $l->{name} has null fields: "
                       . join(', ',@invalid)})
      if ($main::JIRA_PID);
    return(0);
  }
  $row->{$main::EXPERIMENT_KEY} = $l->{name} . ' ' . $row->{exp_datetime};
  if (-1 == $row->{cross_barcode}) {
    print STDERR "  Line $l->{name} has an unknown cross_barcode\n";
    &main::submitJIRATicket({summary => 'Unknown cross_barcode for ' . $l->{name},
        description => 'Experiment ' . $row->{$main::EXPERIMENT_KEY}
                       . 'has an unknown cross_barcode'})
      if ($main::JIRA_PID);
    return(0);
  }
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
 Description: Set the appropriate session name
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub session
{
  my($l,$e,$row) = @_;
  $row->{$main::SESSION_KEY} = join(' ',$l->{name},$row->{cross_barcode},
                                    $row->{rep},$row->{tube});
  return(1);
}


# ****************************************************************************
# * score                                                                    *
# ****************************************************************************

=head2 score

 Title:       score
 Usage:       &score($l,$e,$row);
 Description: Set the sterility flag to 0 or 1 based on input.
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              s:   Rose::DB Score object
              row: reference to the row hash
 Parameters:  NONE
 Returns:     1 for success, 0 for failure

=cut

sub score
{
  my($l,$e,$s,$row) = @_;
  $row->{sterile} = -1;
  &main::addGeneral($s,$row,('sterile')x2,'score');
  return(1);
  if ($row->{sterile} =~ /^[TtYy1]/) {
    $row->{sterile} = 1;
  }
  elsif ($row->{sterile} =~ /^[FfNn0]/) {
    $row->{sterile} = 0;
  }
  else {
    &terminateProgram('Bad sterility flag [' . $row->{sterile} . '] for '
                      . $l->{name});
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

  perldoc JFRC::Utils::SAGE::fly_olympiad_sterility

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
