# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE::light_imagery
# Written by:     Rob Svirskas
# Revision level: 0.2
# Date released:  2016-04-06
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
#     0.2     Rob Svirskas      16-04-06  Removed image key modification for
#                                         simpson/baker
# ****************************************************************************

# ****************************************************************************
# * POD documentation header start                                           *
# ****************************************************************************

=head1 NAME

JFRC::Utils::SAGE::light_imagery : light_imagery functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE::light_imagery

=head1 DESCRIPTION

There are currently two routines:

=over

image

postimage

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE::light_imagery;

use strict;
use warnings;
use Image::Size;
use Carp;
use Date::Manip qw(ParseDate UnixDate);
use URI::Escape;
use Zeiss::LSM;

require Exporter;
our @ISA = qw(Exporter);
# This allows declaration       use Foo::Bar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (all => [qw(image postimage)]);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});
our @EXPORT = ();


# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
our $VERSION = '0.1';

# ****************************************************************************
# * Variables                                                                *
# ****************************************************************************
my(@attenuator,@detector,@laser);
my $Prepared = 0;
my %sth = (
  ATTENUATOR => 'SELECT COUNT(1) FROM attenuator WHERE image_id=?',
  DETECTOR => 'SELECT COUNT(1) FROM detector WHERE image_id=?',
  LASER => 'SELECT COUNT(1) FROM laser WHERE image_id=?',
  LASERI => 'INSERT INTO laser (image_id,name,power) VALUES (?,?,?)',
);
my %SCOPE_MAP;

# ****************************************************************************
# * Callable routines                                                        *
# ****************************************************************************

sub AUTOLOAD
{ return(1); }


# ****************************************************************************
# * image                                                                    *
# ****************************************************************************

=head2 image

 Title:       image
 Usage:       &image();
 Description: This routine will return the display name for a given CV
              term.
 Parameters:  NONE
 Returns:     1 for success, 0 for failure

=cut

sub image
{
  my($l,$s,$row) = @_;
  $row->{source} = 'JFRC';
  ($row->{family} = $row->{designator}) =~ s/-/_/g;
  $row->{external_lab} = '' unless ($row->{external_lab});
  $row->{path} = (my $path = join('/',$row->{source_dir},$row->{source_file}));
  $row->{file_size} = (-s $path);
  $row->{url} = join('/','http://img.int.janelia.org',$row->{img_application},
                     $row->{designator} . '-confocal-data',uri_escape($row->{start}))
    if (exists $row->{img_application});
  if ((!-e $path) && ($path =~ /lsm$/)) {
    $path .= '.bz2';
    return(1) if (-e $path);
    if (!-e $path) {
      print $main::handle "  ERROR: could not find image file $path\n";
      return(0);
    }
  }
  # Fix stack to remove the image family
  #$row->{$main::IMAGE_KEY} =~ s/.+?\///
  #  if ('simpson' eq $main::LAB || 'baker' eq $main::LAB);
  #  *** No longer needed, unless we start to tmog simpson/baker images
  # Handle LSM files
  my $must_parse_lsm = 1;
  if ($main::SKIP_LSM_PARSE) {
    my($x) = $main::dbh->selectrow_array("SELECT dimension_x FROM image_data_mv WHERE name='" . $row->{$main::IMAGE_KEY} . "'");
    $must_parse_lsm = 0 if ($x);
  }
  if (($row->{extension} eq 'lsm') && ($must_parse_lsm)) {
    my %lsm;
    @attenuator = ();
    @detector = ();
    @laser = ();
    return(0) unless (&parseLSM($path,\%lsm,\@attenuator,\@detector,\@laser));
    # Created by
    $row->{created_by} = $lsm{created_by};
    delete $lsm{created_by};
    # Capture date (Stupid MS Access formatted date...)
    if ($lsm{sample_0time}) {
      my($hh,$mi,$ss,$dd,$mm,$yy) =
        localtime((int($lsm{sample_0time})-25568)*86400);
      my $f = ($lsm{sample_0time}- int($lsm{sample_0time})) * 86400;
      $f = ($f - ($ss = $f % 60)) / 60;
      $f = ($f - ($mi = $f % 60)) / 60;
      $f = ($f - ($hh = $f % 24)) / 24;
      my $datel = sprintf "%04d-%02d-%02d %02d:%02d:%02d",$yy+1900,$mm+1,$dd,$hh,$mi,$ss;
      $row->{date} = $datel if ($datel);
    }
    else {
      print $main::handle "  WARNING: could not find capture date in LSM\n";
    }
    # LSM attributes
    foreach my $k (keys %lsm) {
      push @main::IMAGE,$k unless (scalar(grep(/^$k$/,@main::IMAGE)));
      $row->{$k} = $lsm{$k};
    }
  }
  elsif ($main::SKIP_LSM_PARSE) {
    print $main::handle "  Skipping LSM parsing\n" if ($main::VERBOSE);
  }
  # Convert to .png if necessary
  if ($row->{convert_image}) {
    unless (-r $row->{target_path}) {
      print $main::handle "  Converting $row->{source_path}\n" if ($main::VERBOSE);
      `convert '$row->{source_path}' '$row->{target_path}'`;
    }
  }
  return(1);
}


