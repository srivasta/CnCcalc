#!/usr/bin/perl -w
#                              -*- Mode: Perl -*-
# gen_deriv.pl ---
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com )
# Created On       : Mon Jul  8 17:36:15 2002
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Jul  9 18:42:21 2002
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 39
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

gen_deriv - create a SQL script to process the raw data in the data base

=cut


=head1 SYNOPSIS

gen_deriv [options]

Options:

   --help:            Short usage message
   --man:             Full manual page
   --experiment NAME  Set the experiment name (unimplimented)

=cut

=head1 DESCRIPTION

Creates the SQL for the derived tables for the experiment.

=cut

=head2 Internal Implementation


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

=item B<--experiment> B<experiment name>

This specifies the experiment we are conducting. Defaults to the
constant 'Robustness_1'.

=back

=cut

sub main {
  my %Options = ();
  my $parser = new Getopt::Long::Parser;

  $parser->configure ("bundling");
  $parser->getoptions(\%Options, 'help|?', 'man', 'experiment=s')
    or pod2usage(-exitstatus => 2, -msg => "Failed to parse options");


  pod2usage(1) if $Options{'help'};
  pod2usage(-exitstatus => 0, -msg => "$main::MYNAME : $main::Version\n",
            -verbose => 2) if $Options{'man'};

  $Options{'experiment'} = 'Robustness_1'  unless $Options{'experiment'};


  print <<EOF;

DROP TABLE IF EXISTS Scoring_Constants;
CREATE TABLE Scoring_Constants (
ID          varchar(127) NOT NULL default '',
A           double           default '0',
B           double           default '10',
C           double           default 0,
D           double           default 0,
E           double           default 0,
F           double           default 0,
G           double           default 0,
H           double           default 0,
UNIQUE KEY  ix_ID            (ID)
) TYPE=MyISAM;

INSERT INTO Scoring_Constants
VALUES ('Default', '0', '10', '0', '0', '0', '0', '0', '0');

DROP TABLE IF EXISTS TempRun;
CREATE TABLE TempRun (
  ID                 varchar(127)  NOT NULL default '',
  NAME               varchar(127),
  VALUE              int(11)
) TYPE=MyISAM;

INSERT INTO TempRun
SELECT 'LOW_BASE', 'The Minimum Base Run', min(ID)
FROM runs
WHERE Type = 'base' AND ExperimentID = '$Options{experiment}';

INSERT INTO TempRun
SELECT 'HIGH_BASE', 'The Maximum Base Run', max(ID)
FROM runs
WHERE Type = 'base'AND ExperimentID = '$Options{experiment}';

INSERT INTO TempRun
SELECT 'STRESS', 'The Stressed Run', ID
FROM runs
WHERE Type = 'stress' AND ExperimentID = '$Options{experiment}';

DROP TABLE IF EXISTS Derived_RelevantTasks;
CREATE TABLE Derived_RelevantTasks (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  ParentID              varchar(63)           default NULL,
  agent                 varchar(63)           default NULL,
  verb                  varchar(31)           default NULL,
  asset_id              varchar(63)           default NULL,
  pe_id                 varchar(63)           default NULL,
  UNIQUE KEY            ix_task               (RunID, TaskUID)
) TYPE=MyISAM;

INSERT INTO Derived_RelevantTasks
SELECT DISTINCT my_task.run_id, my_task.id, my_task.parentid, my_task.agent,
       my_task.verb,   my_task.asset_id, my_task.pe_id
FROM tasks my_task, tasks p_task
WHERE my_task.parentid = p_task.id
 AND (my_task.verb IN ('Transport'))
 AND (p_task.verb IN ('DetermineRequirements'));

INSERT INTO Derived_RelevantTasks
SELECT DISTINCT my_task.run_id, my_task.id, my_task.parentid, my_task.agent,
       my_task.verb,   my_task.asset_id, my_task.pe_id
FROM tasks my_task, tasks p_task
WHERE my_task.parentid = p_task.id
 AND (my_task.verb IN ('Supply', 'ProjectSupply'))
 AND (p_task.verb IN ('GenerateProjections'));

DROP TABLE IF EXISTS Derived_RelevantAssets;
CREATE TABLE Derived_RelevantAssets (
 id            varchar(63)  NOT NULL  PRIMARY KEY,
 classname     varchar(255) NOT NULL default ' ',
 typepg_id     int(11)           default NULL,
 itempg_id     int(11)           default NULL,
 prototype_id  varchar(63)       default NULL,
 isAggregate   tinyint(1)        default NULL,
 quantity      int(11)           default NULL
) TYPE=MyISAM;

INSERT INTO Derived_RelevantAssets (id, classname, typepg_id, itempg_id,
                                    prototype_id, isAggregate, quantity )
SELECT DISTINCT assets.id, assets.classname, assets.typepg_id,
       assets.itempg_id, assets.prototype_id, assets.isAggregate,
       assets.quantity
FROM assets, Derived_RelevantTasks task
WHERE assets.id = task.asset_id;


DROP TABLE IF EXISTS Derived_RelevantTypePG;
CREATE TABLE Derived_RelevantTypePG (
 id            int(11)     NOT NULL  PRIMARY KEY AUTO_INCREMENT,
 typeId        varchar(63) default NULL,
 nomenclature  varchar(63) default NULL,
 altTypeId     varchar(63) default NULL
) TYPE=MyISAM;

INSERT INTO Derived_RelevantTypePG (id, typeid, nomenclature, altTypeId)
SELECT DISTINCT 0, typepg.typeid, typepg.nomenclature, typepg.altTypeId
FROM  Derived_RelevantAssets assets, typepg
WHERE assets.typepg_id = typepg.id;

DROP TABLE IF EXISTS Derived_RelevantPrepositions;
CREATE TABLE Derived_RelevantPrepositions (
 id            int(11)      NOT NULL  PRIMARY KEY AUTO_INCREMENT,
 task_Id       varchar(63)  NOT NULL default ' ',
 prep          varchar(31)  NOT NULL default ' ',
 val           varchar(255) default NULL
) TYPE=MyISAM;

INSERT INTO Derived_RelevantPrepositions (id, task_id, prep, val)
SELECT DISTINCT 0, prepositions.task_id, prepositions.prep, prepositions.val
FROM  Derived_RelevantTasks task, prepositions
WHERE prepositions.task_id = task.TaskUID;

DROP TABLE IF EXISTS Derived_RelevantPreferences;
CREATE TABLE Derived_RelevantPreferences (
 id            int(11)      NOT NULL  PRIMARY KEY AUTO_INCREMENT,
 task_Id       varchar(63)  NOT NULL default ' ',
 aspecttype    varchar(63)  NOT NULL default ' ',
 bestvalue     double   default NULL
) TYPE=MyISAM;

INSERT INTO Derived_RelevantPreferences (id, task_id, aspecttype, bestvalue)
SELECT DISTINCT 0, preferences.task_id, preferences.aspecttype,
                   preferences.bestvalue
FROM  Derived_RelevantTasks task, preferences
WHERE preferences.task_id = task.TaskUID;

DROP TABLE IF EXISTS Derived_Relevant_AllocResults;
CREATE TABLE Derived_Relevant_AllocResults (
 id           int(11)      NOT NULL  PRIMARY KEY AUTO_INCREMENT,
 type         varchar(63)  NOT NULL default ' ',
 pe_id        varchar(63)  NOT NULL default ' ',
 success      tinyint(1)  default  NULL,
 phased       tinyint(1)  default  NULL,
 confidence   float       default  NULL
) TYPE=MyISAM;

INSERT INTO Derived_Relevant_AllocResults (id, type, pe_id, success,
                                           phased, confidence)
SELECT DISTINCT 0, Alloc_result.type, Alloc_result.pe_id,
                   Alloc_result.success, Alloc_result.phased,
                   Alloc_result.confidence
FROM  Derived_RelevantTasks task, allocation_results Alloc_result
WHERE Alloc_result.pe_id = task.pe_id AND Alloc_result.type = 'ESTIMATED';


DROP TABLE IF EXISTS Temp_Aspects;
CREATE TABLE Temp_Aspects (
 id          int(11)     NOT NULL   PRIMARY KEY auto_increment,
 ar_id       int(11)     NOT NULL   default '0',
 aspecttype  varchar(63) NOT NULL   default ' ',
 value       double                 default NULL
) TYPE=MyISAM;

INSERT INTO Temp_Aspects (id, ar_id, aspecttype, value)
SELECT DISTINCT 0, aspect.ar_id, aspect.aspecttype, aspect.value
FROM aspectvalues aspect, Derived_Relevant_AllocResults Alloc_result
WHERE aspect.ar_id = Alloc_result.id;


DROP TABLE IF EXISTS Temp_TR_One;
CREATE TABLE Temp_TR_One (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  AgentID               varchar(127) NOT NULL default '',
  Verb                  varchar(127) NOT NULL default '',
  NSNNumber             varchar(127)          default NULL
) TYPE=MyISAM;

INSERT INTO Temp_TR_One (RunID, TaskUID, AgentID, Verb, NSNNumber)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       task.Agent as AgentID, task.Verb, typepg.typeId as NSNNumber
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantAssets assets, Derived_RelevantTypePG typepg
WHERE task.verb = 'Transport'
  AND task.runid BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND assets.id = task.asset_id AND assets.typepg_id = typepg.id;


DROP TABLE IF EXISTS Temp_TR_Two;
CREATE TABLE Temp_TR_Two (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  FromLocation          varchar(127)          default NULL,
  ToLocation            varchar(127)          default NULL,
  ForAgent              varchar(127)          default NULL
) TYPE=MyISAM;

INSERT INTO Temp_TR_Two (RunID, TaskUID,  FromLocation, ToLocation, ForAgent)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       prepositions_1.val as FromLocation, prepositions_2.val as ToLocation,
       prepositions_3.val as ForAgent
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantPrepositions prepositions_1,
      Derived_RelevantPrepositions prepositions_2,
      Derived_RelevantPrepositions prepositions_3
WHERE task.verb = 'Transport'
  AND task.runid BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND prepositions_1.task_id = task.TaskUID AND prepositions_1.prep = 'From'
  AND prepositions_2.task_id = task.TaskUID AND prepositions_2.prep = 'To'
  AND prepositions_3.task_id = task.TaskUID AND prepositions_3.prep = 'For';


DROP TABLE IF EXISTS Temp_TR_Three;
CREATE TABLE Temp_TR_Three (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  PreferredStartDate    datetime              default NULL,
  PreferredEndDate      datetime              default NULL
) TYPE=MyISAM;

INSERT INTO Temp_TR_Three (RunID, TaskUID, PreferredStartDate, 
            PreferredEndDate)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       preferences_1.bestvalue as PreferredStartDate,
       preferences_2.bestvalue as PreferredEndDate
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantAssets assets, Derived_RelevantTypePG typepg,
      Derived_RelevantPreferences  preferences_1,
      Derived_RelevantPreferences  preferences_2
WHERE task.verb = 'Transport'
  AND task.runid BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND preferences_1.task_id = task.TaskUID
  AND preferences_1.aspecttype = 'START_TIME'
  AND preferences_2.task_id = task.TaskUID
  AND preferences_2.aspecttype = 'END_TIME';



DROP TABLE IF EXISTS Temp_TR_Four;
CREATE TABLE Temp_TR_Four (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  StartDate          datetime              default NULL,
  EndDate            datetime              default NULL,
) TYPE=MyISAM;

INSERT INTO Temp_TR_Four (RunID, TaskUID, StartDate, EndDate)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       aspect_val_1.value as StartDate,
       aspect_val_2.value as EndDate
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_Relevant_AllocResults Alloc_result,
      Temp_Aspects aspect_val_1,
      Temp_Aspects aspect_val_2
WHERE task.verb = 'Transport'
  AND task.runid BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND Alloc_result.pe_id = task.pe_id
  AND aspect_val_1.ar_id = Alloc_result.id
  AND aspect_val_1.aspecttype = 'START_TIME'
  AND aspect_val_2.ar_id = Alloc_result.id
  AND aspect_val_2.aspecttype = 'END_TIME';




DROP TABLE IF EXISTS Temp_Sup_One;
CREATE TABLE Temp_Sup_One (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  AgentID               varchar(127) NOT NULL default '',
  Verb                  varchar(127) NOT NULL default '',
  NSNNumber             varchar(127)          default NULL
) TYPE=MyISAM;

INSERT INTO Temp_Sup_One (RunID, TaskUID, AgentID, Verb, NSNNumber)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       task.Agent as AgentID, task.Verb, typepg.typeId as NSNNumber
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantAssets assets, Derived_RelevantTypePG typepg
WHERE task.verb = 'Supply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND assets.id = task.asset_id  AND typepg.id = assets.itempg_id;


DROP TABLE IF EXISTS Temp_Sup_Two;
CREATE TABLE Temp_Sup_Two (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  ToLocation            varchar(127)          default NULL,
  ForAgent              varchar(127)          default NULL
) TYPE=MyISAM;

INSERT INTO Temp_Sup_Two (RunID, TaskUID, ToLocation, ForAgent)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       prepositions_1.val as ToLocation,
       prepositions_2.val as ForAgent
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantPrepositions prepositions_1,
      Derived_RelevantPrepositions prepositions_2
WHERE task.verb = 'Supply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND prepositions_1.task_id = task.TaskUID AND prepositions_1.prep = 'To'
  AND prepositions_2.task_id = task.TaskUID AND prepositions_2.prep = 'For';

DROP TABLE IF EXISTS Temp_Sup_Three;
CREATE TABLE Temp_Sup_Three (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  PreferredQuantity     double                default NULL,
  PreferredEndDate      datetime              default NULL
) TYPE=MyISAM;

INSERT INTO Temp_Sup_Three (RunID, TaskUID, PreferredQuantity, 
                            PreferredEndDate)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       preferences_1.bestvalue as PreferredQuantity,
       preferences_2.bestvalue as PreferredEndDate
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantPreferences  preferences_1,
      Derived_RelevantPreferences  preferences_2
WHERE task.verb = 'Supply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND preferences_1.task_id = task.TaskUID
  AND preferences_1.aspecttype = 'QUANTITY'
  AND preferences_2.task_id = task.TaskUID
  AND preferences_2.aspecttype = 'END_TIME';

DROP TABLE IF EXISTS Temp_Sup_Four;
CREATE TABLE Temp_Sup_Four (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  EndDate               datetime              default NULL,
  Quantity              double                default NULL
) TYPE=MyISAM;

INSERT INTO Temp_Sup_Four (RunID, TaskUID, EndDate, Quantity)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       aspect_val_1.value as EndDate,
       aspect_val_2.value as Quantity
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_Relevant_AllocResults Alloc_result,
      Temp_Aspects aspect_val_1,
      Temp_Aspects aspect_val_2
WHERE task.verb = 'Supply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND Alloc_result.pe_id = task.pe_id
  AND aspect_val_1.ar_id = Alloc_result.id
  AND aspect_val_1.aspecttype = 'START_TIME'
  AND aspect_val_2.ar_id = Alloc_result.id
  AND aspect_val_2.aspecttype = 'QUANTITY';

DROP TABLE IF EXISTS Temp_PS_One;
CREATE TABLE Temp_PS_One (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  AgentID               varchar(127) NOT NULL default '',
  Verb                  varchar(127) NOT NULL default '',
  NSNNumber             varchar(127)          default NULL
) TYPE=MyISAM;



INSERT INTO Temp_PS_One (RunID, TaskUID, AgentID, Verb, NSNNumber)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       task.Agent as AgentID, task.Verb, typepg.typeId as NSNNumber
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantAssets assets, Derived_RelevantTypePG typepg
WHERE task.verb = 'ProjectSupply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND assets.id = task.asset_id  AND typepg.id = assets.typepg_id;


DROP TABLE IF EXISTS Temp_PS_Two;
CREATE TABLE Temp_PS_Two (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  FromLocation          varchar(127)          default NULL,
  ToLocation            varchar(127)          default NULL
  ForAgent              varchar(127)          default NULL,
) TYPE=MyISAM;

INSERT INTO Temp_PS_Two (RunID, TaskUID, FromLocation, ToLocation, ForAgent)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       prepositions_1.val as FromLocation, prepositions_2.val as ToLocation,
       prepositions_3.val as ForAgent
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantPrepositions prepositions_1,
      Derived_RelevantPrepositions prepositions_2,
      Derived_RelevantPrepositions prepositions_3
WHERE task.verb = 'ProjectSupply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND prepositions_1.task_id = task.TaskUID AND prepositions_1.prep = 'From'
  AND prepositions_2.task_id = task.TaskUID AND prepositions_2.prep = 'To'
  AND prepositions_3.task_id = task.TaskUID AND prepositions_3.prep = 'For';



DROP TABLE IF EXISTS Temp_PS_Three;
CREATE TABLE Temp_PS_Three (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  PreferredStartDate    datetime              default NULL,
  PreferredEndDate      datetime              default NULL
) TYPE=MyISAM;

INSERT INTO Temp_PS_Three (RunID, TaskUID, PreferredStartDate,
                         PreferredEndDate)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       preferences_1.bestvalue as PreferredStartDate,
       preferences_2.bestvalue as PreferredEndDate
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_RelevantPreferences  preferences_1,
      Derived_RelevantPreferences  preferences_2
WHERE task.verb = 'ProjectSupply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND preferences_1.task_id = task.TaskUID
  AND preferences_1.aspecttype = 'START_TIME'
  AND preferences_2.task_id = task.TaskUID
  AND preferences_2.aspecttype = 'END_TIME';


DROP TABLE IF EXISTS Temp_PS_Four;
CREATE TABLE Temp_PS_Four (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  StartDate          datetime              default NULL,
  EndDate            datetime              default NULL,
) TYPE=MyISAM;

INSERT INTO Temp_PS__Four (RunID, TaskUID, StartDate, EndDate)
SELECT task.runid as RunID, task.TaskUID as TaskUID,
       aspect_val_1.value as StartDate,
       aspect_val_2.value as EndDate
FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
      Derived_Relevant_AllocResults Alloc_result,
      Temp_Aspects aspect_val_1,
      Temp_Aspects aspect_val_2
WHERE task.verb = 'ProjectSupply'
  AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
  AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
  AND Alloc_result.pe_id = task.pe_id 
  AND aspect_val_1.ar_id = Alloc_result.id
  AND aspect_val_2.ar_id = Alloc_result.id
  AND aspect_val_1.aspecttype = 'START_TIME'
  AND aspect_val_2.aspecttype = 'END_TIME';




DROP TABLE IF EXISTS Temp_Derived_Baseline;
CREATE TABLE Temp_Derived_Baseline (
  AgentID               varchar(127) NOT NULL default '',
  Verb                  varchar(127) NOT NULL default '',
  NSNNumber             varchar(127)          default NULL,
  FromLocation          varchar(127)          default NULL,
  ToLocation            varchar(127)          default NULL,
  ForAgent              varchar(127)          default NULL,
  PreferredQuantity     double                default NULL,
  PreferredStartDate    datetime              default NULL,
  PreferredEndDate      datetime              default NULL,
  MINStartDate          datetime              default NULL,
  MAXStartDate          datetime              default NULL,
  MINEndDate            datetime              default NULL,
  MAXEndDate            datetime              default NULL,
  MINQuantity           double                default NULL,
  MAXQuantity           double                default NULL
) TYPE=MyISAM;

INSERT INTO Temp_Derived_Baseline (
  AgentID, Verb, NSNNumber, FromLocation, ToLocation, ForAgent,
  PreferredStartDate, PreferredEndDate,
  MINStartDate, MAXStartDate, MINEndDate, MAXEndDate)
SELECT Temp_TR_One.AgentID, Temp_TR_One.Verb, Temp_TR_One.NSNNumber,
       Temp_TR_Two.FromLocation, Temp_TR_Two.ToLocation,
       Temp_TR_Two.ForAgent,
       Temp_TR_Three.PreferredStartDate,
       Temp_TR_Three.PreferredEndDate,
       min(Temp_TR_Four.StartDate) as MINStartDate,
       max(Temp_TR_Four.StartDate) as MAXStartDate,
       min(Temp_TR_Four.EndDate) as MINEndDate,
       max(Temp_TR_Four.EndDate) as MAXEndDate
FROM  Temp_TR_One, Temp_TR_Two, Temp_TR_Three, Temp_TR_Four
WHERE Temp_TR_One.RunID = Temp_TR_Two.RunID
      Temp_TR_Two.RunID = Temp_TR_Three.RunID
      Temp_TR_Three.RunID = Temp_TR_Four.RunID
      Temp_TR_One.TaskUID = Temp_TR_Two.TaskUID
      Temp_TR_Two.TaskUID = Temp_TR_Three.TaskUID
      Temp_TR_Three.TaskUID = Temp_TR_Four.TaskUID
GROUP BY AgentID, Verb, NSNNumber, FromLocation, ToLocation,
         ForAgent, PreferredStartDate,  PreferredEndDate;

INSERT INTO Temp_Derived_Baseline (
  AgentID, Verb, NSNNumber, ToLocation, ForAgent,
  PreferredQuantity, PreferredEndDate,
  MINQuantity, MAXQuantity, MINEndDate, MAXEndDate)
SELECT Temp_Sup_One.AgentID, Temp_Sup_One.Verb, Temp_Sup_One.NSNNumber,
       Temp_Sup_Two.ToLocation, Temp_Sup_Two.ForAgent,
       Temp_Sup_Three.PreferredQuantity,
       Temp_Sup_Three.PreferredEndDate,
       min(Temp_Sup_Four.Quantity) as MINQuantity,
       max(Temp_Sup_Four.Quantity) as MAXQuantity,
       min(Temp_Sup_Four.EndDate) as MINEndDate,
       max(Temp_Sup_Four.EndDate) as MAXEndDate
FROM  Temp_Sup_One, Temp_Sup_Two, Temp_Sup_Three, Temp_Sup_Four
WHERE Temp_Sup_One.RunID = Temp_Sup_Two.RunID
      Temp_Sup_Two.RunID = Temp_Sup_Three.RunID
      Temp_Sup_Three.RunID = Temp_Sup_Four.RunID
      Temp_Sup_One.TaskUID = Temp_Sup_Two.TaskUID
      Temp_Sup_Two.TaskUID = Temp_Sup_Three.TaskUID
      Temp_Sup_Three.TaskUID = Temp_Sup_Four.TaskUID
GROUP BY AgentID, Verb, NSNNumber, ToLocation,
         ForAgent, PreferredQuantity,  PreferredEndDate;


INSERT INTO Temp_Derived_Baseline (
  AgentID, Verb, NSNNumber, FromLocation, ToLocation, ForAgent,
  PreferredStartDate, PreferredEndDate,
  MINStartDate, MAXStartDate, MINEndDate, MAXEndDate)
SELECT Temp_PS_One.AgentID, Temp_PS_One.Verb, Temp_PS_One.NSNNumber,
       Temp_PS_Two.FromLocation, Temp_PS_Two.ToLocation,
       Temp_PS_Two.ForAgent,
       Temp_PS_Three.PreferredStartDate,
       Temp_PS_Three.PreferredEndDate,
       min(Temp_PS_Four.StartDate) as MINStartDate,
       max(Temp_PS_Four.StartDate) as MAXStartDate,
       min(Temp_PS_Four.EndDate) as MINEndDate,
       max(Temp_PS_Four.EndDate) as MAXEndDate
FROM  Temp_PS_One, Temp_PS_Two, Temp_PS_Three, Temp_PS_Four
WHERE Temp_PS_One.RunID = Temp_PS_Two.RunID
      Temp_PS_Two.RunID = Temp_PS_Three.RunID
      Temp_PS_Three.RunID = Temp_PS_Four.RunID
      Temp_PS_One.TaskUID = Temp_PS_Two.TaskUID
      Temp_PS_Two.TaskUID = Temp_PS_Three.TaskUID
      Temp_PS_Three.TaskUID = Temp_PS_Four.TaskUID
GROUP BY AgentID, Verb, NSNNumber, FromLocation, ToLocation,
         ForAgent, PreferredStartDate,  PreferredEndDate;



DROP TABLE IF EXISTS Derived_Baseline;
CREATE TABLE Derived_Baseline (
  AgentID               varchar(127) NOT NULL default '',
  Verb                  varchar(127) NOT NULL default '',
  NSNNumber             varchar(127)          default NULL,
  FromLocation          varchar(127)          default NULL,
  ToLocation            varchar(127)          default NULL,
  PreferredQuantity     double                default NULL,
  PreferredStartDate    datetime              default NULL,
  PreferredEndDate      datetime              default NULL,
  MINStartDate          datetime              default NULL,
  MAXStartDate          datetime              default NULL,
  MINEndDate            datetime              default NULL,
  MAXEndDate            datetime              default NULL,
  MINQuantity           double                default NULL,
  MAXQuantity           double                default NULL,
  ScoreStartDate        double                default NULL,
  ScoreEndDate          double                default NULL,
  ScoreQuantity         double                default NULL
) TYPE=MyISAM;

INSERT INTO Derived_Baseline
SELECT t1.AgentID, t1.Verb, t1.NSNNumber, t1.FromLocation, t1.ToLocation,
       t1.PreferredQuantity, t1.PreferredStartDate,
       t1.PreferredEndDate, t1.MINStartDate, t1.MAXStartDate, t1.MINEndDate ,
       t1.MAXEndDate , t1.MINQuantity , t1.MAXQuantity,
       case ABS(t1.PreferredStartDate - t1.MINStartDate)  >
            ABS(t1.PreferredStartDate - t1.MAXStartDate)
       when 0 then POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                            UNIX_TIMESTAMP(t1.MAXStartDate)) / 86400), 4)
                        * t2.E +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                            UNIX_TIMESTAMP(t1.MAXStartDate)) / 86400), 3)
                        * t2.D +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                            UNIX_TIMESTAMP(t1.MAXStartDate)) / 86400), 2)
                        * t2.C +
                   ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                       UNIX_TIMESTAMP(t1.MAXStartDate)) / 86400
                        * t2.B
                   + t2.A
              else POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                            UNIX_TIMESTAMP(t1.MINStartDate)) / 86400), 4)
                      * t2.E +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                            UNIX_TIMESTAMP(t1.MINStartDate)) / 86400), 3)
                      * t2.D +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                            UNIX_TIMESTAMP(t1.MINStartDate)) / 86400), 2)
                      * t2.C +
                   ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
                       UNIX_TIMESTAMP(t1.MINStartDate)) / 86400 * t2.B
                   + t2.A
       end,
       case ABS(t1.PreferredEndDate - t1.MINEndDate) >
             ABS(t1.PreferredEndDate - t1.MAXEndDate)
       when 0 then POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                            UNIX_TIMESTAMP(t1.MAXEndDate)) / 86400), 4)
                     * t2.E +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                            UNIX_TIMESTAMP(t1.MAXEndDate)) / 86400), 3)
                     * t2.D +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                            UNIX_TIMESTAMP(t1.MAXEndDate)) / 86400), 2)
                     * t2.C +
                   ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                       UNIX_TIMESTAMP(t1.MAXEndDate)) / 86400 * t2.B
                   + t2.A
               else POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                             UNIX_TIMESTAMP(t1.MINEndDate)) / 86400), 4)
                     * t2.E +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                             UNIX_TIMESTAMP(t1.MINEndDate)) / 86400), 3)
                     * t2.D +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                             UNIX_TIMESTAMP(t1.MINEndDate)) / 86400), 2)
                     * t2.C +
                   ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
                       UNIX_TIMESTAMP(t1.MINEndDate)) / 86400 * t2.B
                   + t2.A
        end,
       case ABS(t1.PreferredQuantity - t1.MINQuantity) >
            ABS(t1.PreferredQuantity - t1.MAXQuantity)
       when 0 then POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                            UNIX_TIMESTAMP(t1.MAXQuantity)) / 86400), 4)
                      * t2.E +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                            UNIX_TIMESTAMP(t1.MAXQuantity)) / 86400), 3)
                      * t2.D +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                            UNIX_TIMESTAMP(t1.MAXQuantity)) / 86400), 2)
                      * t2.C +
                   ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                       UNIX_TIMESTAMP(t1.MAXQuantity)) / 86400 * t2.B
                   + t2.A
              else POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                            UNIX_TIMESTAMP(t1.MINQuantity)) / 86400), 4)
                     * t2.E +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                            UNIX_TIMESTAMP(t1.MINQuantity)) / 86400), 3)
                     * t2.D +
                   POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                            UNIX_TIMESTAMP(t1.MINQuantity)) / 86400), 2)
                     * t2.C +
                   ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
                       UNIX_TIMESTAMP(t1.MINQuantity)) / 86400 * t2.B
                   + t2.A
       end
