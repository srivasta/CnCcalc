#!/usr/bin/perl -w
#                              -*- Mode: Perl -*-
# parse_logs.pl ---
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com )
# Created On       : Fri Dec  6 11:03:48 2002
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Fri Dec 13 16:39:25 2002
# Last Machine Used: ember.green-gryphon.com
# Update Count     : 314
# Status           : Unknown, Use with caution!
# HISTORY          :
# Description      :
#
#
use strict;
use Time::Local;

my %row;
my %Timing;

my $expstart = 0;
my $oplan = 0;
my $gls = 0;
my $planning = 0;
my $logging = 0;
my $time = 0;
my %Seen = ();

my $planning_complete_initial 	      = 0;
my $planning_complete_Cplus5  	      = 0;
my $planning_complete_editOplan_1     = 0;
my $planning_complete_Cplus7          = 0;
my $planning_complete_editOplan_2     = 0;
my $planning_complete_Cplus10         = 0;
my $planning_complete_after_stimulator = 0;
my $expend = 0;



while (<>) {
  chomp;
  my $file;
  ($file = $ARGV) =~ s,.*/(.*)$,$1,;
  if ($file =~ m/\.log$/) {
    $file =~ s/\.log$//;

    if (m/\[INFO\]\s+(\S+)\s+(\S+)\s+::\s+Started run \d+ at/g) {
      $expstart = "$1_$2";
      $time  = "$1:$2";
    }
    if (m/\[INFO\]\s+(\S+)\s+(\S+)\s+::\s+Sent OPlan at (\d+) minutes (\d+) seconds/g) {
      $oplan = "0:$3:$4"  if  $4 >= 10;
      $oplan = "0:$3:0$4"  if $4 < 10;
      $time  = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+Published GLS Root at (\d+) minutes (\d+) seconds/g) {
      $gls   = "0:$3:$4"  if $4 >= 10;
      $gls   = "0:$3:0$4" if $4 < 10;
      $time  = "$1:$2";
    }

    if (m/\[INFO\] (\S+) (\S+) ::\s+Planning complete received at (\d+) minutes (\d+) seconds/g) {
      $planning = "0:$3:$4"  if $4 >= 10;
      $planning = "0:$3:0$4" if $4 < 10;
      $time  = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+got_planning_complete_after_stimulator received at (\d+) minutes (\d+) seconds/g) {
      $planning_complete_after_stimulator = "0:$3:$4" if $4 >= 10;
      $planning_complete_after_stimulator = "0:$3:0$4" if $4 < 10;
      $time  = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+Started CnCcalc at (\d+) minutes (\d+) seconds/g) {
      $logging = "0:$3:$4" if $4 >= 10;
      $logging = "0:$3:0$4" if $4 < 10;
      $time    = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+planning_complete_Cplus10 received at (\d+) minutes (\d+) seconds/g) {
      $planning_complete_Cplus10 = "0:$3:$4" if $4 >= 10;
      $planning_complete_Cplus10 = "0:$3:0$4" if $4 < 10;
      $time    = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+planning_complete_Cplus5 received at (\d+) minutes (\d+) seconds/g) {
      $planning_complete_Cplus5 = "0:$3:$4" if $4 >= 10;
      $planning_complete_Cplus5 = "0:$3:0$4" if $4 < 10;
      $time    = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+planning_complete_Cplus7 received at (\d+) minutes (\d+) seconds/g) {
      $planning_complete_Cplus7 = "0:$3:$4" if $4 >= 10;
      $planning_complete_Cplus7 = "0:$3:0$4" if $4 < 10;
      $time    = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+planning_complete_editOplan_1 received at (\d+) minutes (\d+) seconds/g) {
      $planning_complete_editOplan_1 = "0:$3:$4" if $4 >= 10;
      $planning_complete_editOplan_1 = "0:$3:0$4" if $4 < 10;
      $time    = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+planning_complete_editOplan_2 received at (\d+) minutes (\d+) seconds/g) {
      $planning_complete_editOplan_2 = "0:$3:$4" if $4 >= 10;
      $planning_complete_editOplan_2 = "0:$3:0$4" if $4 < 10;
      $time    = "$1:$2";
    }
    if (m/\[INFO\] (\S+) (\S+) ::\s+planning_complete_initial received at (\d+) minutes (\d+) seconds/g) {
      $planning_complete_initial = "0:$3:$4" if $4 >= 10;
      $planning_complete_initial = "0:$3:0$4" if $4 < 10;
      $time    = "$1:$2";
    }
    if (m/\[INFO\]\s+(\S+)\s+(\S+)\s+::\s+Completed run \d+/g) {
      $expend = "$1_$2";
    }


    if (eof) {
      next unless $time;
      my ($wday,$yday) = (0, 0);
      my ($year,$mon,$mday,$hour,$min,$sec) =
	($time =~ m/(\d+)-(\d+)-(\d+):(\d+):(\d+):(\d+)/g);

      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(timelocal($sec,$min,$hour,$mday,$mon - 1,$year));
      $mday = "0" . $mday if $mday < 10;
      $hour = "0" . $hour if $hour < 10;
      $min  = "0" . $min  if $min  < 10;
      $mon  += 1;
      $mon  = "0" . $mon  if $mon  < 10;
      $year += 1900;
      $sec  = "0" . $sec  if $sec  < 10;

      my $timestamp = $year . "-" . $mon . "-$mday" . "_" . "$hour:$min:$sec";

      $Timing{$file}{"$timestamp"}{'Logging'} = "$logging" if $logging;
      $Timing{$file}{"$timestamp"}{'Oplan'}   = "$oplan" if $oplan;
      $Timing{$file}{"$timestamp"}{'GLS'} = "$gls" if $gls;
      $Timing{$file}{"$timestamp"}{'Planning Complete'} = "$planning"
	if $planning;
      $Timing{$file}{"$timestamp"}{'Final Planning Complete'} = "$planning"
	if $planning;
      $Timing{$file}{"$timestamp"}{'Final Planning Complete'} =
	$planning_complete_after_stimulator
	  if (!$planning && $planning_complete_after_stimulator);

      $Timing{$file}{"$timestamp"}{'Planning Complete'} =
	$planning_complete_initial
	  if (!$planning && $planning_complete_initial);


      $Timing{$file}{"$timestamp"}{'PC Initial'} =
	$planning_complete_initial if $planning_complete_initial;
      $Timing{$file}{"$timestamp"}{'PC at C+5'} =
	$planning_complete_Cplus5 if $planning_complete_Cplus5;
      $Timing{$file}{"$timestamp"}{'Perturbation 1'} =
	$planning_complete_editOplan_1 if $planning_complete_editOplan_1;
      $Timing{$file}{"$timestamp"}{'PC at C+7'} =
	$planning_complete_Cplus7 if $planning_complete_Cplus7;
      $Timing{$file}{"$timestamp"}{'Perturbation 2'} =
	$planning_complete_editOplan_2 if $planning_complete_editOplan_2;
      $Timing{$file}{"$timestamp"}{'PC at C+10'} =
	$planning_complete_Cplus10 if $planning_complete_Cplus10;
      $Timing{$file}{"$timestamp"}{'Perturbation 3'} =
	$planning_complete_after_stimulator
	  if $planning_complete_after_stimulator;

      $Timing{$file}{"$timestamp"}{'Experiment Started'} = $expstart
	if $expstart;
      $Timing{$file}{"$timestamp"}{'Experiment Ended'} = $expend
	if $expend;

      $expstart = $oplan = $gls = $planning = $logging = $time = $expend = 0;
      $planning_complete_Cplus10= 0;
      $planning_complete_Cplus5= 0;
      $planning_complete_Cplus7= 0;
      $planning_complete_editOplan_1= 0;
      $planning_complete_editOplan_2= 0;
      $planning_complete_initial= 0;
      $planning_complete_after_stimulator = 0;
    }
  }
  elsif ($file =~ m/_results\.txt$/) {
    $file =~ s/_results\.txt$//;
    my ($experiment, $timedate) = ($file =~ m/^(.*)_(\d+-\d+-\d+_\d+:\d+:\d+)$/ );
    if (m/^\s*Completeness\s+\%\s+\|\s+([\d\.]+)\s+\|\s+([\d\.]+)\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{T_Completeness} = $1;
      $Timing{$experiment}{$timedate}{S_Completeness} = $2;
      $Timing{$experiment}{$timedate}{Completeness}   = $3;
      # print STDERR "Found Completeness = $1\n";
    }
    if (m/^\s*Correctness\s+%\s+\|\s+([\d\.]+)\s+\|\s+([\d\.]+)\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{T_Correctness} = $1;
      $Timing{$experiment}{$timedate}{S_Correctness} = $2;
      $Timing{$experiment}{$timedate}{Correctness}   = $3;
      # print STDERR "Found Correctness = $1\n";
    }
    if (m/^\s*Variation\s+%\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Variation} = $1;
      # print STDERR "Found Variation = $1\n";
    }
    if (m/^\s*Total Number\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Total} = $1;
      # print STDERR "Found Total = $1\n";
    }
    if (m/^\s*Incomplete Number Level 6\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Incomplete_L6} = $1;
      # print STDERR "Found Incomplete_L6 = $1\n";
    }
    if (m/^\s*Incomplete Number Level 2\s+\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Incomplete_L2} = $3;
      # print STDERR "Found Incomplete_L2 = $3\n";
    }
    if (m/^\s*Complete Number Level 6\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Complete_l6} = $1;
      #  print STDERR "Found Complete_l6 = $1\n";
    }
    if (m/^\s*Complete Number Level 2\s+\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Complete_l2} = $3;
      #  print STDERR "Found Complete_l2 = $3\n";
    }
    if (m/^\s*Phased AR  Number Level 6\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Phased_l6} = $1;
      # print STDERR "Found Phased_l6 = $1\n";
    }
    if (m/^\s*Phased AR  Number Level 2\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+[\d\.]+\s+\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Phased_l2} = $1;
      # print STDERR "Found Phased_l2 = $1\n";
    }

    if (m/^\s*Total Number.*First 7. min_start\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Total_7_AR} = $4;
      # print STDERR "Found Total_7_AR = $4\n";
    }
    if (m/^\s*Total Number .First 7. Preferred_start\s+\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Total_7_Pref} = $4;
      # print STDERR "Found Total_7_Pref = $4\n";
    }

    if (m/^\s*.*First 7.*Completeness % using baseline min_start_date\s+\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Completeness_7_AR} = $4;
      # print STDERR "Found Completeness_7_AR = $4\n";
    }
    if (m/^\s*.First 7. Completeness % using baseline Preferred_start_date\s+\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Completeness_7_Pref} = $4;
      # print STDERR "Found Completeness_7_Pref = $4\n";
    }

    if (m/^\s*.First 7. Correctness % using baseline min_start_date\s+\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Correcness_7_AR} = $4;
      # print STDERR "Found Correcness_7_AR = $4\n";
    }
    if (m/^\s*.First 7. Correctness % using baseline Preferred_start_date\s+\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s*([\d\.]+)?\s*\|\s+([\d\.]+)/) {
      $Timing{$experiment}{$timedate}{Correctness_7_Pref} = $4;
      # print STDERR "Found Correctness_7_Pref = $4\n";
    }
  }
  elsif ($file =~ m/_stressed\.sql/) {
    $file =~ s/_stressed\.sql$//;
    my ($experiment, $timedate) = ($file =~ m/^(.*)_(\d+-\d+-\d+_\d+:\d+:\d+)$/ );
    if (m/^\d+\t*\S+\t+\S+\t+(\S+)/) {
      my $verb = $1;
      $Seen{$verb}++;
    }
    if (eof) {
      my ($experiment, $timedate) = ($file =~ m/^(.*)_(\d+-\d+-\d+_\d+:\d+:\d+)$/ );
      for my $tasks (keys %Seen) {
	$Timing{$experiment}{$timedate}{$tasks} = $Seen{$tasks};
	# print STDERR "Found $tasks = $Seen{$tasks};\n";
      }
      %Seen = ();
    }
  }
  else {

  }
}

