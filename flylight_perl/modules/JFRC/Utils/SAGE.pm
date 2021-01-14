# ****************************************************************************
# Resource name:  JFRC::Utils::SAGE
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

JFRC::Utils::SAGE : SAGE utility functions

=head1 SYNOPSIS

use JFRC::Utils::SAGE

=head1 DESCRIPTION

There are currently six routines that can be exported:

=over

buildStandardQueryBox: build a standard query box

calculateFlipDate: calculate the flip date

executeQuery: create and exeute a results query

getCVTerm : given a CV/CV term, return a specified field

getCVTermDefinition: given a CV/CV term, return the definition

getCVTermDisplay: given a CV/CV term, return the display name

getCVTermID : given a CV/CV term, return the ID

getCVTermType : given a CV/CV term, return the data type

insertOperation : insert an operation record into the data_processing table

=back

=head1 FUNCTIONS

=cut

# ****************************************************************************
# * POD documentation header end                                             *
# ****************************************************************************

package JFRC::Utils::SAGE;

use strict;
use warnings;
use Carp;
use CGI qw/:standard/;
use Date::Calc qw(Add_Delta_Days);
use Switch;
use Sys::Hostname;

require Exporter;
our @ISA = qw(Exporter);
# This allows declaration       use Foo::Bar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (all => [qw(buildStandardQueryBox calculateFlipDate
                               executeQuery getCVTerm getCVTermDefinition
                               getCVTermDisplay getCVTermID getCVTermType
                               insertOperation)]);
our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});
our @EXPORT = ();


# ****************************************************************************
# * Constants                                                                *
# ****************************************************************************
our $VERSION = '0.2';
use constant ANY    => '(any)';
use constant IGNORE => 'ignore';
use constant NBSP   => '&nbsp;';

# ****************************************************************************
# * Globals                                                                  *
# ****************************************************************************
my %cvterm;

# ****************************************************************************
# * Callable routines                                                        *
# ****************************************************************************

# ****************************************************************************
# * buildStandardQueryBox                                                    *
# ****************************************************************************

=head2 buildStandardQueryBox

 Title:       buildStandardQueryBox
 Usage:       &buildStandardQueryBox(TERM  => \%TERM,
                                     ORDER => \@TERM_ORDER);
 Description: This routine will return an input query box. Layout/display
              information is built based on the "term" section of the
              XML configuration. Fields that display choices are
              populated from the SAGE database through custom
              (XML-specified) SQL statements.
 Parameters:  Named parameters
              ORDER:  (required) arrayref with order of terms
              TERM:   (required) XML "term" section
              NOICON: (optional) do not display "help" icon
              DBH:    (optional) database handle
 Returns:     NONE

=cut

sub buildStandardQueryBox
{
  my %args = (ORDER  => '',
              TERM   => '',
              GROUP  => '',
              NOICON => 0,
              DBH    => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(ORDER TERM));
  my($dbh,$term,$group) = @args{qw(DBH TERM GROUP)};
  my (@header,@row);
  foreach my $item (@{$args{ORDER}}) {
    next if ($term->{$item}{group} && $group
             && ($term->{$item}{group} ne $group));
    my ($ar,$plural);
    if ($term->{$item}{uitype} eq 'like'
        || $term->{$item}{uitype} eq 'autocomplete'
        || $term->{$item}{uitype} eq 'calendar') {
      push @header,($args{NOICON})
        ? a({href  => '#',
             class => 'tooltip'},$term->{$item}{display} . NBSP
            . span($term->{$item}{text}))
        : $term->{$item}{display} . NBSP
          . a({href  => '#',
               class => 'tooltip'},'?' . span($term->{$item}{text}));
    }
    else {
      my $sth = $dbh->prepare($term->{$item}{sql});
      $sth->execute();
      $ar = $sth->fetchall_arrayref;
      ($plural = $term->{$item}{display}) =~ s/y$/ie/;
      $plural =~ s/s$//;
      push @header,($args{NOICON})
        ? a({href  => '#',
             class => 'tooltip'},$term->{$item}{display} . NBSP
            . span($term->{$item}{text}))
        : span({title => scalar @$ar},$term->{$item}{display}) . NBSP
          . a({href  => '#',
               class => 'tooltip'},'?' . span($term->{$item}{text}));
    }
    switch ($term->{$item}{uitype}) {
      case 'pulldown' {
        push @row,&createPulldownQuery($item,$ar,$plural);
      } #pulldown
      case 'calendar' {
        push @row,&createCalendarQuery($item);
      } #calendar
      case 'scrolled' {
        push @row,&createScrolledQuery($item,$ar,$plural);
      } #scrolled
      case 'stacked' {
        push @row,&createStackedQuery($item,$ar,$plural,$term->{$item}{display});
      } #stacked
      case 'like' {
        push @row,div({align => 'left'},
               input({&identify($item)}));
      } #like
      case 'autocomplete' {
        push @row,div({align => 'left'},
                      input({&identify($item)})
                            . img({src   => '/images/loading.gif',
                                   style => 'display: none;',
                                   id    => $item . '_loading'})
                      . div({class => 'autocomplete',
                             map {$_ => $item . '_autocomplete'}
                                 qw(id name)},'')
                         . div({&identify($item . 'select')},''));
      } # autocomplete
      case 'radio' {
        push @row,&createRadioQuery($item,$ar);
      } #radio
    } #case
  }
  # Return query box
  div({id=>'querybox'},
      map {div({id=>'queryitem'},$_,br,shift @row)} @header);
}


