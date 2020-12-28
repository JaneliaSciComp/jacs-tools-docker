# ****************************************************************************
# Resource name:  Zeiss::LSM
# Written by:     Rob Svirskas, Jody Clements
# Revision level: 1.0
# Date released:  2020-01-22
# Description:    This module uses POD documentation.
# Required resources:
#   Programs:       NONE
#   USEd modules:   strict
#                   warnings
#                   Carp
#                   IO::File
#                   Switch
#                   Class::Accessor::Fast
#                   Zeiss::LSM::CZPrivate
#                   Zeiss::LSM::Channel
#                   Zeiss::LSM::Recording
#                   Zeiss::LSM::Laser
#                   Zeiss::LSM::Timer
#                   Zeiss::LSM::Marker
#                   Zeiss::LSM::Track
#
#                               REVISION HISTORY
# ----------------------------------------------------------------------------
# | revision | name            | date    | description                       |
# ----------------------------------------------------------------------------
#     0.1     Rob Svirskas      08-05-30  Initial version
#     0.2     Rob Svirskas      08-06-02  Added Level 1 track accessors.
#     0.3     Rob Svirskas      08-06-12  Fixed a few field typos, added Zen
#                                         unknown fields.
#     0.4     Rob Svirskas      08-07-28  Modified unknown fields as per
#                                         Z. Iwinski (Zeiss).
#     0.5     Rob Svirskas      08-08-11  Modified DETCH_LASER_SUPPRESSION
#                                         type.
#     0.6     Rob Svirskas      08-10-31  Ya know, I'm really starting to get
#                                         miffed about these UNDOCUMENTED
#                                         types. The latest is in the
#                                         illumination subblock.
#     0.7     Jody Clements     14-12-12  Adds bunzip2. When passed a compressed
#                                         file, it will be inflated into a temporary
#                                         directory and then parsed for meta data.
#     1.0     Rob Svirskas      20-01-22  Ignore unknown data types in the Tag
#                                         block.
# ****************************************************************************
package Zeiss::LSM;

use strict;
use warnings;
use Carp;
use IO::File;
use IO::Uncompress::Bunzip2 qw(bunzip2 $Bunzip2Error);
use File::Temp qw(tempfile tempdir);
use Switch;
use base 'Class::Accessor::Fast';

use Zeiss::LSM::CZPrivate;
use Zeiss::LSM::Channel;
use Zeiss::LSM::Recording;
use Zeiss::LSM::Laser;
use Zeiss::LSM::Timer;
use Zeiss::LSM::Marker;
use Zeiss::LSM::Track;


# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
our $VERSION = '0.7';

use constant BYTE_ORDER      => 0x4949;
use constant TIFF_IDENTIFIER => 42;
use constant TIF_CZ_LSMINFO  => 34412;
use constant ASCII           => 2;
use constant LONG            => 4;
use constant RATIONAL        => 5;
use constant SUBBLOCK        => 0;
use constant HEX             => -2;
use constant SUBBLOCK_END    => 0x0ffffffff;