FROM Temp_Derived_Baseline t1, Scoring_Constants t2
WHERE t2.ID = 'Default';



DROP TABLE IF EXISTS Derived_ScoredStress;
CREATE TABLE Derived_ScoredStress (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  AgentID               varchar(127) NOT NULL default '',
  Verb                  varchar(127) NOT NULL default '',
  NSNNumber             varchar(127)          default NULL,
  FromLocation          varchar(127)          default NULL,
  ToLocation            varchar(127)          default NULL,
  PreferredQuantity     double                default NULL,
  PreferredStartDate    datetime              default NULL,
  PreferredEndDate      datetime              default NULL,
  EstimatedQuantity     double                default NULL,
  EstimatedStartDate    datetime              default NULL,
  EstimatedEndDate      datetime              default NULL,
  ScoreStartDate        double                default NULL,
  ScoreEndDate          double                default NULL,
  ScoreQuantity         double                default NULL
) TYPE=MyISAM;


INSERT INTO Derived_ScoredStress

SELECT t1.RunID, t1.TaskUID, t1.AgentID, t1.Verb, t1.NSNNumber,
       t1.FromLocation, t1.ToLocation, t1.PreferredQuantity,
       t1.PreferredStartDate, t1.PreferredEndDate,
       t1.EstimatedQuantity, t1.EstimatedStartDate, EstimatedEndDate,
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
           UNIX_TIMESTAMP(t1.EstimatedStartDate)) / 86400), 4) * t3.E +
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
           UNIX_TIMESTAMP(t1.EstimatedStartDate)) / 86400), 3) * t3.D +
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
           UNIX_TIMESTAMP(t1.EstimatedStartDate)) / 86400), 2) * t3.C +
       ABS(UNIX_TIMESTAMP(t1.PreferredStartDate) -
           UNIX_TIMESTAMP(t1.EstimatedStartDate)) / 86400 * t3.B
       + t3.A,
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
           UNIX_TIMESTAMP(t1.EstimatedEndDate)) / 86400), 4) * t3.E +
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
           UNIX_TIMESTAMP(t1.EstimatedEndDate)) / 86400), 3) * t3.D +
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
           UNIX_TIMESTAMP(t1.EstimatedEndDate)) / 86400), 2) * t3.C +
       ABS(UNIX_TIMESTAMP(t1.PreferredEndDate) -
           UNIX_TIMESTAMP(t1.EstimatedEndDate)) / 86400 * t3.B
       + t3.A,
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
           UNIX_TIMESTAMP(t1.EstimatedQuantity)) / 86400), 4) * t3.E +
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
           UNIX_TIMESTAMP(t1.EstimatedQuantity)) / 86400), 3) * t3.D +
       POW((ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
           UNIX_TIMESTAMP(t1.EstimatedQuantity)) / 86400), 2) * t3.C +
       ABS(UNIX_TIMESTAMP(t1.PreferredQuantity) -
           UNIX_TIMESTAMP(t1.EstimatedQuantity)) / 86400 * t3.B
       + t3.A