# ****************************************************************************
# * addScanTime                                                              *
# ****************************************************************************

=head2 addScanTime

 Title:       addScanTime
 Usage:       Internal routine
 Description: Internal routine
 Parameters:  N/A
 Returns:     N/A

=cut
sub addScanTime
{
  my($row,$log_file) = @_;
  my $scan_handle = new IO::File $log_file,'<'
    or print $main::handle "  Could not open $log_file ($!)";
  return unless ($scan_handle);
  print $main::handle "  Extracting scan time from $log_file\n"
    if ($main::DEBUG);
  my ($istart,$istop,$rstart,$rstop,$sstart,$sstop);
  while ($_ = $scan_handle->getline) {
    next unless (my ($date,$time) = $_ =~ /^(\d{4}-\d{2}-\d{2}),(\d{2}:\d{2}:\d{2}\.\d+),/);
    if (/,Interpolation/) {
      if ($istart) {
        $istop = join ' ',$time,$date;
      }
      else {
        $istart = UnixDate(ParseDate(join ' ',$time,$date),"%s");
      }
    }
    elsif (/,Scan Starts/) {
      $sstart = UnixDate(ParseDate(join ' ',$time,$date),"%s");
    }
    elsif (/,Scan Ends/) {
      $sstop = UnixDate(ParseDate(join ' ',$time,$date),"%s");
    }
    elsif (/Starting RUN\./) {
      $rstart = UnixDate(ParseDate(join ' ',$time,$date),"%s");
    }
    elsif (/End RUN\./) {
      $rstop = UnixDate(ParseDate(join ' ',$time,$date),"%s");
    }
  }
  $scan_handle->close;
  if ($istart && $istop && $sstart && $sstop) {
    $istop = UnixDate(ParseDate($istop),"%s");
    $row->{interpolation_start} = $istart;
    $row->{interpolation_stop} = $istop;
    $row->{interpolation_elapsed} = &main::computeElapsedTime($istop-$istart);
    $row->{scan_start} = $sstart;
    $row->{scan_stop} = $sstop;
    $row->{scan_elapsed} = &main::computeElapsedTime($sstop-$sstart);
    if ($rstart && $rstop) {
      $row->{run_start} = $rstart;
      $row->{run_stop} = $rstop;
      $row->{run_elapsed} = &main::computeElapsedTime($rstop-$rstart);
    }
  }
}


# ****************************************************************************
# * parseLSM                                                                 *
# ****************************************************************************

=head2 parseLSM

 Title:       parseLSM
 Usage:       Internal routine
 Description: Internal routine
 Parameters:  N/A
 Returns:     N/A

=cut