my %TYPE_MAP = (
  2  => 'ASCII',
  4  => 'long',
  5  => 'rational',
  0  => 'subblock',
  -2 => 'hex',
);
# Acquisition information
# See pp 46-66, "Image File Format Description", Release 4.0
our %SUBBLOCK = (
  # Recording
  0x010000000 => [SUBBLOCK,'SUBBLOCK_RECORDING'],
  0x010000001 => [ASCII,'RECORDING_ENTRY_NAME'],
  0x010000002 => [ASCII,'RECORDING_ENTRY_DESCRIPTION'],
  0x010000003 => [ASCII,'RECORDING_ENTRY_NOTES'],
  0x010000004 => [ASCII,'RECORDING_ENTRY_OBJECTIVE'],
  0x010000005 => [ASCII,'RECORDING_ENTRY_PROCESSING_SUMMARY'],
  0x010000006 => [ASCII,'RECORDING_ENTRY_SPECIAL_SCAN_MODE'],
  0x010000007 => [ASCII,'RECORDING_ENTRY_SCAN_LINE'],
  0x010000008 => [ASCII,'RECORDING_ENTRY_SCAN_MODE'],
  0x010000009 => [LONG,'RECORDING_ENTRY_NUMBER_OF_STACKS'],
  0x01000000a => [LONG,'RECORDING_ENTRY_LINES_PER_PLANE'],
  0x01000000b => [LONG,'RECORDING_ENTRY_SAMPLES_PER_LINE'],
  0x01000000c => [LONG,'RECORDING_ENTRY_PLANES_PER_VOLUME'],
  0x01000000d => [LONG,'RECORDING_ENTRY_IMAGES_WIDTH'],
  0x01000000e => [LONG,'RECORDING_ENTRY_IMAGES_HEIGHT'],
  0x01000000f => [LONG,'RECORDING_ENTRY_IMAGES_NUMBER_PLANES'],
  0x010000010 => [LONG,'RECORDING_ENTRY_IMAGES_NUMBER_STACKS'],
  0x010000011 => [LONG,'RECORDING_ENTRY_IMAGES_NUMBER_CHANNELS'],
  0x010000012 => [LONG,'RECORDING_ENTRY_LINSCAN_XY_SIZE'],
  0x010000013 => [LONG,'RECORDING_ENTRY_SCAN_DIRECTION'],
  0x010000014 => [LONG,'RECORDING_ENTRY_TIME_SERIES'],
  0x010000015 => [LONG,'RECORDING_ENTRY_ORIGINAL_SCAN_DATA'],
  0x010000016 => [RATIONAL,'RECORDING_ENTRY_ZOOM_X'],
  0x010000017 => [RATIONAL,'RECORDING_ENTRY_ZOOM_Y'],
  0x010000018 => [RATIONAL,'RECORDING_ENTRY_ZOOM_Z'],
  0x010000019 => [RATIONAL,'RECORDING_ENTRY_SAMPLE_0X'],
  0x01000001a => [RATIONAL,'RECORDING_ENTRY_SAMPLE_0Y'],
  0x01000001b => [RATIONAL,'RECORDING_ENTRY_SAMPLE_0Z'],
  0x01000001c => [RATIONAL,'RECORDING_ENTRY_SAMPLE_SPACING'],
  0x01000001d => [RATIONAL,'RECORDING_ENTRY_LINE_SPACING'],
  0x01000001e => [RATIONAL,'RECORDING_ENTRY_PLANE_SPACING'],
  0x01000001f => [RATIONAL,'RECORDING_ENTRY_PLANE_WIDTH'],
  0x010000020 => [RATIONAL,'RECORDING_ENTRY_PLANE_HEIGHT'],
  0x010000021 => [RATIONAL,'RECORDING_ENTRY_VOLUME_DEPTH'],
  0x010000034 => [RATIONAL,'RECORDING_ENTRY_ROTATION'],
  0x010000035 => [RATIONAL,'RECORDING_ENTRY_PRECESSION'],
  0x010000036 => [RATIONAL,'RECORDING_ENTRY_SAMPLE_0TIME'],
  0x010000037 => [ASCII,'RECORDING_ENTRY_START_SCAN_TRIGGER_IN'],
  0x010000038 => [ASCII,'RECORDING_ENTRY_START_SCAN_TRIGGER_OUT'],
  0x010000039 => [LONG,'RECORDING_ENTRY_START_SCAN_EVENT'],
  0x010000040 => [RATIONAL,'RECORDING_ENTRY_START_SCAN_TIME'],
  0x010000041 => [ASCII,'RECORDING_ENTRY_STOP_SCAN_TRIGGER_IN'],
  0x010000042 => [ASCII,'RECORDING_ENTRY_STOP_SCAN_TRIGGER_OUT'],
  0x010000043 => [LONG,'RECORDING_ENTRY_STOP_SCAN_EVENT'],
  0x010000044 => [RATIONAL,'RECORDING_ENTRY_STOP_SCAN_TIME'],
  0x010000045 => [LONG,'RECORDING_ENTRY_USE_ROIS'],
  0x010000046 => [LONG,'RECORDING_ENTRY_USE_REDUCED_MEMORY_ROIS'],
  0x010000047 => [ASCII,'RECORDING_ENTRY_USER'],
  0x010000048 => [LONG,'RECORDING_ENTRY_USEBCCORRECTION'],
  0x010000049 => [RATIONAL,'RECORDING_ENTRY_POSITIONBCCORRECTION1'],
  0x010000050 => [RATIONAL,'RECORDING_ENTRY_POSITIONBCCORRECTION2'],
  0x010000051 => [LONG,'RECORDING_ENTRY_INTERPOLATIONY'],
  0x010000052 => [LONG,'RECORDING_ENTRY_CAMERA_BINNING'],
  0x010000053 => [LONG,'RECORDING_ENTRY_CAMERA_SUPERSAMPLING'],
  0x010000054 => [LONG,'RECORDING_ENTRY_CAMERA_FRAME_WIDTH'],
  0x010000055 => [LONG,'RECORDING_ENTRY_CAMERA_FRAME_HEIGHT'],
  0x010000056 => [RATIONAL,'RECORDING_ENTRY_CAMERA_OFFSETX'],
  0x010000057 => [RATIONAL,'RECORDING_ENTRY_CAMERA_OFFSETY'],
  0x010000059 => [LONG,'RECORDING_ENTRY_RT_BINNING'],
  0x01000005a => [LONG,'RECORDING_ENTRY_RT_FRAME_WIDTH'],
  0x01000005b => [LONG,'RECORDING_ENTRY_RT_FRAME_HEIGHT'],
  0x01000005c => [LONG,'RECORDING_ENTRY_RT_REGION_WIDTH'],
  0x01000005d => [LONG,'RECORDING_ENTRY_RT_REGION_HEIGHT'],
  0x01000005e => [RATIONAL,'RECORDING_ENTRY_RT_OFFSETX'],
  0x01000005f => [RATIONAL,'RECORDING_ENTRY_RT_OFFSETY'],
  0x010000060 => [RATIONAL,'RECORDING_ENTRY_RT_ZOOM'],
  0x010000061 => [RATIONAL,'RECORDING_ENTRY_RT_LINEPERIOD'],
  0x010000062 => [LONG,'RECORDING_ENTRY_PRESCAN'],
  0x010000063 => [LONG,'RECORDING_ENTRY_SCAN_DIRECTIONZ'],
  0x010000064 => [LONG,'RECORDING_ENTRY_RT_SUPERSAMPLING'],
  # Track
  0x020000000 => [SUBBLOCK,'SUBBLOCK_TRACKS'],
  0x040000000 => [SUBBLOCK,'SUBBLOCK_TRACK'],
  0x040000001 => [LONG,'TRACK_ENTRY_MULTIPLEX_TYPE'],
  0x040000002 => [LONG,'TRACK_ENTRY_MULTIPLEX_ORDER'],
  0x040000003 => [LONG,'TRACK_ENTRY_SAMPLING_MODE'],
  0x040000004 => [LONG,'TRACK_ENTRY_SAMPLING_METHOD'],
  0x040000005 => [LONG,'TRACK_ENTRY_SAMPLING_NUMBER'],
  0x040000006 => [LONG,'TRACK_ENTRY_ACQUIRE'],
  0x040000007 => [RATIONAL,'TRACK_ENTRY_SAMPLE_OBSERVATION_TIME'],
  0x04000000b => [RATIONAL,'TRACK_ENTRY_TIME_BETWEEN_STACKS'],
  0x04000000c => [ASCII,'TRACK_ENTRY_NAME'],
  0x04000000d => [ASCII,'TRACK_ENTRY_COLLIMATOR1_NAME'],
  0x04000000e => [LONG,'TRACK_ENTRY_COLLIMATOR1_POSITION'],
  0x04000000f => [ASCII,'TRACK_ENTRY_COLLIMATOR2_NAME'],
  0x040000010 => [LONG,'TRACK_ENTRY_COLLIMATOR2_POSITION'],
  0x040000011 => [LONG,'TRACK_ENTRY_IS_BLEACH_TRACK'],
  0x040000012 => [LONG,'TRACK_ENTRY_IS_BLEACH_AFTER_SCAN_NUMBER'],
  0x040000013 => [LONG,'TRACK_ENTRY_BLEACH_SCAN_NUMBER'],
  0x040000014 => [ASCII,'TRACK_ENTRY_TRIGGER_IN'],
  0x040000015 => [ASCII,'TRACK_ENTRY_TRIGGER_OUT'],
  0x040000016 => [LONG,'TRACK_ENTRY_IS_RATIO_STACK'],
  0x040000017 => [LONG,'TRACK_ENTRY_BLEACH_COUNT'],
  0x040000018 => [RATIONAL,'TRACK_ENTRY_SPI_CENTER_WAVELENGTH'],
  0x040000019 => [RATIONAL,'TRACK_ENTRY_PIXEL_TIME'],
  0x040000020 => [ASCII,'TRACK_ENTRY_ID_CONDENSOR_FRONTLENS'],
  0x040000021 => [LONG,'TRACK_ENTRY_CONDENSOR_FRONTLENS'],
  0x040000022 => [ASCII,'TRACK_ENTRY_ID_FIELD_STOP'],
  0x040000023 => [RATIONAL,'TRACK_ENTRY_FIELD_STOP_VALUE'],
  0x040000024 => [ASCII,'TRACK_ENTRY_ID_CONDENSOR_APERTURE'],
  0x040000025 => [RATIONAL,'TRACK_ENTRY_CONDENSOR_APERTURE'],
  0x040000026 => [ASCII,'TRACK_ENTRY_ID_CONDENDOR_REVOLVER'],
  0x040000027 => [ASCII,'TRACK_ENTRY_CONDENSOR_FILTER'],
  0x040000028 => [RATIONAL,'TRACK_ENTRY_ID_TRANSMISSION_FILTER1'],
  0x040000029 => [ASCII,'TRACK_ENTRY_ID_TRANSMISSION1'],
  0x040000030 => [RATIONAL,'TRACK_ENTRY_ID_TRANSMISSION_FILTER2'],
  0x040000031 => [ASCII,'TRACK_ENTRY_ID_TRANSMISSION2'],
  0x040000032 => [LONG,'TRACK_ENTRY_REPEAT_BLEACH'],
  0x040000033 => [LONG,'TRACK_ENTRY_ENABLE_SPOT_BEACH_POS'],
  0x040000034 => [RATIONAL,'TRACK_ENTRY_SPOT_BLEACH_POSX'],
  0x040000035 => [RATIONAL,'TRACK_ENTRY_SPOT_BLEACH_POSY'],
  0x040000036 => [RATIONAL,'TRACK_ENTRY_BLEACH_POSITION_Z'],
  0x040000037 => [ASCII,'TRACK_ENTRY_ID_TUBELENS'],
  0x040000038 => [ASCII,'TRACK_ENTRY_ID_TUBELENS_POSITION'],
  0x040000039 => [RATIONAL,'TRACK_TRANSMITTED_LIGHT'],
  0x04000003a => [RATIONAL,'TRACK_REFLECTED_LIGHT'],
  0x04000003b => [LONG,'TRACK_SIMULTAN_GRAB_AND_BLEACH'],
  0x04000003c => [RATIONAL,'TRACK_BLEACH_PIXEL_TIME'],
  0x04000003d => [HEX,'TRACK_BLEACH_STOP_AT_DROP'],
  0x04000003f => [LONG,'TRACK_LASER_SUPRESSION_MODE'],  
  # Laser
  0x030000000 => [SUBBLOCK,'SUBBLOCK_LASERS'],
  0x050000000 => [SUBBLOCK,'SUBBLOCK_LASER'],
  0x050000001 => [ASCII,'OLEDB_LASER_ENTRY_NAME'],
  0x050000002 => [LONG,'OLEDB_LASER_ENTRY_ACQUIRE'],
  0x050000003 => [RATIONAL,'OLEDB_LASER_ENTRY_POWER'],
  # Detection channel
  0x060000000 => [SUBBLOCK,'SUBBLOCK_DETECTION_CHANNELS'],
  0x070000000 => [SUBBLOCK,'SUBBLOCK_DETECTION_CHANNEL'],
  0x070000003 => [RATIONAL,'DETCHANNEL_ENTRY_DETECTOR_GAIN'],
  0x070000005 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_GAIN'],
  0x070000007 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_OFFS'],
  0x070000009 => [RATIONAL,'DETCHANNEL_ENTRY_PINHOLE_DIAMETER'],
  0x07000000b => [LONG,'DETCHANNEL_ENTRY_ACQUIRE'],
  0x07000000c => [ASCII,'DETCHANNEL_POINT_DETECTOR_NAME'],
  0x07000000d => [ASCII,'DETCHANNEL_AMPLIFIER_NAME'],
  0x07000000e => [ASCII,'DETCHANNEL_PINHOLE_NAME'],
  0x07000000f => [ASCII,'DETCHANNEL_FILTER_SET_NAME'],
  0x070000010 => [ASCII,'DETCHANNEL_FILTER_NAME'],
  0x070000011 => [ASCII,'DETCHANNEL_FILTER_SET_1_NAME'],
  0x070000012 => [ASCII,'DETCHANNEL_FILTER_1_NAME'],
  0x070000013 => [ASCII,'DETCHANNEL_INTEGRATOR_NAME'],
  0x070000014 => [ASCII,'DETCHANNEL_DETECTION_CHANNEL_NAME'],
  0x070000015 => [RATIONAL,'DETCHANNEL_ENTRY_DETECTOR_GAIN_BC1'],
  0x070000016 => [RATIONAL,'DETCHANNEL_ENTRY_DETECTOR_GAIN_BC2'],
  0x070000017 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_GAIN_BC1'],
  0x070000018 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_GAIN_BC2'],
  0x070000019 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_OFFS_BC1'],
  0x070000020 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_OFFS_BC2'],
  0x070000021 => [LONG,'DETCHANNEL_ENTRY_SPECTRAL_SCAN_CHANNELS'],
  0x070000022 => [RATIONAL,'DETCHANNEL_ENTRY_SPI_WAVELENGTH_START'],
  0x070000023 => [RATIONAL,'DETCHANNEL_ENTRY_SPI_WAVELENGTH_END'],
  0x070000024 => [RATIONAL,'DETCHANNEL_SPI_WAVELENGTH_START2'],
  0x070000025 => [RATIONAL,'DETCHANNEL_SPI_WAVELENGTH_END2'],
  0x070000026 => [ASCII,'DETCHANNEL_ENTRY_DYE_NAME'],
  0x070000027 => [ASCII,'DETCHANNEL_ENTRY_DYE_FOLDER'],
  0x070000028 => [RATIONAL,'DETCHANNEL_DIGITAL_GAIN'],
  0x070000029 => [RATIONAL,'DETCHANNEL_DIGITAL_OFFS'],
  0x070000030 => [RATIONAL,'DETCHANNEL_LASER_SUPRESSION'],
  # Illumination channel
  0x080000000 => [SUBBLOCK,'SUBBLOCK_ILLUMINATION_CHANNELS'],
  0x090000000 => [SUBBLOCK,'SUBBLOCK_ILLUMINATION_CHANNEL'],
  0x090000001 => [ASCII,'ILLUMCHANNEL_ENTRY_NAME'],
  0x090000002 => [RATIONAL,'ILLUMCHANNEL_ENTRY_POWER'],
  0x090000003 => [RATIONAL,'ILLUMCHANNEL_ENTRY_WAVELENGTH'],
  0x090000004 => [LONG,'ILLUMCHANNEL_ENTRY_ACQUIRE'],
  0x090000005 => [ASCII,'ILLUMCHANNEL_ENTRY_DETCHANNEL_NAME'],
  0x090000006 => [RATIONAL,'ILLUMCHANNEL_ENTRY_POWER_BC1'],
  0x090000007 => [RATIONAL,'ILLUMCHANNEL_ENTRY_POWER_BC2'],
  # Beam splitter
  0x0a0000000 => [SUBBLOCK,'SUBBLOCK_BEAM_SPLITTERS'],
  0x0b0000000 => [SUBBLOCK,'SUBBLOCK_BEAM_SPLITTER'],
  0x0b0000001 => [ASCII,'BEAMSPLITTER_ENTRY_FILTER_SET'],
  0x0b0000002 => [ASCII,'BEAMSPLITTER_ENTRY_FILTER'],
  0x0b0000003 => [ASCII,'BEAMSPLITTER_ENTRY_NAME'],
  # Data channel
  0x0c0000000 => [SUBBLOCK,'SUBBLOCK_DATA_CHANNELS'],
  0x0d0000000 => [SUBBLOCK,'SUBBLOCK_DATA_CHANNEL'],
  0x0d0000001 => [ASCII,'DATACHANNEL_ENTRY_NAME'],
  0x0d0000003 => [LONG,'DATACHANNEL_MMF_INDEX'],
  0x0d0000004 => [LONG,'DATACHANNEL_ENTRY_COLOR'],
  0x0d0000005 => [LONG,'DATACHANNEL_ENTRY_SAMPLETYPE'],
  0x0d0000006 => [LONG,'DATACHANNEL_ENTRY_BITSPERSAMPLE'],
  0x0d0000007 => [LONG,'DATACHANNEL_ENTRY_RATIO_TYPE'],
  0x0d0000008 => [LONG,'DATACHANNEL_ENTRY_RATIO_TRACK1'],
  0x0d0000009 => [LONG,'DATACHANNEL_ENTRY_RATIO_TRACK2'],
  0x0d000000a => [ASCII,'DATACHANNEL_ENTRY_RATIO_CHANNEL1'],
  0x0d000000b => [ASCII,'DATACHANNEL_ENTRY_RATIO_CHANNEL2'],
  0x0d000000c => [RATIONAL,'DATACHANNEL_ENTRY_RATIO_CONST1'],
  0x0d000000d => [RATIONAL,'DATACHANNEL_ENTRY_RATIO_CONST2'],
  0x0d000000e => [RATIONAL,'DATACHANNEL_ENTRY_RATIO_CONST3'],
  0x0d000000f => [RATIONAL,'DATACHANNEL_ENTRY_RATIO_CONST4'],
  0x0d0000010 => [RATIONAL,'DATACHANNEL_ENTRY_RATIO_CONST5'],
  0x0d0000011 => [RATIONAL,'DATACHANNEL_ENTRY_RATIO_CONST6'],
  0x0d0000012 => [LONG,'DATACHANNEL_ENTRY_RATIO_FIRST_IMAGES1'],
  0x0d0000013 => [LONG,'DATACHANNEL_ENTRY_RATIO_FIRST_IMAGES2'],
  0x0d0000014 => [ASCII,'DATACHANNEL_ENTRY_DYE_NAME'],
  0x0d0000015 => [ASCII,'DATACHANNEL_ENTRY_DYE_FOLDER'],
  0x0d0000016 => [ASCII,'DATACHANNEL_ENTRY_SPECTRUM'],
  0x0d0000017 => [LONG,'DATACHANNEL_ENTRY_ACQUIRE'],
  # Timer
  0x011000000 => [SUBBLOCK,'SUBBLOCK_TIMERS'],
  0x012000000 => [SUBBLOCK,'SUBBLOCK_TIMER'],
  0x012000001 => [ASCII,'TIMER_ENTRY_NAME'],
  0x012000003 => [RATIONAL,'TIMER_ENTRY_INTERVAL'],
  0x012000004 => [ASCII,'TIMER_ENTRY_TRIGGER_IN'],
  0x012000005 => [ASCII,'TIMER_ENTRY_TRIGGER_OUT'],
  # Marker
  0x013000000 => [SUBBLOCK,'SUBBLOCK_MARKERS'],
  0x014000000 => [SUBBLOCK,'SUBBLOCK_MARKER'],
  0x014000001 => [ASCII,'MARKER_ENTRY_NAME'],
  0x014000002 => [ASCII,'MARKER_ENTRY_DESCRIPTION'],
  0x014000003 => [ASCII,'MARKER_ENTRY_TRIGGER_IN'],
  0x014000004 => [ASCII,'MARKER_ENTRY_TRIGGER_OUT'],
  # Subblock end
  0x0ffffffff => [SUBBLOCK,'END'],
  # Unknown
  0x090000009 => [HEX,'UNDEFINED'],
  # Obsolete
  0x010000023 => [RATIONAL,'RECORDING_ENTRY_NUTATION'],
  0x070000001 => [LONG,'DETCHANNEL_ENTRY_INTEGRATION_MODE'],
  0x070000002 => [LONG,'DETCHANNEL_ENTRY_SPECIAL_MODE'],
  0x070000004 => [RATIONAL,'DETCHANNEL_ENTRY_DETECTOR_GAIN_LAST'],
  0x070000006 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_GAIN_LAST'],
  0x070000008 => [RATIONAL,'DETCHANNEL_ENTRY_AMPLIFIER_OFFS_LAST'],
  0x07000000a => [RATIONAL,'DETCHANNEL_ENTRY_COUNTING_TRIGGER'],
  0x012000006 => [RATIONAL,'TIMER_ENTRY_ACTIVATION_TIME'],
  0x012000007 => [LONG,'TIMER_ENTRY_ACTIVATION_NUMBER'],
);

