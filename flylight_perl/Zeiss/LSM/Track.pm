# ****************************************************************************
# Resource name:  Zeiss::LSM::Track
# Written by:     Rob Svirskas
# Revision level: (same as Zeiss::LSM)
# Date released:  (same as Zeiss::LSM)
# Description:    This module uses POD documentation.
# Required resources:
#   Programs:       NONE
#   USEd modules:   strict
#                   warnings
#                   Class::Accessor::Fast
#                   Zeiss::LSM::Track::Beamsplitter
#                   Zeiss::LSM::Track::Datachannel
#                   Zeiss::LSM::Track::Detectionchannel
#                   Zeiss::LSM::Track::Illuminationchannel
# ****************************************************************************
package Zeiss::LSM::Track;

use strict;
use warnings;
use base 'Class::Accessor::Fast';

use Zeiss::LSM::Track::Beamsplitter;
use Zeiss::LSM::Track::Datachannel;
use Zeiss::LSM::Track::Detectionchannel;
use Zeiss::LSM::Track::Illuminationchannel;

# ****************************************************************************
# * Variables                                                                *
# ****************************************************************************
my $accessors_created = 0;

# ****************************************************************************
# * Constructor                                                              *
# ****************************************************************************

sub new
{
  my $class = shift;
  my $self = {};
  bless($self,$class);
  unless ($accessors_created++) {
    &_createTrackAccessors;
    &Zeiss::LSM::_createLevel1Accessors(__PACKAGE__,'TRACK')
  }
  return($self);
}


# ****************************************************************************
# * Internal routines                                                        *
# ****************************************************************************

# ****************************************************************************
# * Subroutine:  _createTrackAccessors                                       *
# * Description: This routine will create accessors for all Track            *
# *              subclasses.                                                 *
# *                                                                          *
# * Parameters:  NONE                                                        *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub _createTrackAccessors
{
  foreach my $attr (map { $_.'s' } @{Zeiss::LSM::LEVEL2}) {
    (my $func = $attr) =~ s/_//;
    my $slot = __PACKAGE__ . '::get' . ucfirst($func);
    no strict 'refs';
    *$slot = sub {
      my $self = shift;
      return() unless ($self->{$attr});
      @{$self->{$attr}};
    };
    $slot = __PACKAGE__ . '::num' . ucfirst($func);
    no strict 'refs';
    *$slot = sub {
      my $self = shift;
      return(0) unless ($self->{$attr});
      return(scalar @{$self->{$attr}});
    };
  }
}


# ****************************************************************************
# * Subroutine:  _createLevel2Accessors                                      *
# * Description: This routine will create accessors for all Track subclass   *
# *              attributes. It is called by the subclasses when the first   *
# *              object is instantiated.                                     *
# *                                                                          *
# * Parameters:  slot: subclass name (package)                               *
# *              key:  subclass key                                          *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub _createLevel2Accessors
{
  my($slot,$key) = @_;
  foreach (values %Zeiss::LSM::SUBBLOCK) {
    next unless ($_->[1] =~ /^$key/);
    $slot->mk_ro_accessors($_->[1]);
  }
}

1;

__END__

=head1 NAME

Zeiss::LSM::Track - encapsulate Zeiss LSM track information

=head1 SYNOPSIS

  use Zeiss::LSM;
  my $lsm = Zeiss::LSM->new({stack => 'stack.lsm'});
  my $num = 0;
  foreach my $t ($lsm->getTracks) {
    print "Track $num: ",$t->{TRACK_ENTRY_NAME},"\n";
    foreach my $list ('Beam Splitter','Data Channel','Detection Channel',
                      'Illum Channel') {
      no strict 'refs';
      (my $func = $list) =~ s/ +//g;
      my $s = uc($func) . '_ENTRY_NAME';
      $func = 'get' . ucfirst(lc($func)) . 's';
      $func =~ s/Illum/Illumination/;
      print "  $list ",$_->{$s}||$_->{DETCHANNEL_DETECTION_CHANNEL_NAME},"\n"
        foreach ($t->$func($_));
    }
    $num++;
  }

=head1 DESCRIPTION

This module provides a convenient read-only interface to Zeiss
LSM track information.

=head1 METHODS

=over 4

=item B<new>

Creates a new Zeiss::LSM::Track object and its accessors.

=back

=head1 BUGS

None known

=head1 AUTHOR

 Rob Svirskas
 svirskasr@janelia.hhmi.org

=head1 SEE ALSO

L<Zeiss::LSM>