FROM Derived_RelevantTasks t1, TempRun t2, Scoring_Constants t3
WHERE t1.RunID = t2.VALUE
  AND t2.ID = 'Stress'
  AND t3.ID = 'Default';


DROP TABLE IF EXISTS Derived_Completion;
CREATE TABLE Derived_Completion (
  RunID                 int(11)      NOT NULL default '0',
  TaskUID               varchar(127) NOT NULL default '',
  AgentID               varchar(127) NOT NULL default '',
  Verb                  varchar(127) NOT NULL default '',
  NSNNumber             varchar(127)          default NULL,
  ToLocation            varchar(127)          default NULL,
  PreferredEndDate      datetime              default NULL,
  ScoreStartDate        double                default NULL,
  ScoreEndDate          double                default NULL,
  ScoreQuantity         double                default NULL,
  IsCCStartDate        int(3)                default NULL,
  IsCCEndDate          int(3)                default NULL,
  IsCCQuantity         int(3)                default NULL
) TYPE=MyISAM;


INSERT INTO Derived_Completion
SELECT DISTINCT t1.RunID, t1.TaskUID, t1.AgentID, t1.Verb,
                t1.NSNNumber, t1.ToLocation,
                t1.PreferredEndDate,
                t1.ScoreStartDate, t1.ScoreEndDate, t1.ScoreQuantity,
                case t1.ScoreStartDate > t2.ScoreStartDate
                when 1 then 0
                when 0 then 1
                when NULL then NULL
                else        NULL
                end,
                case t1.ScoreEndDate > t2.ScoreEndDate
                when 1 then 0
                when 0 then 1
                when NULL then NULL
                else           NULL
                end,
                case t1.ScoreQuantity > t2.ScoreQuantity
                when 1 then 0
                when 0 then 1
                when NULL then NULL
                else           NULL
                end