# for my $key (sort keys %Timing) {
#   print STDERR "$key\n";
#   for my $date (sort keys %{ $Timing{$key} }) {
#     print STDERR "    $date\n";
#     for my $type (sort keys %{ $Timing{$key}{$date} }) {
#       print STDERR "\t$type\t=>\t$Timing{$key}{$date}{$type}\n";
#     }
#   }
# }

# exit 0;

my %Notes;
my %Status;
my %Folder;

if (open (NOTES, "Notes")) {
  local $/ = "";
  while (<NOTES>) {
    chomp;
    next unless s/^\s*id\s*:\s*(\d+)\s*$//im;
    my $id = $1;
    next unless s/^\s*experimentid\s*:\s*(\S+)\s*$//im;
    my $experimentid=$1;
    my $status;
    if ( s/^\s*status\s*:\s*(\S+)\s*$//im) {
      $Status{$id}{$experimentid}=$1;
      $status = $1;
    }
    my $folder;
    if ( s/^\s*folder\s*:\s*(\S+)\s*$//im) {
      $Folder{$id}{$experimentid}=$1;
    }

    s/\n+/ /msg;
    s/^\s+/ /ms;
    s/\s+$/ /ms;
    # print STDERR "Found $id $experimentid\n";
    if ($status) {
      $Notes{$id}{$experimentid}="<span id=\"$status\">$_</span>";
    }
    else {
      $Notes{$id}{$experimentid}=$_;
    }
  }
}
else {
  warn "Could not open Notes:$!";
}



