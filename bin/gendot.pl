#!/usr/bin/perl -w
#                              -*- Mode: Perl -*-
# gendot.pl ---
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com )
# Created On       : Wed Jul  3 13:08:38 2002
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Jul  9 16:07:12 2002
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 73
# Status           : Unknown, Use with caution!
# HISTORY          :
# Description      :
#
#

use strict;

require 5.002;

($main::MYNAME     = $main::0) =~ s|.*/||;
$main::Version     = '$Revision: 1.1 $ ';


use Carp;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

gendot - process a raw dump of task data into SQL or dot formats

=cut

# Command line options go into a global variable
my %Options = ();


=head1 SYNOPSIS

gendot [options] data_file [data_file ...]

Options:

   --help: 	     Short usage message
   --man:  	     Full manual page
   --run <number>: Run number (if only a single run is being loaded)
                   [default: 0]
   --status <base|stress>:  Status of the single run in these data files
                            [default: base]
   --description <desc>: Descriptive string about this run (if only a
                         single run is being loaded)

=cut

=head1 DESCRIPTION

This routine is designed to parse the data dump of tasks created by
the delayed action plugin, and create a SQL file to import the datga
into a MySQL database. You can pass in files for a single run, and
specify the run id and statu on the command line, or you can format
the various dump files as log.HOST.STATUS.RUNNUM. Optionally, for
strss runs, the status can be of the form sress_75CPU, and then 75CPU
would be entered as the description in the databse.

=cut

=head2 Internal Implementation

=head3 create_tables

This routine is used to delete and recreate the tables in the database
from scratch. Use with caution, since all data from the previous runs
would be lost.

=cut

sub create_tables {
  my %params = @_;
    print <<MSG;
DROP TABLE IF EXISTS tasks;
CREATE TABLE IF NOT EXISTS tasks (
  LOGSTAMP              datetime              default NULL,
  RunID     	   	int(11)      NOT NULL default '0',
  AgentID     	   	varchar(127) NOT NULL default '',
  TaskUID   	   	varchar(127) NOT NULL default '',
  Verb     	   	varchar(127) NOT NULL default '',
  ParentUID       	varchar(127)          default NULL,
  DirectObjectID   	varchar(127)          default NULL,
  NSNNumber             varchar(127)          default NULL,
  PreferredStartDate    datetime              default NULL,
  PreferredEndDate      datetime              default NULL,
  PreferredQuantity     double                default NULL,
  OrgID                 varchar(127)          default NULL,
  FromLocation          varchar(127)          default NULL,
  ToLocation            varchar(127)          default NULL,
  PlanElementID         varchar(127)          default NULL,
  PEType                varchar(127)          default NULL,
  EstimatedStartDate    datetime              default NULL,
  EstimatedEndDate      datetime              default NULL,
  EstimatedQuantity     double                default NULL,
  UNIQUE KEY            ix_task               (RunID, AgentID, TaskUID),
  KEY                   ix_parentid           (ParentUID)
) TYPE=MyISAM;

DROP TABLE IF EXISTS runs;
CREATE TABLE IF NOT EXISTS runs (
  ExperimentID     	int(11)      NOT NULL default '0',
  RunID     	   	int(11)      NOT NULL default '0',
  Type                  varchar(127) NOT NULL default '',
  Description           varchar(127)          default NULL,
  PRIMARY KEY           ix_runid              (ExperimentID, RunID)
) TYPE=MyISAM;
MSG
  ;
}


=head3 main

This is the top level routine in the script, and this is where the
command line handling is done.  

=cut


=head1 OPTIONS

=over 4

=item B<--help>

A short usage message is presented, and the program exits immediately.

=item B<--man>

Output the full manual page for this script.

=item B<--run>

The run number whose data is being processed. Defaults to 0, which is
a special run in SQL mode. The output of the first (0) run shall
create SQL statements to delete and recreate the data tables in the
database. One should be careful to specify the run number of
subsequent runs, or else the data in the database would be lost when
the SQL script is run. [Defaults to 0].

=item B<--status>

Specifies the type of run whose data is being processed. The values
should be C<base> or C<stress>. [Defaults to base].

=item B<--description>

Optional description of the run whose data is in the data file.

=back

=cut

sub main {
  my $parser = new Getopt::Long::Parser;

  $parser->configure ("bundling");
  $parser->getoptions(\%Options, 'help|?', 'run=i', 'status=s', 'description=s',
		      'man', 'experiment=i')
    or pod2usage(-exitstatus => 2, -msg => "Failed to parse options");


  pod2usage(1) if $Options{'help'};
  pod2usage(-exitstatus => 0, -msg => "$main::MYNAME : $main::Version\n",
	    -verbose => 2) if $Options{'man'};

  $Options{'run'} = 0  unless defined $Options{'run'};
  $Options{'experiment'} = 0  unless defined $Options{'experiment'};
  $Options{'status'} = 'base' unless defined $Options{'status'};

  if ($Options{'run'} == 0) {
    create_tables;
  }

  print "LOCK TABLES tasks WRITE;\n";
  foreach my $file (@ARGV) {
    print "LOAD DATA LOCAL INFILE '$file'\n";
    print "INTO TABLE tasks\n";
    print "FIELDS TERMINATED BY '|';\n";
  }
  print "UNLOCK TABLES;\n";

  print "LOCK TABLES runs WRITE;\n";
  my %seen = ();
  foreach my $file (@ARGV) {

    my @components = split ('\.', $file);
    if (3 == $#components && $components[0] =~ m/^log$/i) {
      $Options{'run'} = $components[3];
      $Options{'status'} = 'base' if $components[2] =~ m/^base$/i;
      if ($components[2] =~ m/^stress/) {
	$Options{'status'} = 'stress';
	if ($components[2] =~ m/^stress_(\S+)/) {
	  $Options{'description'} = $1;
	}
      }
    }
    next if $seen{$components[3]};
    $seen{$components[3]}++;

    print "INSERT INTO runs (RunID, Type, ExperimentID ";
    print ", Description" if $Options{'description'};
    print ") VALUES ('$Options{'run'}', '$Options{'status'}', '$Options{'experiment'}'";
    print ", '$Options{'description'}'" if $Options{'description'};
    print ");\n\n";

  }
  print "UNLOCK TABLES;\n";
}

&main;

=head1 CAVEATS

This is very inchoate, at the moment, and needs testing.

=cut

=head1 BUGS

None Known so far.

=cut

=head1 AUTHOR

Manoj Srivastava <manoj.srivastava@stdc.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002 System/Technology Development Corporation

You may contact System/Technology Development Corporation at
     System/Technology Development Corporation
     Suite 500, Center for Innovative Technology,
     2214 Rock Hill Road,
     Herndon, VA 20170
     (703) 476-0687


=cut

1;