# ****************************************************************************
# * calculateFlipDate                                                        *
# ****************************************************************************

=head2 calculateFlipDate

 Title:       calculateFlipDate
 Usage:       &calculateFlipDate('20100410T093000');
 Description: This routine will calculate the flip dat given a cross date.
 Parameters:  cd: cross date
              flip: flip used
 Returns:     flip date (or false for failure)

=cut

sub calculateFlipDate
{
my @MAP = qw(0 4 7 11);

  my($cd,$flip) = @_;
  return() unless ($cd =~ /^\d{8}T\d{6}$/);
  return($cd) if (!$flip || ($flip < 1) || ($flip > 3));
  my @new = Add_Delta_Days(substr($cd,0,4),substr($cd,4,2),substr($cd,6,2),
                           $MAP[$flip]);
  return() unless (3 == scalar(@new));
  return(sprintf '%4d%02d%02d%s',@new,substr($cd,8));
}


# ****************************************************************************
# * executeQuery                                                             *
# ****************************************************************************

=head2 executeQuery

 Title:       executeQuery
 Usage:       &executeQuery(CONDITION => \my %condition,
                            TERM      => \%TERM,
                            LIST      => \my @list);
 Description: This routine will build and execute the primary query.
              Two lists are populated: LIST is an AoA containing the
              query results, and SQL_LIST is an array containing select
              conditions in plain language.
 Parameters:  Named parameters
              CONDITION: (required) hashref of columns/parms
              SEARCH:    (required) search type (general, region, or both)
              TERM:      (required) XML "term" section
              DBH:       (optional) database handle
 Returns:     NONE

=cut