# CZ-Private tag AoH
# See pp 31-33, "Image File Format Description", Release 4.0
our @CZ_PRIVATE_TAG = (
  (map {{$_ => 4}} qw(MagicNumber StructureSize DimensionX DimensionY DimensionZ
                      DimensionChannels DimensionTime DataType ThumbnailX
                      ThumbnailY)),
  (map {{$_ => 8}} qw(VoxelSizeX VoxelSizeY VoxelSizeZ OriginX OriginY
                      OriginZ)),
  (map {{$_ => 2}} qw(ScanType SpectralScan)),
  (map {{$_ => 4}} qw(DataType OffsetVectorOverlay OffsetInputLut
                      OffsetOutputLut OffsetChannelColors)),
  (map {{$_ => 8}} qw(TimeInterval1)),
  (map {{$_ => 4}} qw(OffsetChannelDataTypes OffsetScanInformation OffsetKsData
                      OffsetTimeStamps OffsetEventList OffsetRoi OffsetBleachRoi
                      OffsetNextRecording)),
  (map {{$_ => 8}} qw(DisplayAspectX DisplayAspectY DisplayAspectZ
                      DisplayAspectTime)),
  (map {{$_ => 4}} qw(OffsetTopolsolineOverlay OffsetTopoProfileOverlay
                      OffsetLinescanOverlay ToolbarFlags OffsetChannelWavelength
                      OffsetChannelFactors)),
  (map {{$_ => 8}} qw(ObjectiveSphereCorrection)),
  (map {{$_ => 4}} qw(OffsetUmixParameters)),
  (map {{"Reserved$_" => 4}} (1..8)),
);