FROM Derived_ScoredStress t1, Derived_Baseline t2
WHERE     t1.AgentID          = t2.AgentID
      AND t1.Verb             = t2.Verb
      AND t1.NSNNumber        = t2.NSNNumber
      AND t1.ToLocation       = t2.ToLocation
      AND t1.PreferredEndDate = t2.PreferredEndDate
     ;

UPDATE Derived_Completion
SET IsCCStartDate = NULL
WHERE ISNULL(ScoreStartDate);

UPDATE Derived_Completion
SET IsCCEndDate = NULL
WHERE ISNULL(ScoreEndDate);

UPDATE Derived_Completion
SET IsCCQuantity = NULL
WHERE ISNULL(ScoreQuantity);

DROP TABLE IF EXISTS Temporary;
CREATE TABLE Temporary (
  ID                    int(11)      NOT NULL  default '1',
  NAME                  varchar(255)           default NULL,
  VALUE                 int(11)                default '0'
) TYPE=MyISAM;

INSERT INTO Temporary
SELECT 1, 'Total Scores', 2 * COUNT(*)
FROM Derived_Completion
;

INSERT INTO Temporary
SELECT 2, 'Total Suppky Task Scores', 2 * COUNT(*)
FROM Derived_Completion
WHERE VERB = 'Supply' OR VERB = 'ProjectSupply';