sub executeQuery
{
  my %args = (CONDITION => '',
              LOGIC => 'AND',
              SEARCH => 'both',
              TERM => '',
              TYPE => 'slew',
              DBH   => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(CONDITION LOGIC SEARCH TERM));
  my $chr = $args{CONDITION};
  my $logic = uc($args{LOGIC});
  my $primary_logic = $logic;
  my $search = $args{SEARCH};
  my $term = $args{TERM};
  my $type = $args{TYPE};
  my $dbh = $args{DBH};
  my ($sql,$view);
  if ('proboscis' eq $type) {
    $view = 'simpson_pe_vw';
    $sql = 'SELECT line,gene,synonyms';
  }
  elsif ('olympiad_aggression' eq $type) {
    $view = $type . '_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,experiment,effector,genotype,automated_pf,manual_pf,screen_reason';
  }
  elsif ('olympiad_bowl' eq $type) {
    $view = $type . '_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,experiment,effector,genotype,automated_pf,manual_pf,screen_reason,screen_type';
  }
  elsif ('olympiad_box' eq $type) {
    $view = 'olympiad_box_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,box,experiment,effector,genotype,protocol,gender,automated_pf,manual_pf,screen_reason';
  }
  elsif ('olympiad_gap' eq $type) {
    $view = $type . '_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,experiment,effector,genotype,gender,automated_pf,manual_pf,screen_reason';
  }
  elsif ('olympiad_observation' eq $type) {
    $view = $type . '_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,experiment,effector,genotype,no_phenotypes,automated_pf,manual_pf,screen_reason';
  }
  elsif ('olympiad_climbing' eq $type) {
    $view = $type . '_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,experiment,effector,genotype,gender,automated_pf,manual_pf,screen_reason';
  }
  elsif ('olympiad_sterility' eq $type) {
    $view = $type . '_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,experiment,effector,genotype,gender,sterile,automated_pf,manual_pf,screen_reason';
  }
  elsif ('olympiad_trikinetics' eq $type) {
    $view = 'olympiad_trikinetics_vw';
    $sql = 'SELECT DISTINCT line,gene,synonyms,experiment,effector,automated_pf,manual_pf';
  }
  elsif ('summary' eq $type) {
    $view = 'line_summary_vw';
    $sql = 'SELECT line,gene,synonyms,lab,genotype,experiments';
  }
  elsif ($type =~ /^flew/) {
    if ('flew_embryo' eq $type) {
      $view = 'rubin_doe_gal4_vw';
      $sql = "SELECT line,gene,synonyms,stage,expressed_regions,url";
      $logic = 'OR';
    }
    elsif ('flew_imaginal' eq $type) {
      $view = 'rubin_mann_gal4_vw';
      $sql = 'SELECT line,gene,synonyms,gfp_pattern,disc_type_list';
    }
    elsif ('flew_larval' eq $type) {
      $view = 'truman_gal4_vw';
      $sql = "SELECT line,gene,synonyms,gene,expressed_regions,ref_pattern,translation,rock";
      $logic = 'OR';
    }
    else {
      $view = 'rubin_gal4_vw';
      $sql = 'SELECT line,gene,synonyms,organ,expressed_regions,ref_pattern,pattern,registered,translation';
    }
  }
  elsif ($type =~ /^slarv/) {
    $view = 'single_neuron_summary_vw';
    $sql = 'SELECT neuron_name,neuron_type,axon_projection,commissure,longitudinal_tract,dendritic_arbor';
  }
  else {
    $view = 'simpson_gal4_vw';
    $sql = 'SELECT line,gene,synonyms,MIN(cytology),expressed_regions,'
           . 'brain,thorax';
  }
  # ---------- Set conditions ----------
  my $cond = '';
  my @ef;
  my($term_start) = ($type =~ /^flew/) ? 9 : 7;
  $term_start = 6 if ('flew_embryo' eq $type);
  $term_start = 8 if ('flew_larval' eq $type);
  # Region searches: always use OR, then filter programatically
  my (%dterm,%iterm);
  if (($search eq 'region') || ($search eq 'both')) {
    my $pos = $term_start;
    if ($type =~ /^flew/) {
      # FLEW/IMBUE searches
      foreach (param) {
        next unless (/^region(intensity|distribution)_/);
        my $rtype = $1;
        (my $t = $_) =~ s/^region(?:intensity|distribution)_//;
        my($val) = $t =~ /_(\d)$/;
        $t =~ s/_(\d)$//;
        $t =~ s/_/ /g;
        if ($rtype eq 'intensity') {
          push @{$iterm{$t}},$val;
        }
        else {
          push @{$dterm{$t}},$val;
        }
      }
      # Intensity and distibution
      foreach my $t (sort keys %iterm) {
        $cond .= "(term='$t' AND intensity IN (";
        $cond .= join(',',@{$iterm{$t}}) . ")";
        if (exists $dterm{$t}) {
          $cond .= " AND distribution IN (";
          $cond .= join(',',@{$dterm{$t}}) . ")";
          push @{$chr->{'Anatomical term distribution'}},(sprintf '%s (%s)',$t,
               join(',',@{$dterm{$t}}));
        }
        $cond .= ') OR ';
        push @{$chr->{'Anatomical term intensity'}},(sprintf '%s (%s)',$t,
             join(',',@{$iterm{$t}}));
      }
      $cond =~ s/ OR $//;
    }
    else {
      # Region selects (Y/N)
      foreach (param) {
        next unless (/^region_/);
        (my $t = $_) =~ s/^region_//;
        $t =~ s/_/ /g;
        $sql .= ",MAX(IF(STRCMP(term,'$t'),null,expressed)) AS '$_" . "_exp'";
        # "IN" is cleaner..
        $cond = ' term IN (' unless ($cond);
        $cond .= "'$t',";
        push @{$chr->{'Anatomical terms'}},(sprintf '%s (%s)',$t,param($_));
        $ef[$pos++] = param($_);
      }
      $cond =~ s/,$/)/ if ($cond);
    }
  }
  if (($search eq 'general') || ($search eq 'both')) {
    if ($type =~ /^flew/) {
      # Delete unwanted parms
      if (param('_gsearch') || param('_gsearch.x')) {
        delete @{$term}{'lline','mline','dline'};
        Delete('disc','term','gfp_pattern','lterm');
      }
      if (param('_dsearch') || param('_dsearch.x')) {
        delete @{$term}{'line','lline','dline'};
        Delete('gene','term','lterm');
      }
      if (param('_esearch') || param('_esearch.x')) {
        delete @{$term}{'line','lline','mline'};
        Delete('gene','disc','gfp_pattern','lterm');
      }
      if (param('_lsearch') || param('_lsearch.x')) {
        delete @{$term}{'line','dline','mline'};
        Delete('gene','term','disc','gfp_pattern');
      }
    }
    foreach my $t (keys %$term) {
      my $field = [param($t)];
      if ($type =~ /^flew/) {
        $t = 'line' if ($t =~ /^[a-z]line$/);
      }
      my @val;
      (length($_)) && push @val,$_ foreach (@$field);
      foreach (@val) {
        next unless (exists $term->{$t}{validate});
        croak "Invalid entry for $t ($_)" unless (/$term->{$t}{validate}/);
      }
      if (($type =~ /flew_(?:larval)?/) && ($t eq 'line')) {
        my @add;
        push @add,$_.'L' foreach (@val);
        push @val,@add;
      }
      $term->{$t}{querytype} ||= '';
      $term->{$t}{uitype} ||= '';
      if ($term->{$t}{querytype} eq 'like') {
        foreach my $lt (@val) {
          $lt = lc($lt);
          next unless (length($lt));
          push @{$chr->{$t}},$lt;
          $lt = '%' . $lt . '%';
          $cond .= " $logic LOWER($t) LIKE " . $dbh->quote($lt);
        }
      }
      elsif ($term->{$t}{uitype} eq 'calendar'
             && (param('start_date') || param('end_date'))) {
        my $s = param('start_date');
        my $e = param('end_date');
        if ($s && $e) {
          ($s,$e) = ($e,$s) if ($s > $e);
          $cond .= " $logic ($t BETWEEN $s AND $e)";
        }
        elsif ($s) {
          $cond .= " $logic $t >= $s";
        }
        else {
          $cond .= " $logic $t <= $e";
        }
      }
      else {
        unless (scalar @val) {
          push @{$chr->{$t}},'ANY';
          next;
        }
        if ('gene' eq $t) {
          my %v;
          foreach my $g (@val) {
            $v{$g}++ if ($g =~ /^CG\d+$/);
            my $cph = $dbh->prepare("CALL getGene('$g')");
            $cph->execute();
            my $r = $cph->fetchrow_array();
            $v{$r}++ if ($r);
          }
          @val = keys %v;
        }
        push @{$chr->{$t}},@val;
        $t = 'term' if (($type eq 'flew_larval') && ($t eq 'lterm'));
        $cond .= " $logic $t "
                 . ((scalar @val > 1) ? "IN ('" . join("','",@val) . "')"
                                     : "= '" . $val[0] . "'");
      }
    }
  }
  if ($type eq 'summary') {
    $cond .= " OR line IN (SELECT line FROM publishing_name_vw WHERE publishing_name='"
             . param('line') . "')";
  }
  # -------- Two-phase select --------
  if ($type =~ /^slarv/) {
    $cond = ' neuron_name IN (SELECT neuron_name FROM single_neuron_vw WHERE '
            . $cond . ')';
  }
  # ---------- WHERE clause ----------
  $sql .= " FROM $view WHERE $cond";
  $sql =~ s/WHERE\s+$//;
  $sql .= " AND session_type='raw_data_individual'"
    if ('olympiad_aggression' eq $type);
  $sql .= ' GROUP BY 1,2,3' unless ('summary' eq $type || $type =~ /^olympiad/);
  if ('slew' eq $type) {
    $sql .= ',5,6,7';
  }
  elsif ($type =~ /^flew/) {
    $sql .= ',4';
  }
  $sql =~ s/WHERE\s+(?:AND|OR)/WHERE /;
  if ($type eq 'flew_') {
    if ($cond) {
      $sql =~ s/WHERE /WHERE organ IS NOT NULL AND (/;
      $sql =~ s/ GROUP BY/) GROUP BY/;
    }
    else {
      $sql =~ s/WHERE /WHERE organ IS NOT NULL /;
    }
  }
  $sql .= ' ORDER BY 1';
  $sql .= ',4' if ($type =~ /^flew/);
  push @{$chr->{QUERY}},$sql;
  print STDERR $sql;
  my $ar = $dbh->selectall_arrayref($sql);

  # For selects with anatomical terms, we have to do the
  # filtering programatically...
  $logic = $primary_logic;
  if ((($search eq 'region') || ($search eq 'both'))
      && ($type !~ /^flew/)
     ) {
    my @arr;
    my $target = ($logic eq 'OR') ? 1 : scalar(@ef)-$term_start;
    foreach my $r (@$ar) {
      my $match = 0;
      foreach ($term_start..$#ef) {
        $r->[$_] ||= 0; # Anatomical values may be undef
        $match++ if ($r->[$_] eq $ef[$_]);
      }
      push @arr,[@$r] if ($match >= $target);
    }
    $ar = \@arr;
  }
  elsif (($type eq 'flew_imaginal') && ($logic eq 'AND')
         && param('gfp_pattern')) {
    my @field = param('gfp_pattern');
    my @arr;
    # Build expression hash
    my %hash = ();
    foreach my $r (@$ar) {
      next unless ($r->[3]);
      $hash{$r->[0]}++;
    }
    foreach my $r (@$ar) {
      if ($hash{$r->[0]} == scalar(@field)) {
        push @arr,[@$r];
        $hash{$r->[0]} = 0;
      }
    }
    $ar = \@arr;
  }
  elsif (($type =~ /flew_(embryo|larval)/) && ($logic eq 'AND')) {
    my @field = param('term');
    @field = param('lterm') if ($type eq 'flew_larval');
    my @arr;
    # Build expression hash
    my %hash = ();
    foreach my $r (@$ar) {
      next unless ($r->[4]);
      if (exists $hash{$r->[0]}) {
        $hash{$r->[0]} = join(', ',$hash{$r->[0]},$r->[4]);
      }
      else {
        $hash{$r->[0]} = $r->[4];
      }
    }
    foreach my $r (@$ar) {
      my $tm = 0;
      foreach my $t (@field) {
        $tm++ if ($hash{$r->[0]} =~ /$t/);
      }
      if ($tm == scalar(@field)) {
        $r->[4] =~ s/(Stage 16|GBE) //g;
        push @arr,[@$r];
      }
    }
    $ar = \@arr;
  }
  elsif (($search eq 'region') && ($type eq 'flew_') && ($logic eq 'AND')) {
    my @arr;
    my $target = scalar(keys %dterm) + scalar(keys %iterm);
    my %use_line;
    foreach my $r (@$ar) {
      if ($r->[3] ne 'Brain') {
        push @arr,[@$r] if ($use_line{$r->[0]});
        next;
      }
      my $tm = 0;
      print STDERR "Term processing for $r->[0]\n";
      foreach my $t (keys %iterm) {
        foreach my $v (@{$iterm{$t}}) {
          $tm++ if (index((', '.$r->[4]),", $t ($v") >= 0);
        }
        if (exists $dterm{$t}) {
          foreach my $v (@{$dterm{$t}}) {
            $tm++ if ((', '.$r->[4]) =~ /, $t \(\d,$v\)/);
          }
        }
      }
      if ($tm >= $target) {
        push @arr,[@$r];
        $use_line{$r->[0]}++;
      }
    }
    $ar = \@arr;
  }
  # Post-processing to remove duplicates for FLEW imaginal discs
  if ($type eq 'flew_imaginal') {
    my @arr = @$ar;
    @$ar = ();
    my %hash;
    foreach (@arr) {
      next if ($hash{$_->[0]});
      splice @$_,3,1;
      $hash{$_->[0]}++;
      push @$ar,[@$_];
    }
  }
  # We're done! Return the array reference
  return($ar);
}