# Level 1 data is directly subordinate to an acquisition block, and an
# acquisition will have one or more of each type of level 1 data. While a
# recording is technically Level 1 data, it's a special case since there is
# only one.
my @LEVEL1 = qw(laser marker timer track);
# Level 2 data is subordinate to a track, and a track will have one or more of
# each type of level 2 data. Note that for bleach tracks, the level 2 blocks
# will be present, but may be empty.
our @LEVEL2 = qw(beam_splitter data_channel detection_channel
                illumination_channel);


# ****************************************************************************
# * Variables                                                                *
# ****************************************************************************
my $lsm_handle;


# ****************************************************************************
# * Constructor                                                              *
# ****************************************************************************

sub new
{
  my($class,$params) = @_;
  my $self = {};
  bless($self,$class);
  # Did we get a stack parameter? If so, parse it.
  if ($params && $params->{stack}) {
    $self->{stack} = $params->{stack};
    $self->parse();
  }
  return($self);
}


# ****************************************************************************
# * Callable routines                                                        *
# ****************************************************************************

sub parse
{
  my($self,$params) = @_;
  $self->{stack} = $params->{stack} if ($params && $params->{stack});
  $self->_compressionCheck();
  croak('No stack has been specified') unless ($self->{stack});
  # Set the LSM information
  my @zeiss = $self->_readZeissTag();
  my $offset = 0;
  my %hash;
  # Interpret every CZ-Private tag in order
  foreach (0..$#CZ_PRIVATE_TAG) {
    my($key,$val) = %{$CZ_PRIVATE_TAG[$_]};
    my $type = 'L';
    switch ($val) {
      case 2 { $type = 'S' }
      case 8 { $type = 'd' }
    }
    $hash{$key} = unpack($type,pack('C*',(@zeiss[$offset..$offset+$val])));
    $offset += $val;
  }
  # The CZ-Private tag goes into "cz_private" object
  $self->{cz_private} = new Zeiss::LSM::CZPrivate;
  $self->{cz_private}->{$_} = $hash{$_} foreach (keys %hash);
  # Parse the channel block
  $self->_parseChannelBlock($self->{cz_private}->{OffsetChannelColors});
  # Parse the acquisition block
  $self->_parseAcquisitionBlock($self->{cz_private}->{OffsetScanInformation});
  if ($self->{cz_private}->{OffsetKsData}) {
    # Parse the ApplicationTags/KS data block
    $self->_parseTagsBlock($self->{cz_private}->{OffsetKsData});
  }
  # We're done parsing!
  $lsm_handle->close;
}


