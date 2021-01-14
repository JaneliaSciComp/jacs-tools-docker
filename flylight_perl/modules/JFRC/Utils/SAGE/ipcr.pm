# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::ipcr
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

JFRC::Utils::SAGE::ipcr : ipcr functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::ipcr

=head1 DESCRIPTION

There are currently two routines:

=over

transform

line

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::ipcr;

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
# This allows declaration       use Foo::Bar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (all => [qw(transform line)]);
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
 Usage:       &transform();
 Description: This routine will transform a Simpson line name to include
              the "JHS_" prefix.
 Parameters:  row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub transform
{
  my $row = shift;
  my($letter,$number) = $row->{line} =~ /^([A-Za-z]+)(\d+)(?:[ -]GAL4)?$/;
  my $new;
  unless ($letter && length($number)) {
    print $main::handle "  Could not transform $row->{line}\n";
    return(0);
  }
  if ($letter eq 'G') {
    $new = sprintf 'JHS_%s%02d-GAL4',$letter,$number;
  }
  else {
    $new = sprintf 'JHS_%s%03d-GAL4',$letter,$number;
  }
  $row->{line} = $new;
  return(1);
}


# ****************************************************************************
# * line                                                                     *
# ****************************************************************************

=head2 line

 Title:       line
 Usage:       &transform($l,$row);
 Description: This routine will fetch the gene (as a CG) from SAGE
              given an abbreviation.
 Parameters:  l:   Rose::DB Line object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut
sub line
{
  my($l,$row) = @_;
  if ((my $gene = $row->{trapped}) && (!$l->gene_id)) {
  $gene = 'CG31366' if ($gene =~ /^hsp70a$/i); #PLUG
  $gene = 'CG10045' if ($gene =~ /^gst1$/i); #PLUG
  $gene = 'CG2671' if ($gene =~ /^lgl$/i); #PLUG
    my $cph = $main::dbh->prepare("CALL getGene('$gene')");
    $cph->execute();
    my $r = $cph->fetchrow_array();
    unless ($r) {
      print $main::handle "  Gene $gene is not in SAGE\n";
      $main::count{gene}++;
      $main::unknown{$gene}++;
      return(0);
    }
    $l->gene_id(&main::getGeneID($r));
    $l->save;
    print $main::handle "  Set gene to $r\n";
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

  perldoc JFRC::Utils::SAGE::ipcr

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