# ****************************************************************************
# * getCVTermDefinition                                                      *
# ****************************************************************************

=head2 getCVTermDefinition

 Title:       getCVTermDefinition
 Usage:       &getCVTermDefinition(CV => 'ipcr', TERM => 'cytology');
 Description: This routine will return the definition for a given CV
              term.
 Parameters:  Named parameters
              CV:   (required) CV
              TERM: (required) CV term
              DBH:  (optional) database handle
 Returns:     CV term definition

=cut

sub getCVTermDefinition
{
  my %args = (CV   => '',
              TERM => '',
              DBH  => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(CV TERM DBH));
  return(&getCVTerm(@args{qw(DBH CV TERM)},'definition'));
}


# ****************************************************************************
# * getCVTermDisplay                                                         *
# ****************************************************************************

=head2 getCVTermDisplay

 Title:       getCVTermDisplay
 Usage:       &getCVTermDisplay(CV => 'ipcr', TERM => 'cytology');
 Description: This routine will return the display name for a given CV
              term.
 Parameters:  Named parameters
              CV:   (required) CV
              TERM: (required) CV term
              DBH:  (optional) database handle
 Returns:     CV term display name

=cut

sub getCVTermDisplay
{
  my %args = (CV   => '',
              TERM => '',
              DBH  => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(CV TERM DBH));
  return(&getCVTerm(@args{qw(DBH CV TERM)},'display'));
}