# ****************************************************************************
# * Accessors                                                                *
# ****************************************************************************

# Auto-magically make accessors
__PACKAGE__->mk_ro_accessors(qw(ascii cz_private recording stack zeiss_tag));

foreach my $attr (map { $_.'s' } @LEVEL1,'channel') {
  # Level 1 acessors
  my $slot = __PACKAGE__ . '::get' . ucfirst($attr);
  no strict 'refs';
  *$slot = sub {
    my $self = shift;
    return() unless ($self->{$attr});
    @{$self->{$attr}};
  };
  $slot = __PACKAGE__ . '::num' . ucfirst($attr);
  no strict 'refs';
  *$slot = sub {
    my $self = shift;
    return(0) unless ($self->{$attr});
    return(scalar @{$self->{$attr}});
  };
}

# ****************************************************************************
# * Internal routines                                                        *
# ****************************************************************************

# ****************************************************************************
# * Subroutine:  _createLevel1Accessors                                      *
# * Description: This routine will create accessors for all LSM subclass     *
# *              attributes. It is called by the subclasses when the first   *
# *              object is instantiated.                                     *
# *                                                                          *
# * Parameters:  slot: subclass name (package)                               *
# *              key:  subclass key                                          *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub _createLevel1Accessors
{
  my($slot,$key) = @_;
  foreach (values %SUBBLOCK) {
    next unless ($_->[1] =~ /^$key/);
    $slot->mk_ro_accessors($_->[1]);
  }
}