INSERT INTO Temporary
SELECT 3, 'Total Transport Task Scores', 2 * COUNT(*)
FROM Derived_Completion
WHERE VERB = 'Transport';
;

INSERT INTO Temporary
SELECT 4, 'Incomplete, No End Scores', COUNT(*)
FROM Derived_Completion
WHERE ISNULL(IsCCEndDate);

INSERT INTO Temporary
SELECT 5, 'Incomplete, No End Scores For Supply Tasks', COUNT(*)
FROM Derived_Completion
WHERE ISNULL(IsCCEndDate)
  AND VERB = 'Supply' OR VERB = 'ProjectSupply';

INSERT INTO Temporary
SELECT 6, 'Incomplete, No End Scores for Transport Tasks', COUNT(*)
FROM Derived_Completion
WHERE ISNULL(IsCCEndDate)
  AND VERB = 'Transport';


INSERT INTO Temporary
SELECT 7, 'Incomplete, No Quantity Scores', COUNT(*)
FROM Derived_Completion
WHERE (VERB = 'Supply' OR VERB = 'ProjectSupply')
  AND ISNULL(IsCCQuantity);

INSERT INTO Temporary
SELECT 8, 'Incomplete, No Start Scores', COUNT(*)
FROM Derived_Completion
WHERE VERB = 'Transport'
  AND ISNULL(IsCCStartDate)