# ****************************************************************************
# * getCVTermID                                                              *
# ****************************************************************************

=head2 getCVTermID

 Title:       getCVTermID
 Usage:       &getCVTermID(CV => 'ipcr', TERM => 'cytology');
 Description: This routine will return the ID for a given CV
              term.
 Parameters:  Named parameters
              CV:   (required) CV
              TERM: (required) CV term
              DBH:  (optional) database handle
 Returns:     CV term ID

=cut

sub getCVTermID
{
  my %args = (CV   => '',
              TERM => '',
              DBH  => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(CV TERM DBH));
  return(&getCVTerm(@args{qw(DBH CV TERM)},'id'));
}


# ****************************************************************************
# * getCVTermType                                                            *
# ****************************************************************************

=head2 getCVTermType

 Title:       getCVTermType
 Usage:       &getCVTermType(CV => 'ipcr', TERM => 'cytology');
 Description: This routine will return the data type for a given CV
              term.
 Parameters:  Named parameters
              CV:   (required) CV
              TERM: (required) CV term
              DBH:  (optional) database handle
 Returns:     CV term display name

=cut

sub getCVTermType
{
  my %args = (CV   => '',
              TERM => '',
              DBH  => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(CV TERM DBH));
  return(&getCVTerm(@args{qw(DBH CV TERM)},'type'));
}


