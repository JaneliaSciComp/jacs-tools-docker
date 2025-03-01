# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::fly_olympiad_observation
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

JFRC::Utils::SAGE::fly_olympiad_observation : fly_olympiad_observation functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::fly_olympiad_observation

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

package JFRC::Utils::SAGE::fly_olympiad_observation;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = (all => [qw(session transform)]);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});
our @EXPORT = ();


# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
our $VERSION = '0.1';
my @OBS = qw(per pec perc ptouch pspit pleg plick plab pdrop gbody ghead gant
             gprob gwing gabd gterm ghind grub gback gunc gnone lhyper lred ljump
             lback lside lturn lspin lab psunc psfall psseize pspar pssplay
             psnar pshunch pscontort pswiggly psab wup wdn wside wflap wflix
             wsin wab acurl along around apoint avib atrans awag aup aside
             aab hyes hno hdn hant tmale tfem tegg tliq tsol tpull sred smfc
             smmc sffc sfmc sffa smma sfma smfa sab);
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
 Description: Transform TRUE/FALSE into Y/N
 Parameters:  row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub transform
{
  my $row = shift;
  # Check observations and convert
  foreach (@OBS) {
    unless (length $row->{$_}) {
      print $main::handle "  Null value found for $_\n";
      return(0);
    }
    $row->{$_} = ('TRUE' eq uc($row->{$_})) ? 'Y' : 'N';
    $row->{$_.'_gender'} = &convertGender($row->{$_.'_gender'});
  }
  # Default null columns, and change TRUE/FALSE to Y/N
  foreach (qw(aint gint hint lint pint psint sint tint wint
              flag_aborted roompheno)) {
    # Null columns are FALSE by default
    $row->{$_} = 'FALSE' if (!exists $row->{$_} || !length $row->{$_});
    $row->{$_} = ('TRUE' eq uc($row->{$_})) ? 'Y' : 'N';
  }
  $row->{gender} = &convertGender($row->{gender});
  # If we just get a date, make it a date/time
  foreach (qw(exp_datetime cross_date)) {
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
  $row->{automated_pf} = 'P';
  $row->{automated_pf} = 'F'
    if ($row->{flag_redo} || (abs(29 - $row->{temperature}) > 1)
        || (abs(50 - $row->{humidity}) > 3));
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
 Description: Set the appropriate experiment key
 Parameters:  l:   Rose::DB Line object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub experiment
{
  my($l,$row) = @_;
  my @invalid;
  unless ($row->{exp_datetime}) {
    print STDERR "  Line $l->{name} has no exp_datetime\n";
    &main::submitJIRATicket({summary => "Missing exp_datetime for ".$l->{name},
        description => "Line $l->{name} has no exp_datetime"})
      if ($main::JIRA_PID);
    return(0);
  }
  $row->{$main::EXPERIMENT_KEY} = $l->{name} . ' ' . $row->{exp_datetime};
  $main::ALT_CV{$_} = 'fly_olympiad_qc' foreach (qw(manual_pf automated_pf));
  return(1);
}


# ****************************************************************************
# * session                                                                  *
# ****************************************************************************

=head2 session

 Title:       session
 Usage:       &session($l,$e,$row);
 Description: Set the appropriate sessions
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub session
{
  my($l,$e,$row) = @_;
  my $line = $l->{name};
  my $found_phenotypes = 0;
  foreach my $stype (@OBS) {
    if (('N' eq $row->{$stype})
       && ($row->{$stype.'_gender'} || $row->{$stype.'_penetrance'})) {
      print STDERR "  Experiment $e->{name} has gender/penetrance data "
                   . "but no observation for $stype\n";
      &main::submitJIRATicket({summary => 'Inconsistent observation data for '
          . $e->{name},
          description => "Experiment $e->{name} has gender/"
                         . "penetrance data but no observation for $stype"})
        if ($main::JIRA_PID);
      return(0);
    }
    my $s = &main::getSession(cv => $main::BASE_CV,
                              cvterm => $stype,
                              experiment => $e,
                              line => $l,
                              name => $stype);
    &main::addGeneral($s,$row,'observed',$stype,'observation');
    if ('Y' eq $row->{$stype}) {
      foreach (qw(gender penetrance)) {
        &main::addGeneral($s,$row,$_,$stype."_$_",'observation')
          if (exists $row->{$stype."_$_"});
      }
      $found_phenotypes++;
    }
  }
  # Set experimental properties
  $row->{no_phenotypes} = ($found_phenotypes) ? 'N' : 'Y';
  &main::addGeneral($e,$row,('no_phenotypes')x2,'experimentprop');
if (0) {
  $row->{automated_pf} = 'P';
  $row->{automated_pf} = 'F'
    if ($row->{flag_redo} || (abs(29 - $row->{temperature}) > 1)
        || (abs(50 - $row->{humidity}) > 3));
  &main::addGeneral($e,$row,('automated_pf')x2,'experimentprop');
}
  return(1);
}

# ****************************************************************************
# * convertGender                                                            *
# ****************************************************************************

=head2 convertGender

 Title:       convertGender
 Usage:       $g = &convertGender('male');
 Description: Return a gender abbreviation
 Parameters:  g: gender
 Returns:     gender abbreviation

=cut

sub convertGender
{
    my $g = shift;
    return() unless ($g);
    if ($g =~ /^male/i) {
        return('m');
    }
    elsif ($g =~ /^female/i) {
        return('f');
    }
    elsif ($g =~ /^both/i) {
        return('b');
    }
    else {
        return('x');
    }
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

  perldoc JFRC::Utils::SAGE::fly_olympiad_observation

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