;

INSERT INTO Temporary
SELECT 9, 'Incorrect end date', COUNT(*)
FROM Derived_Completion
WHERE IsCCEndDate = '0';

INSERT INTO Temporary
SELECT 10, 'Incorrect End Date for Supply Tasks', COUNT(*)
FROM Derived_Completion
WHERE IsCCEndDate = '0'
 AND Verb = 'Supply' OR VERB = 'ProjectSupply';

INSERT INTO Temporary
SELECT 11, 'Incorrect End Date for Transport Tasks', COUNT(*)
FROM Derived_Completion
WHERE IsCCEndDate = '0'
  AND Verb = 'Transport';

INSERT INTO Temporary
SELECT 12, 'Incorrect Quantity ', COUNT(*)
FROM Derived_Completion
WHERE (VERB = 'Supply' OR VERB = 'ProjectSupply')
  AND IsCCQuantity = '0'
;

INSERT INTO Temporary
SELECT 13, 'Incorrect Start Date', COUNT(*)
FROM Derived_Completion
WHERE VERB = 'Transport'
  AND IsCCStartDate = '0'
;

DROP TABLE IF EXISTS Results;
CREATE TABLE Results (
  NAME                  varchar(255)           default NULL,
  SupplyVALUE           double                default '0.0',
  TransportVALUE        double                default '0.0',
  VALUE                 double                default '0.0'
) TYPE=MyISAM;

INSERT INTO Results
SELECT 'Completeness',
      (t1.VALUE - t2.VALUE -t3.VALUE)/t1.VALUE * 100,
      (t4.VALUE - t5.VALUE -t6.VALUE)/t4.VALUE * 100,
      (t7.VALUE - t8.VALUE -t9.VALUE -t10.VALUE)/t7.VALUE * 100
FROM Temporary t1, Temporary t2, Temporary t3, Temporary t4,
     Temporary t5, Temporary t6, Temporary t7, Temporary t8,
     Temporary t9, Temporary t10