# ****************************************************************************
# * getCVTerm                                                                *
# ****************************************************************************

=head2 getCVTerm

 Title:       getCVTerm
 Usage:       &getCVTerm($dbh,$cv,$term,'id');
 Description: This routine will return the specified field for a given CV
              term.
 Parameters:  dbh:   database handle
              cv:    CV
              term:  CV term
              field: field to return
 Returns:     specified field for CV term

=cut

sub getCVTerm
{
  my($dbh,$cv,$term,$field) = @_;
  $field ||= 'id';
  return($cvterm{$field}{$cv}{$term}) if (exists $cvterm{$field}{$cv}{$term});
#  my $statement = 'SELECT id,display_name,definition,data_type FROM cv_term_vw '
#                  . 'WHERE cv=? AND cv_term=? AND is_current=1';
  my $statement = 'SELECT id,display_name,definition,data_type FROM cv_term_vw '
                  . 'WHERE id=getCvTermID(?,?,NULL) AND is_current=1';
  my $sth = $dbh->prepare($statement);
  eval { $sth->execute($cv,$term); };
  croak "Problem searching for $term in CV $cv" if ($@);
  my($id,$display,$definition,$type) = $sth->fetchrow_array();
  # Populate hashes
  $cvterm{id}{$cv}{$term} = $id;
  $cvterm{display}{$cv}{$term} = $display || ucfirst($term);
  $cvterm{definition}{$cv}{$term} = $definition || '';
  $cvterm{type}{$cv}{$term} = $type || '';
  return($cvterm{$field}{$cv}{$term});
}


# ****************************************************************************
# * getLine                                                                  *
# ****************************************************************************

=head2 getLine

 Title:       getLine
 Usage:       &getLine(NAME => $name,LAB => $lab);
 Description: This routine will return the line ID for a given line.
 Parameters:  Named parameters
              NAME: (required) line name
              LAB:  (required) line lab
              DBH:  (optional) database handle
 Returns:     line ID

=cut

sub getLine
{
  my %args = (NAME => '',
              LAB  => '',
              DBH  => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(NAME LAB));
  my $statement = 'SELECT id FROM line WHERE name=? AND lab=?';
  my $sth = $args{DBH}->prepare($statement);
  $sth->execute(@args{qw(NAME LAB)});
  my($id) = $sth->fetchrow_array();
  return($id||'');
}


# ****************************************************************************
# * insertOperation                                                          *
# ****************************************************************************

=head2 insertOperation

 Title:       insertOperation
 Usage:       &getLine(OPERATION => $op,NAME => $name...);
 Description: This routine will insert an operation into the
              data_processing table along with its associated
              properties.
 Parameters:  Named parameters
              OPERATION: (required) operation term ("operation" CV)
              NAME:      (required) image name
              START:     (required) start timestamp
              STOP:      (required) stop timestamp
              PROGRAM:   (optional) program
              VERSION:   (optional) program version
              OPERATOR:  (optional) operator
              HOST:      (optional) host
              DBH:  (optional) database handle
 Returns:     1 for success, 0 for failure

