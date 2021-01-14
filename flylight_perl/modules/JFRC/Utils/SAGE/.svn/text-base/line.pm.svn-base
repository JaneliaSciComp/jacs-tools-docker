package JFRC::Utils::SAGE::line;

require Exporter;
our @ISA = qw(Exporter);
# This allows declaration       use Foo::Bar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ();
our @EXPORT_OK = ();
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
# * line                                                                     *
# ****************************************************************************

=head2 line

 Title:       line
 Usage:       &line($l,$row);
 Description: This routine will create parent/child relationships
 Parameters:  l:   Rose::DB Line object
              row: reference to the row hash
 Returns:     1 for success, 0 for failure

=cut
sub line
{
  my($l,$row) = @_;
  my $child = $l->name;
  my $child_id = $l->id;
  my @parent_ids;
  if ($child =~ /(.+)-x-(.+)/) {
    foreach my $parent ($1,$2) {
      my $sql = "SELECT id FROM line WHERE name='$parent'";
      my $parent_id = $main::dbh->selectrow_array($sql);
      push @parent_ids,$parent_id if ($parent_id);
    }
  }
  else {
    foreach my $parent (split(/\s+/,$row->{_flycore_parents})) {
      my $sql = "SELECT id FROM line_vw WHERE flycore_id='$parent'";
      my $parent_id = $main::dbh->selectrow_array($sql);
      push @parent_ids,$parent_id if ($parent_id);
    }
  }
  if (scalar @parent_ids) {
#+------------+---------+------------+------------------+-----------------+--------------+-----------+------------------+
#| context_id | context | subject_id | subject          | relationship_id | relationship | object_id | object           |
#+------------+---------+------------+------------------+-----------------+--------------+-----------+------------------+
#|          7 | schema  |      35648 | BJD_102A06_AV_01 |            4916 | parent_of    |    104113 | JRC_SS45406      |
#|          7 | schema  |      33085 | BJD_109B11_BB_21 |            4916 | parent_of    |    104113 | JRC_SS45406      |
#|          7 | schema  |      33940 | BJD_114B06_BB_21 |            4916 | parent_of    |    104113 | JRC_SS45406      |
#|          7 | schema  |     104113 | JRC_SS45406      |            4915 | child_of     |     33085 | BJD_109B11_BB_21 |
#|          7 | schema  |     104113 | JRC_SS45406      |            4915 | child_of     |     35648 | BJD_102A06_AV_01 |
#|          7 | schema  |     104113 | JRC_SS45406      |            4915 | child_of     |     33940 | BJD_114B06_BB_21 |
#+------------+---------+------------+------------------+-----------------+--------------+-----------+------------------+
    # Delete where subject_id=child_id and relationship_id=child_of
    # Delete where object_id=child_id and relationship_id=parent_of
     print $main::handle "  Delete relationships for $child\n";
    my $sql = "DELETE FROM line_relationship WHERE subject_id=$child_id AND type_id=getCVTermID('schema','child_of',NULL)";
    eval {$main::dbh->do($sql);};
    $sql = "DELETE FROM line_relationship WHERE object_id=$child_id AND type_id=getCVTermID('schema','parent_of',NULL)";
    eval {$main::dbh->do($sql);};
    print $main::handle "  Create relationships for $child to ",
                        join(", ",@parent_ids),"\n";
    foreach my $parent_id (@parent_ids) {
      $sql = "CALL createLineRelationship($child_id,$parent_id)";
      eval {$main::dbh->do($sql);};
    }
  }
  return(1);
}


1;