sub parseLSM
{
my @SCANTYPE = ('normal x-y-z scan','z-scan','line scan','time series x-y',
                'time series x-z','time series Mean of ROIs','time series x-y-z',
                'spline scan','spline plane x-z',
                'time series spline plane x-z','point mode');

  my($path,$lsm_ref,$attn_ref,$det_ref,$laser_ref) = @_;
  # Instantiate a Zeiss::LSM object
  my $lsm;
  eval {
    $lsm = new Zeiss::LSM({stack => $path});
  };
  if ($@) {
    push @main::message,"$@ $path";
    print $main::handle "  $@ $path\n";
    return(0);
  }
  print $main::handle "  Parsed LSM $path\n" if ($main::DEBUG);
  # Simple "per-image" data
  my $ver = unpack('H8',$lsm->cz_private->MagicNumber);
  $lsm_ref->{dimension_x} = $lsm->cz_private->DimensionX;
  $lsm_ref->{dimension_y} = $lsm->cz_private->DimensionY;
  $lsm_ref->{dimension_z} = $lsm->cz_private->DimensionZ;
  $lsm_ref->{zoom_x} = $lsm->recording->RECORDING_ENTRY_ZOOM_X;
  $lsm_ref->{zoom_y} = $lsm->recording->RECORDING_ENTRY_ZOOM_Y;
  $lsm_ref->{zoom_z} = $lsm->recording->RECORDING_ENTRY_ZOOM_Z;
  $lsm_ref->{channels} = $lsm->cz_private->DimensionChannels;
  $lsm_ref->{total_pixels} = $lsm_ref->{dimension_x} * $lsm_ref->{dimension_y}
                             * $lsm_ref->{dimension_z} * $lsm_ref->{channels};
  $lsm_ref->{number_tracks} = $lsm->numTracks;
  $lsm_ref->{objective} = $lsm->recording->RECORDING_ENTRY_OBJECTIVE;
  $lsm_ref->{voxel_size_x} = sprintf '%.2f',$lsm->cz_private->VoxelSizeX*1e6;
  $lsm_ref->{voxel_size_y} = sprintf '%.2f',$lsm->cz_private->VoxelSizeY*1e6;
  $lsm_ref->{voxel_size_z} = sprintf '%.2f',$lsm->cz_private->VoxelSizeZ*1e6;
  $lsm_ref->{scan_type} = $SCANTYPE[$lsm->cz_private->ScanType] || 'unknown';
  $lsm_ref->{created_by} = $lsm->recording->RECORDING_ENTRY_USER;
  $lsm_ref->{sample_0time} = $lsm->recording->RECORDING_ENTRY_SAMPLE_0TIME;
  $lsm_ref->{sample_0z} = $lsm->recording->RECORDING_ENTRY_SAMPLE_0Z;
  $lsm_ref->{bc_correction1} = $lsm->recording->RECORDING_ENTRY_POSITIONBCCORRECTION1;
  $lsm_ref->{bc_correction2} = $lsm->recording->RECORDING_ENTRY_POSITIONBCCORRECTION2;
  (my $desc = $lsm->recording->RECORDING_ENTRY_DESCRIPTION) =~ s/^\s+$//;
  $lsm_ref->{description} = $lsm->recording->RECORDING_ENTRY_DESCRIPTION || '';
  (my $notes = $lsm->recording->RECORDING_ENTRY_NOTES || '') =~ s/^\s+//;
  $notes =~ s/\s+$//;
  $lsm_ref->{notes} = $notes;
  if (exists $lsm->{tags} && exists $lsm->{tags}{mac_address}) {
    unless (scalar %SCOPE_MAP) {
      my $ar = $main::dbh->selectall_arrayref("SELECT cv_term,display_name FROM cv_term_vw WHERE cv='microscope'");
      $SCOPE_MAP{$_->[0]} = $_->[1] foreach (@$ar);
    }
    my $mac_addr = $lsm->{tags}{mac_address};
    $lsm_ref->{mac_address} = $mac_addr;
    $lsm_ref->{microscope} = $SCOPE_MAP{$mac_addr} || $mac_addr;
  }
  else {
    $lsm_ref->{mac_address} = $lsm_ref->{microscope} = '';
  }
  my %hash;
  # Lasers
  foreach ($lsm->getLasers) {
    %hash = ();
    $hash{name} = $_->OLEDB_LASER_ENTRY_NAME;
    $hash{power} = sprintf '%0.3f mW',$_->OLEDB_LASER_ENTRY_POWER;
    push @$laser_ref,{%hash};
  }
  printf $main::handle "  Found %d laser%s:%s\n",scalar(@$laser_ref),
                       ((1 == scalar(@$laser_ref)) ? '' : 's'),
                       join(', ',map {$_->{name}} @$laser_ref);
  # Track data
  foreach my $track ($lsm->getTracks) {
    # Attenuators
    my $num = 1;
    foreach my $ic ($track->getIlluminationchannels) {
      %hash = ();
      $hash{num} = $num++;
      $hash{track} = $ic->ILLUMCHANNEL_ENTRY_NAME;
      $hash{wavelength} = sprintf '%.1f nm',$ic->ILLUMCHANNEL_ENTRY_WAVELENGTH;
      $hash{transmission} = sprintf '%.2f%%',$ic->ILLUMCHANNEL_ENTRY_POWER;
      $hash{acquire} = $ic->ILLUMCHANNEL_ENTRY_ACQUIRE;
      $hash{detchannel_name} = $ic->ILLUMCHANNEL_ENTRY_DETCHANNEL_NAME;
      $hash{power_bc1} = $ic->ILLUMCHANNEL_ENTRY_POWER_BC1;
      $hash{power_bc2} = $ic->ILLUMCHANNEL_ENTRY_POWER_BC2;
      if ((defined $hash{power_bc1}) && (defined $hash{power_bc2})
          && ($hash{power_bc1} != $hash{power_bc2})) {
        # P(n) = (P2-P1)*(Z0-(n-1)*dZ-Z1)/Z2-Z1)+P1
        my $dZ = $lsm_ref->{voxel_size_z};
        my $P1 = $hash{power_bc1};
        my $P2 = $hash{power_bc2};
        my $Z0 = $lsm_ref->{sample_0z};
        my $Z1 = $lsm_ref->{bc_correction1};
        my $Z2 = $lsm_ref->{bc_correction2};
        my ($bot_power,$top_power);
        eval {
          $top_power = ($P2-$P1)*($Z0-(1-1)*$dZ-$Z1)/($Z2-$Z1)+$P1;
          ($top_power < 0) && ($top_power = 0);
          $bot_power = ($P2-$P1)*($Z0-($lsm_ref->{dimension_z}-1)*$dZ-$Z1)/($Z2-$Z1)+$P1;
        };
        unless ($@) {
          $hash{ramp_low_power} = sprintf '%.2f',$top_power;
          $hash{ramp_high_power} = sprintf '%.2f',$bot_power;
        }
        else{
         printf $main::handle "  Could not calc ramp for image: $path";
        }
      }
      push @$attn_ref,{%hash};
    }
    # Detectors
    $num = 1;
    foreach my $dc ($track->getDetectionchannels) {
      %hash = ();
      $hash{num} = $num++;
      $hash{track} = $track->TRACK_ENTRY_NAME;
      $hash{image_channel_name} = $dc->DETCHANNEL_DETECTION_CHANNEL_NAME;
      $hash{detector_voltage} = sprintf '%.3f V',
          $dc->DETCHANNEL_ENTRY_DETECTOR_GAIN;
      $hash{detector_voltage_first} = sprintf '%.3f V',
          $dc->DETCHANNEL_ENTRY_DETECTOR_GAIN_BC1;
      $hash{detector_voltage_last} = sprintf '%.3f V',
          $dc->DETCHANNEL_ENTRY_DETECTOR_GAIN_BC2;
      $hash{amplifier_gain} = sprintf '%.3f',
          $dc->DETCHANNEL_ENTRY_AMPLIFIER_GAIN;
      $hash{amplifier_gain_first} = sprintf '%.3f',
          $dc->DETCHANNEL_ENTRY_AMPLIFIER_GAIN_BC1;
      $hash{amplifier_gain_last} = sprintf '%.3f',
          $dc->DETCHANNEL_ENTRY_AMPLIFIER_GAIN_BC2;
      $hash{amplifier_offset} = sprintf '%.3f',
          $dc->DETCHANNEL_ENTRY_AMPLIFIER_OFFS;
      $hash{amplifier_offset_first} = sprintf '%.3f',
          $dc->DETCHANNEL_ENTRY_AMPLIFIER_OFFS_BC1;
      $hash{amplifier_offset_last} = sprintf '%.3f',
          $dc->DETCHANNEL_ENTRY_AMPLIFIER_OFFS_BC2;
      $hash{pinhole_diameter} = sprintf '%.2f &micro;m',
          $dc->DETCHANNEL_ENTRY_PINHOLE_DIAMETER;
      $hash{filter} = $dc->DETCHANNEL_FILTER_NAME;
      $hash{wavelength_start} = $dc->DETCHANNEL_ENTRY_SPI_WAVELENGTH_START;
      $hash{wavelength_end} = $dc->DETCHANNEL_ENTRY_SPI_WAVELENGTH_END;
      $hash{dye_name} = $dc->DETCHANNEL_ENTRY_DYE_NAME;
      $hash{digital_gain} = ($dc->DETCHANNEL_DIGITAL_GAIN)
        ? (sprintf '%.5f',$dc->DETCHANNEL_DIGITAL_GAIN) : '0.00000';
      $hash{point_detector_name} = $dc->DETCHANNEL_POINT_DETECTOR_NAME;
      $hash{pinhole_name} = $dc->DETCHANNEL_PINHOLE_NAME;
      foreach my $dac ($track->getDatachannels) {
        $lsm_ref->{bits_per_sample} = $dac->DATACHANNEL_ENTRY_BITSPERSAMPLE
          unless ($lsm_ref->{bits_per_sample});
        next unless ($dac->DATACHANNEL_ENTRY_NAME
                     eq $dc->DETCHANNEL_DETECTION_CHANNEL_NAME);
        $hash{color} = '#'.unpack('H6',pack('L',$dac->DATACHANNEL_ENTRY_COLOR));
      }
      push @$det_ref,{%hash};
    }
  }
  return(1);
}