=cut

sub insertOperation
{
my @DEFAULT = qw(OPERATION NAME START STOP PROGRAM
                 VERSION OPERATOR HOST);
  my %args = ((map { $_ => '' } @DEFAULT),
              DBH  => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(OPERATION NAME START STOP));
  # Get operation ID
  my $oid = &getCVTermID(CV => 'operation',TERM => $args{OPERATION});
  croak("Could not find ID for operation: $args{OPERATION}") unless ($oid);
  # Get image ID
  my $statement = 'SELECT id FROM image WHERE name=?';
  my $sth = $args{DBH}->prepare($statement);
  $sth->execute($args{NAME});
  my($iid) = $sth->fetchrow_array();
  $sth = $args{DBH}->prepare('INSERT INTO data_processing (operation_id,'
                             . "image_id,start,stop) VALUES (?,?,?,?)");
  eval { $sth->execute($oid,$iid,$args{START},$args{STOP}) };
  croak "Problem inserting operation $args{OPERATION}: $@" if ($@);
  my $dpid = $args{DBH}->last_insert_id(undef,undef,'data_processing','id');
  $sth = $args{DBH}->prepare('INSERT INTO data_processing_property ('
                             . 'data_processing_id,type_id,value) VALUES '
                             . '(?,?,?)');
  # Add properties
  $args{HOST} ||= hostname;
  $args{OPERATOR} ||= (getlogin || getpwuid($<));
  my %hash = %args;
  map { $hash{lc($_)} = $hash{$_} } qw(PROGRAM VERSION OPERATOR HOST);
  delete @hash{(@DEFAULT,'DBH')};
  foreach (sort keys %hash) {
    my $oid = &getCVTermID(CV => 'operation',TERM => $_);
    croak("Could not find ID for operation: $_") unless ($oid);
    eval { $sth->execute($dpid,$oid,$hash{$_}) };
    croak "Problem inserting property $_: $@" if ($@);
  }
}


# ****************************************************************************
# * getSession                                                               *
# ****************************************************************************

=head2 getSession

 Title:       getSession
 Usage:       &getSession(NAME => $name,CV => $cv,
                          TERM => $term,LAB => $lab);
 Description: This routine will return the session ID for a given
              session.
 Parameters:  Named parameters
              NAME: (required) session name
              CV:   (required) CV
              TERM: (required) CV term
              LAB:  (required) annotating lab
              DBH:  (optional) database handle
 Returns:     session ID

=cut

sub getSession
{
  my %args = (NAME => '',
              CV   => '',
              TERM => '',
              LAB  => '',
              DBH  => $main::dbh,
              @_);
  $args{$_} || croak("A $_ must be specified")
    foreach (qw(NAME CV TERM LAB));
  my $statement = 'SELECT id FROM session_vw WHERE name=? AND cv=? '
                  . 'AND type=? AND lab=?';
  my $sth = $args{DBH}->prepare($statement);
  $sth->execute(@args{qw(NAME CV TERM LAB)});
  my($id) = $sth->fetchrow_array();
  return($id||'');
}


# ****************************************************************************
# * Internal routines                                                        *
# ****************************************************************************

=head1 Internal functions

The following finctions are internal and are not meant to be called.
If you have a burning desire to see how they work, check the code.

=cut

# ****************************************************************************
# * Subroutine:  createPulldownQuery                                         *
# * Description: This routine will return HTML for a pulldown selection      *
# *              list.                                                       *
# *                                                                          *
# * Parameters:  item:   element ID                                          *
# *              ar:     list of choices (arrayref)                          *
# *              plural: plural form of item                                 *
# * Returns:     HTML                                                        *
# ****************************************************************************

=head2 createPulldownQuery

=cut

sub createPulldownQuery
{
  my($item,$ar,$plural) = @_;
  div({align => 'left'},
      popup_menu(&identify($item),
                 -values => [map {$_->[0]} @$ar],
                 -onChange => "countSelected('" . $item . "','"
                              . $item . "_count','"
                              . $plural . "s')"))
      . div({&identify($item . '_count'),
             class => 'select_count'},br);
}


