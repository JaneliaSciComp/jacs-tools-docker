# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::grooming
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

JFRC::Utils::SAGE::grooming : grooming functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::grooming

=head1 DESCRIPTION

There are currently four routines:

=over

experiment

observation

score

image

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::grooming;

use strict;
use warnings;
use Image::Size;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
# This allows declaration       use Foo::Bar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (all => [qw(preload experiment observation score image)]);
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
 Description: This routine will delete all grooming experiments
              and sessions.
 Parameters:  NONE
 Returns:     1 for success, 0 for failure

=cut

sub preload
{
  return(1) if ($main::IMAGE_KEY);
  print $main::handle "Deleting grooming experiments\n" if ($main::VERBOSE);
  my $rv  = $main::dbh->do("DELETE FROM experiment WHERE type_id IN (SELECT id FROM cv_term_vw WHERE cv='grooming')");
  printf $main::handle "  Deleted %d experiment%s\n",$rv,((1 == $rv) ? '' : 's')
    if ($main::VERBOSE);
  print $main::handle "Deleting grooming sessions\n" if ($main::VERBOSE);
  $rv  = $main::dbh->do("DELETE FROM session WHERE type_id IN (SELECT id FROM cv_term_vw WHERE cv='grooming')");
  printf $main::handle "  Deleted %d session%s\n",$rv,((1 == $rv) ? '' : 's')
    if ($main::VERBOSE);
}


# ****************************************************************************
# * experiment                                                               *
# ****************************************************************************

=head2 experiment

 Title:       experiment
 Usage:       &experiment($l,$row);
 Description: This routine will add session properties for the
              three "imaged" booleans.
 Parameters:  l:   Rose::DB Line object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub experiment
{
  my($l,$row) = @_;
  $row->{$_ . '_imaged'} = 'N'
    foreach (qw(evidence experimental expression));
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
my %save;

  my($l,$e,$row) = @_;
  foreach (@main::FIELD) {
    next unless ($_->{type} eq 'observation_special');
    next unless ($row->{$_->{term}});
    my($sess,$term) = $_->{term} =~ /^(.+)_(.+)$/;
    my $s = $save{$sess}
            || &main::getSession(cv => $main::BASE_CV,
                                 cvterm => $sess,
                                 experiment => $e,
                                 line => $l,
                                 name => $row->{$main::SESSION_KEY});
    if ($s) {
      $save{$sess} = $s;
      &main::addGeneral($s,$row,$term,$sess.'_'.$term,'observation');
    }
  }
  return(1);
}


# ****************************************************************************
# * score                                                                    *
# ****************************************************************************

=head2 score

 Title:       score
 Usage:       &score();
 Description: This routine will retrieve the session and
              add scores.
 Parameters:  l:   Rose::DB Line object
              e:   Rose::DB Experiment object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub score
{
my %save;

  my($l,$e,$row) = @_;
  my $line_id = $l->id;
  my @sess = qw(experimental experimental_decap permissive restrictive stock
                stock_control tnt trpa);
  foreach my $type (@sess) {
    my $expected = ($type =~ /decap/) ? 2 : 4;
    my $cell = $row->{$type.'_scores'} || next;
    $cell =~ s/^\s*\/?\s*//;
    $cell =~ s/\s*\/?\s*$//;
    my @run = split(/\s*\/\s*/,$cell);
    next unless (scalar @run);
    my $run_num = 1;
    foreach my $run (@run) {
      my @score = split(/\s*-\s*/,$run);
      &terminateProgram("Improperly formatted $type scores ($run) for line "
                        . "ID $line_id")
        unless ($expected == scalar(@score));
      foreach my $score (@score) {
        &terminateProgram("Improperly formatted $type scores ($score) for "
                          . "line ID $line_id")
          unless ($score =~ /^[0-9]*\.?[0-9]+$/);
      }
      my $s = $save{$type}
              || &main::getSession(cv => $main::BASE_CV,
                                   cvterm => $type,
                                   experiment => $e,
                                   line => $l,
                                   name => $row->{$main::SESSION_KEY});
      $save{$type} = $s;
      my @type = qw(wing notum);
      unshift @type,qw(eye head) if (4 == $expected);
      foreach (map { $_ . '_score' } @type) {
        $row->{'_'.$_} = shift @score;
        &main::addGeneral($s,$row,$_,'_'.$_,'score',$run_num);
      }
      $run_num++;
    }
  }
  return(1);
}


# ****************************************************************************
# * image                                                                    *
# ****************************************************************************

=head2 image

 Title:       image
 Usage:       &image($l,$s,$row);
 Description: This routine will prepare secondary data and comments for
              storage.
 Parameters:  l:   Rose::DB Line object
              s:   Rose::DB Session object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut

sub image
{
  my($l,$s,$row) = @_;
  return(0) if ($row->{target_file} =~ /\.temp\.mp4$/);
  if ($row->{target_file} =~ /\.txt$/) {
    my $cs = &main::getSession(cv => $main::BASE_CV,
                               cvterm => $row->{product},
                               line => $l,
                               name => $row->{area});
    # Slurp!
    open HANDLE,$row->{target_path};
    sysread HANDLE,$row->{comment},-s HANDLE;
    close(HANDLE);
    &main::addGeneral($cs,$row,('comment')x2,'observation');
    return(0);
  }
  $row->{class} = '';
  my $save_product = $row->{product};
  if ($row->{product} =~ /experimental/) {
    $row->{product} = 'experimental_imaged';
    $row->{class} = $row->{area};
    $row->{area} = '';
  }
  elsif ($row->{product} =~ /expression/) {
    $row->{product} = 'expression_imaged';
  }
  else {
    $row->{product} = 'evidence_imaged';
  }
  $row->{$row->{product}} = 'Y';
  &main::addGeneral($s,$row,($row->{product})x2,'sessionprop');
  ($row->{width},$row->{height}) = ('')x2;
  if ($row->{target_path} =~ /\.jpg$/) {
    unless (-r $row->{target_path}) {
      print $main::handle "  Converting $row->{source_path}\n" if ($main::VERBOSE);
      `convert '$row->{source_path}' '$row->{target_path}'`;
    }
    # Get image size
    unless (-r $row->{target_path}) {
      print $main::handle "  Could not read $row->{target_path}\n";
      return(0);
    }
    ($row->{width},$row->{height}) = imgsize($row->{target_path});
  }
  elsif ($row->{target_path} =~ /\.mp4$/) {
    unless (-r $row->{target_path}) {
      print $main::handle "  Converting $row->{source_path}\n" if ($main::VERBOSE);
      `/usr/bin/ffmpeg -i '$row->{source_path}' -b 1000000 '$row->{target_path}'`;
    }
    # Get image size
    unless (-r $row->{target_path}) {
      print $main::handle "  Could not read $row->{target_path}\n";
      return(0);
    }
  }
  $row->{file_size} = (-s "$row->{target_path}");
  $row->{product} = $save_product;
  $row->{representative} = ($row->{target_path} =~ /representative\.\S+$/) ? 1 : 0;
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

  perldoc JFRC::Utils::SAGE::grooming

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
