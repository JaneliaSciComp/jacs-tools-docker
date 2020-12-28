#!/usr/bin/perl

use Zeiss::LSM;
use Data::Dumper;

my $file = $ARGV[0]
  || &terminateProgram('You must enter a filename');

my $outputFile = $ARGV[1] || &terminateProgram('You must enter an output filepath');

my $lsm;
eval { $lsm = new Zeiss::LSM({stack => $file}); };

open(OUTPUT, ">$outputFile") || &terminateProgram("Could not open file $outputFile to write");

print OUTPUT Dumper($lsm);

&terminateProgram($@) if ($@);

my $x = $lsm->cz_private->VoxelSizeX*1e6;
my $y = $lsm->cz_private->VoxelSizeY*1e6;
my $z = $lsm->cz_private->VoxelSizeZ*1e6;

print OUTPUT "$x $y $z\n";

close OUTPUT;

exit;

# ****************************************************************************
# * Subroutine:  terminateProgram                                            *
# * Description: This routine will gracefully terminate the program. If a    *
# *              message is passed in, we exit with a code of -1. Otherwise, *
# *              we exit with a code of 0.                                   *
# *                                                                          *
# * Parameters:  message: the error message to print                         *
# * Returns:     NONE                                                        *
# ****************************************************************************
sub terminateProgram
{
  my $message = shift;
  print STDERR  "$message\n" if ($message);
  exit(($message) ? -1 : 0);
}