# ****************************************************************************
# * Subroutine:  createScrolledQuery                                         *
# * Description: This routine will return HTML for a scrolled selection list *
# *              that will permit selection of multiples. It will display at *
# *              most 5 choices at a time.                                   *
# *                                                                          *
# * Parameters:  item:   element ID                                          *
# *              ar:     list of choices (arrayref)                          *
# *              plural: plural form of item                                 *
# * Returns:     HTML                                                        *
# ****************************************************************************

=head2 createScrolledQuery

=cut

sub createScrolledQuery
{
  my($item,$ar,$plural) = @_;
  my $size = scalar @$ar;
  $size = 10 if ($size > 10);
  div({align => 'left'},
      scrolling_list(&identify($item),
                     -values => [map {$_->[0]} @$ar],
                     -size => $size,
                     -multiple => 'true',
                     -onChange => "countSelected('" . $item . "','"
                                  . $item . "_count','"
                                  . $plural . "s')"))
      . div({&identify($item . '_count'),
             class => 'select_count'},br);
}


# ****************************************************************************
# * Subroutine:  createStackedQuery                                          *
# * Description: This routine will return HTML for a scrolled selection list *
# *              that will permit selection of multiples. It will display at *
# *              most 5 choices at a time. Above this scrolled list will be  *
# *              an autocomplete input field.                                *
# *                                                                          *
# * Parameters:  item:    element ID                                         *
# *              ar:      list of choices (arrayref)                         *
# *              plural:  plural form of item                                *
# *              display: item display text                                  *
# * Returns:     HTML                                                        *
# ****************************************************************************

=head2 createStackedQuery

=cut

sub createStackedQuery
{
  my($item,$ar,$plural,$display) = @_;
  my $size = scalar @$ar;
  $size = 8 if ($size > 8);
  div({align => 'left'},
      input({&identify($item . 's')})
            . img({src   => '/images/loading.gif',
                   style => 'display: none;',
                   id    => $item . '_loading'})
            . div({class => 'autocomplete',
                  map {$_ => $item . '_autocomplete'} qw(id name)},'') . br
            . scrolling_list(&identify($item),
                             -values => [map {$_->[0]} @$ar],
                             -size => $size,
                             -multiple => 'true',
                             -onChange => "countSelected('" . $item . "','"
                                          . $item . "_count','"
                                          . $display . "s')"))
            . div({&identify($item . '_count'),
                   class => 'select_count'},br);
}


# ****************************************************************************
# * Subroutine:  createRadioQuery                                            *
# * Description: This routine will return HTML for a radio button group. The *
# *              last choice (and the default) is always set to "(any)".     *
# *                                                                          *
# * Parameters:  item:   element ID                                          *
# *              ar:     list of choices (arrayref)                          *
# * Returns:     HTML                                                        *
# ****************************************************************************

=head2 createRadioQuery

=cut

sub createRadioQuery
{
  my($item,$ar) = @_;
  radio_group(&identify($item),
              -values  => @$ar);
}


# ****************************************************************************
# * Subroutine:  createLikeQuery                                             *
# * Description: This routine will return HTML for a "like" text field.      *
# *                                                                          *
# * Parameters:  eid:  element ID                                            *
# * Returns:     HTML                                                        *
# ****************************************************************************

=head2 createLikeQuery

=cut

sub createLikeQuery
{
  my $eid = shift;
  'contains '.textfield(&identify($eid));
}


# ****************************************************************************
# * Subroutine:  createCalendarQuery                                         *
# * Description: This routine will return HTML for a calendar select.        *
# *                                                                          *
# * Parameters:  eid:  element ID                                            *
# * Returns:     HTML                                                        *
# ****************************************************************************

=head2 createCalendarQuery

=cut

sub createCalendarQuery
{
  my $eid = shift;
  div({&identify($eid)},
      'Start date: ',
      textfield({&identify('start_date'),maxlength=>8,size=>8}),
      image_button({id=>'_start_date',src=>'/css/jscal/img.gif'}),
      (NBSP)x2,'End date: ',
      textfield({&identify('end_date'),maxlength=>8,size=>8}),
      image_button({id=>'_end_date',src=>'/css/jscal/img.gif'}));
}


# ****************************************************************************
# * Subroutine:  identify                                                    *
# * Description: This routine will return a hash to identify an HTML element.*
# *                                                                          *
# * Parameters:  (unspecified): element name                                 *
# * Returns:     id/name hash                                                *
# ****************************************************************************

=head2 identify

=cut

sub identify
{
  map { '-'.$_ => $_[0] } qw(id name);
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

  perldoc JFRC::Utils::SAGE

Copyright 2009 HHMI, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