# ****************************************************************************
# * Subroutine:  _compressionCheck                                           *
# * Description: Checks to see if the input file is compressed with bzip.    *
# *              If it is, then it uncompresses it to a temporary location   *
# *              and replaces the stack attribute with the name of the       *
# *              uncompressed file. It also sets a flag to delete the        *
# *              temporary file when the object goes out of scope.           *
# *                                                                          *
# * Parameters:  self: Zeiss::LSM object                                     *
# * Returns:     undef                                                       *
# ****************************************************************************
sub _compressionCheck {
  my $self = shift;
  $self->{_filename} = $self->{stack};
  # check that the file name ends with .bz2
  if ($self->{stack} =~ /\.bz2$/) {

    # has the temporary directory been set in and ENV variable?
    my $template = undef;
    if ($ENV{'ZEISS_UNPACK_TMP_DIR'}) {
      if (-d $ENV{'ZEISS_UNPACK_TMP_DIR'}) {
        $template = $ENV{'ZEISS_UNPACK_TMP_DIR'} . "/XXXXXXXX";
      }
      else {
        die "Value in ZEISS_UNPACK_TMP_DIR is not a directory: $ENV{'ZEISS_UNPACK_TMP_DIR'}\n"
      }
    }

    # set up a temporary file and make sure it gets deleted when out of scope.
    my ($fh, $filename) = tempfile($template, UNLINK => 1);
    # extract the contents
    my $status = bunzip2 $self->{stack} => $fh
      or die "Unable to uncompress the stack: $Bunzip2Error\n";
    # update the stack attribute
    $self->{_filename} = $filename;
  }
  return;
}

# ****************************************************************************
# * Subroutine:  _readZeissTag                                               *
# * Description: This routine will return an array of integers, with each    *
# *              integer representing a byte from the Zeiss tag (34412).     *
# *              Even though an array of bytes isn't the most compact and    *
# *              requires an extra step to process, I do it this way in case *
# *              we ever need to get other information from the file using   *
# *              Image::ExifTool. Note that we are currently reading in 8    *
# *              additional bytes in the "Reserved" area - these contain     *
# *              undocumented offsets to two ANSI blocks.                    *
# *                                                                          *
# * Parameters:  self: Zeiss::LSM object                                     *
# * Returns:     array of integers                                           *
# ****************************************************************************
sub _readZeissTag
{
my @zeiss;

  my $self = shift;
  my $file = $self->{_filename};
  $lsm_handle = new IO::File "< $file" or croak("Can't open $file ($!)");
  $lsm_handle->binmode;
  sysread($lsm_handle,my $buff,8);
  my($order,$ident,$offset) = unpack('v v L',$buff);
  croak("Invalid LSM file (order: $order, ID: $ident)")
    unless ($order == BYTE_ORDER && $ident == TIFF_IDENTIFIER);
  sysseek($lsm_handle,$offset,0);
  $offset = 0;
  sysread($lsm_handle,$buff,2);
  my $num_tags = unpack('v',$buff);
  while (!$offset) {
    last unless ($num_tags);
    # Process a single directory
    foreach (1..$num_tags) {
      sysread($lsm_handle,$buff,12);
      my $tag = unpack('v',$buff);
      if ($tag == TIF_CZ_LSMINFO) {
        $offset = unpack('x8 L',$buff);
        last;
      }
    }
    unless ($offset) {
      # We didn't find the Zeiss tag. Go to the next directory.
      sysread($lsm_handle,$buff,4);
      my $next = unpack('L',$buff);
      last unless ($next);
      sysseek($lsm_handle,$next,0);
      sysread($lsm_handle,$buff,2);
      $num_tags = unpack('v',$buff);
    }
  }
  if ($offset) {
    sysseek($lsm_handle,$offset,0);
    sysread($lsm_handle,$buff,8);
    my $size = unpack('x4 l',$buff);
    $self->{zeiss_tag} = unpack('H*',$buff);
    @zeiss = unpack('C*',$buff);
    sysread($lsm_handle,$buff,$size-8);
    push @zeiss,unpack('C*',$buff);
    $self->{zeiss_tag} .= unpack('H*',$buff);
  }
  else {
    croak('Could not find Zeiss tag');
  }
  @zeiss;
}