# for my $id (sort {$a <=> $b} keys %Notes) {
#   for my $exp (keys %{$Notes{$id}}) {
#     print "$id $exp description:[$Notes{$id}{$exp}]\n";
#   }
# }


my %twiki_files = ('runs0.txt' => 'runs0.out',
		   'runs1.txt' => 'runs1.out',
		   'runs2.txt' => 'runs2.out',
		   'runs3.txt' => 'runs3.out',
		   'runs4.txt' => 'runs4.out',
		   'runs5.txt' => 'runs5.out');

for my $input (sort keys %twiki_files) {
  # print STDERR "Doing file $input -> $twiki_files{$input}\n";
  if (! open (RUNS, "$input")) {
    warn "Did not find the file $input:$!";
    next;
  }

  if (! open (OUT, ">$twiki_files{$input}")) {
    warn "Could not open the output file $twiki_files{$input}:$!";
    next;
  }

  my $titles = <RUNS>;
  $titles =~ s/\*//g;


  my @title = split (/\s+\|\s+/, $titles);
  shift @title;

  print OUT "  |";
  for (@title) {
    print OUT "  *$_*  |";
  }
  print OUT "\n";

  while (<RUNS>) {
    chomp;
    next if /^\s*$/;
    next unless /\s+\|\s*\d+/;
    my $line = "  ";
    # Read line from file
    %row = ();
    @row{ 'dummy', @title } = split (/\s+\|\s+/);

    $row{Experimentid} =~ s/\s*(\S+)\s+.*$/$1/;
    # print STDERR "$row{Experimentid} ";

    if ($row{'Log Started'} && exists $Timing{$row{Experimentid}}) {
      print STDERR "Found. Started at $row{'Log Started'}. $input:$. ($row{id} $row{Experimentid})\n";

      my $starttime = $row{'Log Started'};
      my ($wday,$yday);
      my ($year,$mon,$mday,$hour,$min,$sec) =
	$starttime =~ m/(\d+)-(\d+)-(\d+)_(\d+):(\d+):(\d+)/;
      my $log_start_stamp = timegm($sec,$min,$hour,$mday,$mon - 1,$year);

      my $mindiff = -1;
      my $mintime = -1;
      for my $newtime (sort keys %{ $Timing{$row{Experimentid}} }) {
	($year,$mon,$mday,$hour,$min,$sec) =
	  $newtime =~ m/(\d+)-(\d+)-(\d+)_(\d+):(\d+):(\d+)/;
	my $newstamp = timegm($sec,$min,$hour,$mday,$mon - 1,$year);

	if (defined $Timing{$row{Experimentid}}{$newtime}{'Experiment Started'}
	    &&
	    defined $Timing{$row{Experimentid}}{$newtime}{'Experiment Ended'}){
	  ($year,$mon,$mday,$hour,$min,$sec) =
	    ($Timing{$row{Experimentid}}{$newtime}{'Experiment Started'}
	     =~ m/(\d+)-(\d+)-(\d+)_(\d+):(\d+):(\d+)/g);

	  my $startstamp =
	    timelocal($sec,$min,$hour,$mday,$mon - 1,$year);

	  ($year,$mon,$mday,$hour,$min,$sec) =
	    ($Timing{$row{Experimentid}}{$newtime}{'Experiment Ended'}
	     =~ m/(\d+)-(\d+)-(\d+)_(\d+):(\d+):(\d+)/g);

	  my $endstamp =
	    timelocal($sec,$min,$hour,$mday,$mon - 1,$year);

	  if ($startstamp < $log_start_stamp && $endstamp > $log_start_stamp) {
	    # print STDERR "start = $startstamp; new = $log_start_stamp; end=$endstamp;\n";
	    $mindiff = 0.0000000001;
	    $mintime = $newtime;
	    last;
	  }
	}
	else {

	  my $diff = abs($newstamp - $log_start_stamp);
	  # print STDERR "\t $row{'Log Started'} => $newtime ($diff)\n";
	  if ($mindiff < 0 || $diff < $mindiff  ) {
	    $mindiff = $diff;
	    $mintime = $newtime;
	    # print STDERR "\t $row{'Log Started'} => $newtime ($diff)\n";
	  }
	}
      }
      if ($mindiff >= 0 && $mindiff < 3600) {
	# print STDERR "  Matched: $row{'Log Started'} => $mintime ($mindiff)\n";
	# print STDERR "  $input Matched: @title\n";
	for my $type (sort keys %{ $Timing{$row{Experimentid}}{$mintime} } ) {
	  # print STDERR
	  #  "Matched:\t$type=>$Timing{$row{Experimentid}}{$mintime}{$type}\n";
	  next if $type =~ m/Logging/;
	  next unless exists $row{$type};
	  next unless $row{$type} =~ m/^\s*\&nbsp\;\s*$/;
	  $row{$type} = $Timing{$row{Experimentid}}{$mintime}{$type};
	  # print STDERR "$type updated\n";
	}
      }
    }
    # print STDERR ".\n";
    if (exists $Notes{$row{id}}{$row{Experimentid}}) {
      $row{Notes} = $Notes{$row{id}}{$row{Experimentid}};
    }
    $row{Completeness} = sprintf("%.5f", $row{Completeness})
      if (exists $row{Completeness} &&
	  defined $row{Completeness} &&
	  $row{Completeness} =~ m/^\s*[\d\.]+\s*$/);
    $row{Correctness} = sprintf("%.5f", $row{Correctness})
      if (exists $row{Correctness} &&
	  defined $row{Correctness} &&
	  $row{Correctness} =~ m/^\s*[\d\.]+\s*$/);
    $row{Variation} = sprintf("%.5f", $row{Variation})
      if (exists $row{Variation} &&
	  defined $row{Variation} &&
	  $row{Variation} =~ m/^\s*[\d\.]\;\s*$/);

    # Last thing before we write the notes back
    if (exists $Folder{$row{id}}{$row{Experimentid}}) {
      $row{Experimentid} .= " <span class=\"Folder\">$Folder{$row{id}}{$row{Experimentid}}</span> "
    }
    # write line back
    for my $key (@title) {
      $line .= "|  $row{$key}  " if exists $row{$key} && defined $row{$key};
      $line .= "|  \&nbsp;  " unless exists $row{$key} && defined $row{$key};
    }
    chop $line;
    chop $line;
    print OUT "$line  |  \n";
  }

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
  $year += 1900;
  my $month = (qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec))[$mon];
  print OUT "\n\n-- [[Main.ManojSrivastava][Manoj]] - $mday $month $year\n";
  close RUNS;
  close OUT;
}