# ****************************************************************************
# * postimage                                                                *
# ****************************************************************************

=head2 postimage

 Title:       postimage
 Usage:       &postimage();
 Description: This routine will handle post-image insertion special
              processing.
 Parameters:  $i: Rose::DB image object
 Returns:     1 for success, 0 for failure

=cut

sub postimage
{
  my($i,$row) = @_;
  return (1) unless ($row->{extension} eq 'lsm');
  my $rv;
  unless ($Prepared) {
    $sth{$_} = $main::dbh->prepare($sth{$_})
      || &main::terminateProgram($main::dbh->errstr) foreach (keys %sth);
    $Prepared++;
  }
  my $hash;
  # Lasers
  $sth{LASER}->execute(my $iid = $i->id);
  my $count = $sth{LASER}->fetchrow_array();
  if ($count) {
    printf $main::handle "  Found %d laser entr%s\n",$count,
                         (1 == $count) ? 'y' : 'ies' if ($main::DEBUG);
    $main::count{laserfound} += $count;
  }
  else {
    foreach $hash (@laser) {
      $rv = $sth{LASERI}->execute($iid,$hash->{name},$hash->{power}||'');
      print $main::handle "  Added laser ",$hash->{name},' (',
                          $hash->{power}||'',")\n" if ($main::DEBUG);
      $main::count{laseradd}++;
    }
  }
  @laser = ();
  # Attenuators
  $sth{ATTENUATOR}->execute($iid);
  $count = $sth{ATTENUATOR}->fetchrow_array();
  if ($count) {
    printf $main::handle "  Found %d attenuator entr%s\n",$count,
                         (1 == $count) ? 'y' : 'ies' if ($main::DEBUG);
    $main::count{attenuatorfound} += $count;
  }
  else {
    foreach $hash (@attenuator) {
      my @value;
      my $sql = 'INSERT INTO attenuator (image_id,';
      foreach (sort keys %$hash) {
        $sql .= "$_,";
        push @value,$hash->{$_};
      }
      next unless (scalar @value);
      unshift @value,$iid;
      $sql =~ s/,$/)/;
      $sql .= ' VALUES (' . join(',',map { $main::dbh->quote($_) } @value) . ')';
      $rv = $main::dbh->do($sql);
      print $main::handle "  Added attenuator ",$hash->{track},"\n"
                          if ($main::DEBUG);
      $main::count{attenuatoradd}++;
    }
  }
  @attenuator = ();
  # Detectors
  $sth{DETECTOR}->execute($iid);
  $count = $sth{DETECTOR}->fetchrow_array();
  if ($count) {
    printf $main::handle "  Found %d detector entr%s\n",$count,
                         (1 == $count) ? 'y' : 'ies' if ($main::DEBUG);
    $main::count{detectorfound} += $count;
  }
  else {
    foreach $hash (@detector) {
      my @value;
      my $sql = 'INSERT INTO detector (image_id,';
      foreach (sort keys %$hash) {
        $sql .= "$_,";
        push @value,$hash->{$_};
      }
      next unless (scalar @value);
      unshift @value,$iid;
      $sql =~ s/,$/)/;
      $sql .= ' VALUES (' . join(',',map { $main::dbh->quote($_) } @value) . ')';
      $rv = $main::dbh->do($sql);
      print $main::handle "  Added detector ",$hash->{track},' (',
                          $hash->{image_channel_name},")\n" if ($main::DEBUG);
      $main::count{detectoradd}++;
    }
  }
  @detector = ();
  # Extract scan times from .log.csv file
  (my $log_file = $row->{path}) =~ s/\.lsm$/_log.csv/;
  if (-e $log_file) {
    &addScanTime($row,$log_file);
  }
  else {
    print $main::handle "  Scan log $log_file was not found\n";
  }
  if (exists $row->{interpolation_start}) {
    foreach (map { 'interpolation_'.$_,'scan_'.$_ } qw(start stop elapsed)) {
      &main::addGeneral($i,$row,($_)x2,'imageprop');
    }
    foreach (qw(run_start run_stop run_elapsed)) {
      &main::addGeneral($i,$row,($_)x2,'imageprop') if (exists $row->{$_});
    }
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

  perldoc JFRC::Utils::SAGE::light_imagery

Copyright 2010 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