# ****************************************************************************
# * Subroutine:  _parseChannelBlock                                          *
# * Description: This routine will parse the channel block. The channel      *
# *              blocks consists of a brief header followed by two offset    *
# *              sections: one for names, and one for colors. The colors are *
# *              converted into an RGB string. Channel data is stored in     *
# *              Zeiss::LSM::Channel objects.                                *
# *                                                                          *
# * Parameters:  self:   Zeiss::LSM object                                   *
# *              offset: offset to channel block                             *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub _parseChannelBlock
{
  my $self = shift;
  my $offset = shift;
  sysseek($lsm_handle,$offset,0);
  sysread($lsm_handle,my $buff,20);
  my($size,undef,$names,$color_offset,$name_offset) = unpack('l*',$buff);
  my @arr;
  if ($names && $name_offset) {
    sysseek($lsm_handle,$offset+$name_offset,0);
    foreach (1..$names) {
      push @arr,{name => &_readString};
    }
  }
  if ($names && $color_offset) {
    sysseek($lsm_handle,$offset+$color_offset,0);
    foreach (1..$names) {
      sysread($lsm_handle,$buff,4);
      $arr[$_-1]->{color} = '#' . unpack('H6',$buff);
    }
  }
  return() unless (scalar @arr);
  # Create an array of Zeiss::LSM::Channel objects
  my @ao;
  push @ao,new Zeiss::LSM::Channel({name  => $_->{name},
                                   color => $_->{color}}) foreach (@arr);
  $self->{channels} =\@ao if (scalar @ao);
}


# ****************************************************************************
# * Subroutine:  _parseAcquisitionBlock                                      *
# * Description: This routine will parse the acquisition block.              *
# *                                                                          *
# * Parameters:  self:   Zeiss::LSM object                                   *
# *              offset: offset to acquisition block                         *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub _parseAcquisitionBlock
{
my @stack = ();
my ($a_key,$data,$store,$string);

  my $self = shift;
  my $offset = shift;
  sysseek($lsm_handle,$offset,0);
  my $in_process = 1;
  while ($in_process) {
    sysread($lsm_handle,my $buff,8);
    my($subblock,$type) = unpack('L*',$buff);
    my $key = sprintf "0x0%08x",$subblock;
    if (exists $SUBBLOCK{$subblock}) {
      my $subblock_name = $SUBBLOCK{$subblock}[1];
      # Debugging area ######################################
      #print STDERR "Read $key $type\n" if ($key =~ /04.*3d/);
      #######################################################
      croak("Type mismatch for $key: expected "
            . ($TYPE_MAP{$SUBBLOCK{$subblock}[0]}||'unknown') . " got "
            . $TYPE_MAP{$type})
        if ($type != $SUBBLOCK{$subblock}[0] && $SUBBLOCK{$subblock}[0] >= 0);
      my $spc = ' 'x(scalar(@stack)*2);
      $spc =~ s/^  // if (SUBBLOCK_END == $subblock);
      $string .= sprintf "%s%s ",$spc . $subblock_name,($type) ? ':' : '';
      ($data,$store) = ('',1);
      switch ($type) {
        case SUBBLOCK {
          $store = 0;
          &_readSubBlockEntry('Z*'); # There isn't any variable data
          my $block;
          if (SUBBLOCK_END == $subblock) {
            $string .= ($block = pop @stack);
            $in_process = 0 if ('SUBBLOCK_RECORDING' eq $block);
          }
          else {
            push @stack,($block = $subblock_name);
          }
          ($a_key = lc($block)) =~ s/subblock_//;
          if ('SUBBLOCK_RECORDING' eq $subblock_name) {
            $self->{recording} = new Zeiss::LSM::Recording;
          }
          elsif (grep(/^$a_key$/,@LEVEL1) && SUBBLOCK_END != $subblock) {
            push @{$self->{$a_key.'s'}},('Zeiss::LSM::' . ucfirst($a_key))->new;
          }
          elsif (grep(/^$a_key$/,@LEVEL2) && SUBBLOCK_END != $subblock) {
            # This subblock is part of a track
            (my $k = $a_key) =~ s/_//g;
            push @{$self->{tracks}[-1]{$a_key.'s'}},
                 ('Zeiss::LSM::Track::' . ucfirst($k))->new;
          }
        }
        case ASCII    { $data = &_readSubBlockEntry('Z*'); }
        case HEX      { $data = &_readSubBlockEntry('H*'); }
        case LONG     { $data = &_readSubBlockEntry('L'); }
        case RATIONAL { $data = &_readSubBlockEntry('d'); }
        else {
          croak("Unknown type $type");
        }
      }
      $string .= "$data\n";
      # Do we have a data attribute to store?
      if ($store && $subblock_name !~ /^unknown/) {
        if ('recording' eq $a_key) {
          $self->{recording}->{$subblock_name} = $data;
        }
        elsif (grep(/^$a_key$/,@LEVEL1)) {
          # Level 1 attribute
          $self->{$a_key.'s'}[-1]->{$subblock_name} = $data;
        }
        else {
          # Level 2 attribute
          $self->{tracks}[-1]{$a_key.'s'}[-1]{$subblock_name} = $data;
        }
      }
    }
    else {
      croak("Subblock $key is not defined");
    }
  }
  $self->{ascii} = $string;
}