Where t1.ID  = '2'
  AND t2.ID  = '5'
  AND t3.ID  = '7'
  AND t4.ID  = '3'
  AND t5.ID  = '6'
  AND t6.ID  = '8'
  AND t7.ID  = '1'
  AND t8.ID  = '4'
  AND t9.ID  = '7'
  AND t10.ID = '8'
;

INSERT INTO Results
SELECT 'Correctness',
      (t1.VALUE - t2.VALUE -t3.VALUE -t11.VALUE -t12.VALUE)/(t1.VALUE -t11.VALUE -t12.VALUE) * 100,
      (t4.VALUE - t5.VALUE -t6.VALUE -t13.VALUE -t14.VALUE)/(t4.VALUE -t13.VALUE -t14.VALUE)* 100,
      (t7.VALUE - t8.VALUE -t9.VALUE -t10.VALUE -t15.VALUE -t16.VALUE -t17.VALUE)/(t7.VALUE -t15.VALUE -t16.VALUE -t17.VALUE) * 100
FROM Temporary t1, Temporary t2, Temporary t3, Temporary t4,
     Temporary t5, Temporary t6, Temporary t7, Temporary t8,
     Temporary t9, Temporary t10, Temporary t11, Temporary t12,
     Temporary t13, Temporary t14, Temporary t15, Temporary t16,
     Temporary t17
Where t1.ID  = '2'
  AND t2.ID  = '10'
  AND t3.ID  = '12'
  AND t4.ID  = '3'
  AND t5.ID  = '11'
  AND t6.ID  = '13'
  AND t7.ID  = '1'
  AND t8.ID  = '9'
  AND t9.ID  = '12'
  AND t10.ID = '13'
  AND t11.ID = '5'
  AND t12.ID = '7'
  AND t13.ID = '6'
  AND t14.ID = '8'
  AND t15.ID = '4'
  AND t16.ID = '7'
  AND t17.ID = '8'
;

SELECt *
FROM Results;

EOF
  ;

}

# DROP TABLE IF EXISTS Derived_Relationships;
# CREATE TABLE Derived_Relationships (
#   RunID                 int(11)      NOT NULL default '0',
#   AgentID               varchar(127) NOT NULL default '',
#   TaskUID               varchar(127) NOT NULL default '',
#   Verb                  varchar(127) NOT NULL default '',
#   ParentUID             varchar(127)          default NULL,
#   ParentVerb            varchar(127)          default NULL,
#   DirectObjectID        varchar(127)          default NULL,
#   NSNNumber             varchar(127)          default NULL,
#   PreferredStartDate    datetime              default NULL,
#   PreferredEndDate      datetime              default NULL,
#   PreferredQuantity     double                default NULL,
#   OrgID                 varchar(127)          default NULL,
#   FromLocation          varchar(127)          default NULL,
#   ToLocation            varchar(127)          default NULL,
#   PlanElementID         varchar(127)          default NULL,
#   PEType                varchar(127)          default NULL,
#   ParentPEID            varchar(127)          default NULL,
#   ParentPEType          varchar(127)          default NULL,
#   EstimatedStartDate    datetime              default NULL,
#   EstimatedEndDate      datetime              default NULL,
#   EstimatedQuantity     double                default NULL,
#   UNIQUE KEY            ix_task               (RunID, AgentID, TaskUID),
#   KEY                   ix_parentid           (ParentUID)
# ) TYPE=MyISAM;

# INSERT INTO Derived_Relationships
# SELECT t1.RunID, t1.AgentID, t1.TaskUID, t1.Verb, t1.ParentUID, t2.Verb,
#        t1.DirectObjectID, t1.NSNNumber, t1.PreferredStartDate,
#        t1.PreferredEndDate, t1.PreferredQuantity, t1.OrgID,
#        t1.FromLocation, t1.ToLocation, t1.PlanElementID, t1.PEType,
#        t2.PlanElementID, t2.PEType, t1.EstimatedStartDate,
#        t1.EstimatedEndDate, t1.EstimatedQuantity
# FROM tasks t1, tasks t2
# WHERE t1.ParentUID = t2.TaskUID;

# DROP TABLE IF EXISTS Derived_DemandGeneration;
# CREATE TABLE Derived_DemandGeneration (
#   AgentID               varchar(127) NOT NULL default '',
#   TaskUID               varchar(127) NOT NULL default '',
#   Verb                  varchar(127) NOT NULL default '',
#   DirectObjectID        varchar(127)          default NULL,
#   NSNNumber             varchar(127)          default NULL,
#   FromLocation          varchar(127)          default NULL,
#   ToLocation            varchar(127)          default NULL,
#   PreferredQuantity     double                default NULL,
#   PreferredStartDate    datetime              default NULL,
#   PreferredEndDate      datetime              default NULL,
#   UNIQUE KEY            ix_task               (AgentID, TaskUID)
# ) TYPE=MyISAM;


# INSERT INTO Derived_DemandGeneration
# SELECT t1.AgentID, t1.TaskUID, t1.Verb, t1.DirectObjectID,
#        t1.NSNNumber, t1.FromLocation, t1.ToLocation,
#        t1.PreferredQuantity, t1.PreferredStartDate,
#        t1.PreferredEndDate
# FROM Derived_RelevantTasks t1, TempRun t2
# WHERE t1.RunID = t2.VALUE
#   AND t2.ID = 'LOW_BASE';





