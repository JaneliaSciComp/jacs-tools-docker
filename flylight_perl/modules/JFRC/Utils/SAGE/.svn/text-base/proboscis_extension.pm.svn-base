# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::proboscis_extension
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

JFRC::Utils::SAGE::proboscis_extension : proboscis_extension functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::proboscis_extension

=head1 DESCRIPTION

There are currently three routines:

=over

preload

session

observation

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::proboscis_extension;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
# This allows declaration       use Foo::Bar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (all => [qw(preload session observation)]);
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
# * preload                                                                  *
# ****************************************************************************

=head2 preload

 Title:       preload
 Usage:       &preload();
 Description: This routine will delete control sessions
 Parameters:  NONE
 Returns:     1 for success, 0 for failure

=cut

sub preload
{
  print $main::handle "Deleting control sessions\n" if ($main::VERBOSE);
  my $controls = join(',',map { "'$_'"} @main::CONTROL);
  my $ar = $main::dbh->selectcol_arrayref('SELECT id FROM session_vw WHERE line IN '
                                          . "($controls) AND type='"
                                          . $main::BASE_CV . "' AND lab='"
                                          . $main::LAB . "'");
  if (scalar @$ar) {
    print $main::handle '  Deleting ',join(', ',@$ar),"\n";
    $controls = join(',',@$ar);
    my $rv  = $main::dbh->do("DELETE FROM session WHERE id IN ($controls)");
    &terminateProgram('Could not delete control sessions')
      unless ($rv == scalar(@$ar));
  }
  return(1);
}


# ****************************************************************************
# * session                                                                  *
# ****************************************************************************

=head2 session

 Title:       session
 Usage:       &session($l,$row);
 Description: This routine will set the session name according to a run number
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut
sub session
{
  my($l,$e,$row) = @_;
  my $line = $l->{name};
  if (grep {/^$line$/} @main::CONTROL) {
    $row->{$main::SESSION_KEY} = 'Trp_obs_' . ++$main::control_session{$line};
  }
  return(1);
}


# ****************************************************************************
# * observation                                                              *
# ****************************************************************************

=head2 observation

 Title:       observation
 Usage:       &observation($l,$e,$row);
 Description: This routine will set the time and temperature
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut
sub observation
{
  my($l,$e,$row) = @_;
  $row->{time} ||= '00:00';
  $row->{time} = '0' . $row->{time} if ($row->{time} =~ /^\d:\d{2}$/);
  $row->{timestamp} = $row->{date} . ' ' . $row->{time};
  if ($row->{temperature}) {
    $row->{temp_type} = ($row->{temperature} < 24.0) ? 'permissive'
                                                     : 'restrictive';
  }
  else {
    $row->{temp_type} = '';
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

  perldoc JFRC::Utils::SAGE::proboscis_extension

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