# ****************************************************************************
# * Subroutine:  _parseTagsBlock                                             *
# * Description: This routine will parse the tags block.                     *
# *                                                                          *
# * Parameters:  self:   Zeiss::LSM object                                   *
# *              offset: offset to tags block                                *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub _parseTagsBlock
{
  my $self = shift;
  my $offset = shift;
  sysseek($lsm_handle,$offset,0);
  sysread($lsm_handle,my $buff,4); # Block size
  sysread($lsm_handle,$buff,4);
  $self->{tags}{NumEntries} = unpack('v',$buff);
  # print STDERR "Parsing Tag block - entries: " . $self->{tags}{NumEntries} . "\n";
  foreach my $entry (1..$self->{tags}{NumEntries}) {
    sysread($lsm_handle,$buff,4); # Entry size
    sysread($lsm_handle,$buff,4);
    sysread($lsm_handle,$buff,unpack('v',$buff));
    my $name = unpack('Z*',$buff);
    sysread($lsm_handle,$buff,4);
    my $data_type = unpack('v',$buff);
    sysread($lsm_handle,$buff,4);
    my $blen = unpack('v',$buff);
    # print STDERR "  $name: data type=$data_type, bytes=$blen\n";
    sysread($lsm_handle,$buff,unpack('v',$buff));
    switch ($data_type) {
      case 2 { $data_type = 'Z*' }
      case 4 { $data_type = 'L' }
      case 5 { $data_type = 'd' }
      else { $data_type = 'b*' }
    }
    $self->{tags}{$name} = unpack($data_type,$buff);
    # print STDERR "    $self->{tags}{$name}\n";
    if ($name eq 'AdapterInfo') {
      my @line = split(/\n+/,$self->{tags}{$name});
      my @adaptor;
      foreach (@line) {
        s/^\s+//;
        next unless (/(?:[0-9A-F]{2}-){4}[0-9A-F]{2}/);
        s/\s+$//;
        push @adaptor,$_;
      }
      if (scalar @adaptor) {
        $self->{tags}{mac_address} = (sort @adaptor)[0];
      }
    }
  }
}


# ****************************************************************************
# * Subroutine:  _readSubBlockEntry                                          *
# * Description: This routine will read and return the contents of a         *
# *              subblock entry. See section 2.8 "Acquisition Information"   *
# *              in "Image File Format Description", Release 4.0.            *
# *                                                                          *
# * Parameters:  (unspecified): pack type of value to expand data into       *
# * Returns:     the unpacked data that was read                             *
# ****************************************************************************
sub _readSubBlockEntry
{
  sysread($lsm_handle,my $buff,4);
  my $rs = unpack('L',$buff) || return;
  sysread($lsm_handle,$buff,$rs);
  unpack(shift,$buff);
}


# ****************************************************************************
# * Subroutine:  _readSubBlockString                                         *
# * Description: This routine will read and return the contents of a         *
# *              subblock string. No parameters are needed; the first four   *
# *              bytes read indicate the length of the string.               *
# *                                                                          *
# * Parameters:  NONE                                                        *
# * Returns:     the string that was read                                    *
# ****************************************************************************
sub _readString
{
  sysread($lsm_handle,my $buff,4);
  my $rs = unpack('L',$buff) || return;
  sysread($lsm_handle,$buff,$rs);
  unpack('Z*',$buff);
}

1;

__END__

=head1 NAME

Zeiss::LSM - class to capture information from Zeiss LSM files

=head1 SYNOPSIS

use Zeiss::LSM;

=head1 DESCRIPTION

This module provides a simple interface to Zeiss LSM file information.
The following information is parsed and accessible:

=over 2

CZ-Private tag information
Acquisition information with all defined subblocks

=back

The following data is currently not parsed:

=over 2

Vector overlay
ROIs
Time stamp information
Event lists
Lookup tables

=back

=head1 METHODS

=over 4

=item B<new>

Create a new instance of the Zeiss::LSM class.  Optionally accepts a
stack name. If a stack name is specified, the LSM stack is parsed.

=item B<parse>

Parse a given stack. The stack may be passed in, or previously specified
at instantiation.

=item B<ascii>

Return a formatted tect version of LSM data

=item B<cz_private>

Return LSM data present in the CZ-Private tag

=item B<stack>

Return the stack name

=item B<zeiss_tag>

Return the Zeiss (34412) tag as a hex string

=item B<recording>

Return a Zeiss::LSM::Recording object

=item B<getChannels>

Returns an array of Zeiss::LSM::Channel objects.

=item B<numChannels>

Returns the number of parsed Zeiss::LSM::Channel objects.

=item B<getLasers>

Returns an array of Zeiss::LSM::Laser objects.

=item B<numLasers>

Returns the number of parsed Zeiss::LSM::Laser objects.

=item B<getMarkers>

Returns an array of Zeiss::LSM::Marker objects.

=item B<numMarkers>

Returns the number of parsed Zeiss::LSM::Marker objects.

=item B<getTimers>

Returns an array of Zeiss::LSM::Timer objects.

=item B<numTimers>

Returns the number of parsed Zeiss::LSM::Timer objects.

=item B<getTracks>

Returns an array of Zeiss::LSM::Track objects.

=item B<numTracks>

Returns the number of parsed Zeiss::LSM::Track objects.

=back

=head1 BUGS

Does not handle files from the 710.

=head1 AUTHOR

 Rob Svirskas
 svirskasr@janelia.hhmi.org