# INSERT INTO Temp_Derived_Baseline (
#   AgentID, Verb, NSNNumber, FromLocation, ToLocation, ForAgent,
#   PreferredStartDate, PreferredEndDate,
#   MINStartDate, MAXStartDate, MINEndDate, MAXEndDate)
# SELECT task.Agent as AgentID, task.Verb, typepg.typeId as NSNNumber,
#        prepositions_1.val as FromLocation, prepositions_2.val as ToLocation,
#        prepositions_3.val as ForAgent,
#        preferences_1.bestvalue as PreferredStartDate,
#        preferences_2.bestvalue as PreferredEndDate,
#        min(aspect_val_1.value) as MINStartDate,
#        max(aspect_val_1.value) as MAXStartDate,
#        min(aspect_val_2.value) as MINEndDate,
#        max(aspect_val_2.value) as MAXEndDate
# FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
#       Derived_RelevantAssets assets, Derived_RelevantTypePG typepg,
#       Derived_RelevantPrepositions prepositions_1,
#       Derived_RelevantPrepositions prepositions_2,
#       Derived_RelevantPrepositions prepositions_3,
#       Derived_RelevantPreferences  preferences_1,
#       Derived_RelevantPreferences  preferences_2,
#       Derived_Relevant_AllocResults Alloc_result,
#       Temp_Aspects aspect_val_1,
#       Temp_Aspects aspect_val_2
# WHERE task.verb = 'Transport'
#   AND task.runid BETWEEN TRun1.VALUE AND TRun2.VALUE
#   AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
#   AND assets.id = task.asset_id AND assets.typepg_id = typepg.id
#   AND prepositions_1.task_id = task.TaskUID AND prepositions_1.prep = 'From'
#   AND prepositions_2.task_id = task.TaskUID AND prepositions_2.prep = 'To'
#   AND prepositions_3.task_id = task.TaskUID AND prepositions_3.prep = 'For'
#   AND preferences_1.task_id = task.TaskUID
#   AND preferences_1.aspecttype = 'START_TIME'
#   AND preferences_2.task_id = task.TaskUID
#   AND preferences_2.aspecttype = 'END_TIME'
#   AND Alloc_result.pe_id = task.pe_id AND Alloc_result.type = 'ESTIMATED'
#   AND aspect_val_1.ar_id = Alloc_result.id
#   AND aspect_val_1.aspecttype = 'START_TIME'
#   AND aspect_val_2.ar_id = Alloc_result.id
#   AND aspect_val_2.aspecttype = 'END_TIME'
# GROUP BY AgentID, Verb, NSNNumber, FromLocation, ToLocation,
#          ForAgent, PreferredStartDate,  PreferredEndDate;


# INSERT INTO Temp_Derived_Baseline (
#   AgentID, Verb, NSNNumber, ToLocation, ForAgent,
#   PreferredQuantity, PreferredEndDate,
#   MINEndDate, MAXEndDate, MINQuantity, MAXQuantity)
# SELECT task.Agent as AgentID, task.Verb, typepg.typeId as NSNNumber,
#        prepositions_1.val as ToLocation,
#        prepositions_2.val as ForAgent,
#        preferences_1.bestvalue as PreferredQuantity,
#        preferences_2.bestvalue as PreferredEndDate,
#        min(aspect_val_1.value) as MINEndDate,
#        max(aspect_val_1.value) as MAXEndDate,
#        min(aspect_val_2.value) as MINQuantity,
#        max(aspect_val_2.value) as MAXQuantity
# FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
#       Derived_RelevantAssets assets, Derived_RelevantTypePG typepg,
#       Derived_RelevantPrepositions prepositions_1,
#       Derived_RelevantPrepositions prepositions_2,
#       Derived_RelevantPreferences  preferences_1,
#       Derived_RelevantPreferences  preferences_2,
#       Derived_Relevant_AllocResults Alloc_result,
#       Temp_Aspects aspect_val_1,
#       Temp_Aspects aspect_val_2
# WHERE task.verb = 'Supply'
#   AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
#   AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
#   AND assets.id = task.asset_id  AND typepg.id = assets.itempg_id
#   AND preferences_1.task_id = task.TaskUID
#   AND preferences_1.aspecttype = 'QUANTITY'
#   AND preferences_2.task_id = task.TaskUID
#   AND preferences_2.aspecttype = 'END_TIME'
#   AND prepositions_1.task_id = task.TaskUID AND prepositions_1.prep = 'To'
#   AND prepositions_2.task_id = task.TaskUID AND prepositions_2.prep = 'For'
#   AND Alloc_result.pe_id = task.pe_id AND Alloc_result.type = 'ESTIMATED'
#   AND aspect_val_1.ar_id = Alloc_result.id
#   AND aspect_val_1.aspecttype = 'START_TIME'
#   AND aspect_val_2.ar_id = Alloc_result.id
#   AND aspect_val_2.aspecttype = 'QUANTITY'
# GROUP BY AgentID, Verb, NSNNumber, ToLocation, ForAgent, PreferredEndDate, 
#          PreferredQuantity;



# INSERT INTO Temp_Derived_Baseline (
#   AgentID, Verb, NSNNumber, ToLocation, ForAgent,  PreferredStartDate,
#   PreferredEndDate, MINStartDate, MAXStartDate, MINEndDate, MAXEndDate)
# SELECT task.Agent as AgentID, task.Verb, typepg.typeId as NSNNumber,
#        prepositions_1.val as ToLocation,
#        prepositions_2.val as ForAgent,
#        preferences_1.bestvalue as PreferredStartDate,
#        preferences_2.bestvalue as PreferredEndDate,
#        min(aspect_val_1.value) as MINStartDate,
#        max(aspect_val_1.value) as MAXStartDate,
#        min(aspect_val_2.value) as MINEndDate,
#        max(aspect_val_2.value) as MAXEndDate
# FROM  Derived_RelevantTasks task, TempRun TRun1, TempRun TRun2,
#       Derived_RelevantAssets assets, Derived_RelevantTypePG typepg,
#       Derived_RelevantPrepositions prepositions_1,
#       Derived_RelevantPrepositions prepositions_2,
#       Derived_RelevantPreferences  preferences_1,
#       Derived_RelevantPreferences  preferences_2,
#       Derived_Relevant_AllocResults Alloc_result,
#       Temp_Aspects aspect_val_1,
#       Temp_Aspects aspect_val_2
# WHERE task.verb = 'ProjectSupply'
#   AND task.RunID BETWEEN TRun1.VALUE AND TRun2.VALUE
#   AND TRun1.ID = 'LOW_BASE' AND TRun2.ID = 'HIGH_BASE'
#   AND assets.id = task.asset_id  AND typepg.id = assets.typepg_id
#   AND prepositions_1.task_id = task.TaskUID AND prepositions_1.prep = 'To'
#   AND prepositions_2.task_id = task.TaskUID AND prepositions_2.prep = 'For'
#   AND preferences_1.task_id = task.TaskUID
#   AND preferences_1.aspecttype = 'START_TIME'
#   AND preferences_2.task_id = task.TaskUID
#   AND preferences_2.aspecttype = 'END_TIME'
#   AND Alloc_result.pe_id = task.pe_id AND Alloc_result.type = 'ESTIMATED'
#   AND aspect_val_1.ar_id = Alloc_result.id
#   AND aspect_val_2.ar_id = Alloc_result.id
#   AND aspect_val_1.aspecttype = 'START_TIME'
#   AND aspect_val_2.aspecttype = 'END_TIME'
# GROUP BY AgentID, Verb, NSNNumber, ToLocation, ForAgent, PreferredStartDate,
#          PreferredEndDate
# ;



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
