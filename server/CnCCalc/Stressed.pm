#                              -*- Mode: Perl -*-
# Stressed.pm ---
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com )
# Created On       : Wed Apr  2 08:35:51 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Nov 19 18:55:41 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 40
# Status           : Unknown, Use with caution!
# HISTORY          :
# Description      :
#
#

package CnCCalc::Stressed;

use strict;
use DBI;
{
  my %Stressed =
    (
     'Clean' => [qw(T_XXX_Rslt Temp_XXX_OP Temp_XXX  T_XXX_Phased )],
     'Tables' =>
     {
      #"00_drop_Temp_XXX_OP" => qq(DROP TABLE Temp_XXX_OP ;),
      "01_Temp_XXX_OP" => qq(
CREATE __TEMP__ TABLE Temp_XXX_OP (
  run_id                bigint  NOT NULL,
  task_id               varchar(63) NOT NULL,
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  ClassName             varchar(255)         default NULL,
  SupplyClass           varchar(63)          default NULL,
  SupplyType            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Preferred_Rate        double precision              default NULL,
  Scoring_Fn_Quantity   varchar(255)         default NULL,
  Scoring_Fn_Start_Date varchar(255)         default NULL,
  Scoring_Fn_End_Date   varchar(255)         default NULL,
  Scoring_Fn_Rate       varchar(255)         default NULL,
  Pref_Score_Quantity   double precision                default NULL,
  Pref_Score_Start_Date double precision              default NULL,
  Pref_Score_End_Date   double precision                default NULL,
  Pref_Score_Rate       double precision                default NULL
);
),


      "02_insert_Temp_XXX_OP" => qq(
INSERT INTO Temp_XXX_OP (run_id, task_id, Agent, Verb, NSN_Number,
	                ClassName, SupplyClass,
                         SupplyType, From_Location, To_Location,
                         Preferred_Start_Date, Preferred_End_Date,
                         Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                         Pref_Score_Start_Date, Pref_Score_End_Date)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prepositions.From_Location, prepositions.To_Location,
       preferences.Preferred_Start_Date,
       preferences.Preferred_End_Date,
       preferences.Scoring_Fn_Start_Date,
       preferences.Scoring_Fn_End_Date, preferences.Pref_Score_Start_Date,
       preferences.Pref_Score_End_Date
FROM tasks, preferences, prepositions, assets
WHERE tasks.run_id = XXX
  AND tasks.verb              = 'Transport'
  AND preferences.run_id            = tasks.run_id
  AND preferences.task_id           = tasks.id
  AND prepositions.task_id          = tasks.id
  AND prepositions.run_id           = tasks.run_id
  AND assets.run_id           = tasks.run_id
  AND assets.task_id          = tasks.id;
),

      "03_insert_Temp_Stressed_OP" => qq(
INSERT INTO Temp_XXX_OP (run_id, task_id, Agent, Verb, NSN_Number,
                              ClassName, SupplyClass, SupplyType,
                              For_Organization, To_Location,
                              Maintain_Type, Maintain_TypeID,
                              Maintain_ItemID, Maintain_Nomenclature,
                              Preferred_Quantity, Preferred_End_Date,
                              Scoring_Fn_Quantity,
                              Scoring_Fn_End_Date,
                              Pref_Score_Quantity,
                              Pref_Score_End_Date)
SELECT DISTINCT
       tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType, 
       prepositions.For_Organization, prepositions.To_Location,
       prepositions.Maintain_Type,
       prepositions.Maintain_TypeID,
       prepositions.Maintain_ItemID,
       prepositions.Maintain_Nomenclature,
       preferences.Preferred_Quantity,
       preferences.Preferred_End_Date,
       preferences.Scoring_Fn_Quantity,
       preferences.Scoring_Fn_End_Date, preferences.Pref_Score_Quantity,
       preferences.Pref_Score_End_Date
FROM tasks, preferences, prepositions, assets
WHERE tasks.run_id = XXX
  AND tasks.verb       = 'Supply'
  AND prepositions.run_id           = tasks.run_id
  AND prepositions.task_id          = tasks.id
  AND preferences.run_id     = tasks.run_id
  AND preferences.task_id    = tasks.id
  AND assets.run_id    = tasks.run_id
  AND assets.task_id   = tasks.id;
),

      "04_insert_Temp_Stressed_O" => qq(
INSERT INTO Temp_XXX_OP (run_id, task_id, Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType,
                           For_Organization, To_Location,
                           Maintain_Type, Maintain_TypeID,
                           Maintain_ItemID, Maintain_Nomenclature,
                           Preferred_Start_Date, Preferred_End_Date,
                           Preferred_Rate, Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Scoring_Fn_Rate,
                           Pref_Score_Start_Date, Pref_Score_End_Date,
                           Pref_Score_Rate)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prepositions.For_Organization, prepositions.To_Location,
       prepositions.Maintain_Type,
       prepositions.Maintain_TypeID,
       prepositions.Maintain_ItemID,
       prepositions.Maintain_Nomenclature,
       preferences.Preferred_Start_Date,
       preferences.Preferred_End_Date, preferences.Preferred_Rate,
       preferences.Scoring_Fn_Start_Date,
       preferences.Scoring_Fn_End_Date,
       preferences.Scoring_Fn_Rate,
       preferences.Pref_Score_Start_Date, preferences.Pref_Score_End_Date,
       preferences.Pref_Score_Rate
FROM tasks, preferences, prepositions, assets
WHERE tasks.run_id = XXX
  AND tasks.verb       = 'ProjectSupply'
  AND prepositions.run_id           = tasks.run_id
  AND prepositions.task_id          = tasks.id
  AND preferences.run_id     = tasks.run_id
  AND preferences.task_id    = tasks.id
  AND assets.run_id    = tasks.run_id
  AND assets.task_id   = tasks.id;
),

      "05_update_ops" => qq(
UPDATE Temp_XXX_OP
SET Maintain_ItemID = '----NULL----'
WHERE NOT Maintain_Type    IS NULL
  AND     Maintain_ItemID  IS NULL;
;),

      #"05_drop_Temp_XXX_Results" => qq(DROP TABLE T_XXX_Rslt ;),
      "06_Temp_XXX_Rslt" => qq(
 CREATE __TEMP__ TABLE T_XXX_Rslt  (
  run_id                bigint  NOT NULL,
  task_id               varchar(63) NOT NULL,
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  Quantity          double precision                default NULL,
  Start_Date        double precision              default NULL,
  End_Date          double precision              default NULL,
  Rate              double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL
);
),



      "07_Insert_Temp_Stressed_Results" => qq(
INSERT INTO T_XXX_Rslt  (run_id, task_id, Agent, Verb,
                                   Start_Date, End_Date,
                                   Score_Start_Date, Score_End_Date,
                                   Phased, Phase_no, Confidence, Success)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       phval1.value as Start_Date, phval2.value as End_Date,
       phval1.score as Score_Start_Date,
       phval2.score as Score_End_Date,
       allocation_results.Phased, phval1.phase_no,
       allocation_results.confidence,  allocation_results.Success
FROM tasks, allocation_results,
     phased_aspects phval1, phased_aspects phval2
WHERE tasks.run_id = XXX
  AND tasks.verb               = 'Transport'
  AND tasks.run_id             = allocation_results.run_id
  AND tasks.id                 = allocation_results.task_id
  AND tasks.run_id             = phval1.run_id
  AND tasks.id                 = phval1.task_id
  AND tasks.run_id             = phval2.run_id
  AND tasks.id                 = phval2.task_id
  AND phval1.phase_no          = phval2.phase_no
  AND phval1.aspecttype        = 'START_TIME'
  AND phval2.aspecttype        = 'END_TIME';
),

      "08_Insert_Temp_Stressed_Results" => qq(
INSERT INTO T_XXX_Rslt  (run_id, task_id, Agent, Verb,
                                   Quantity, End_Date, Score_Quantity,
                                   Score_End_Date, Phased, Phase_no,
                                   Confidence, Success)
SELECT DISTINCT
       tasks.run_id,
       tasks.id,
       tasks.agent,
       tasks.Verb,
       phval1.value as Quantity,
       phval2.value as End_Date,
       phval1.score as Score_Quantity,
       phval2.score as Score_End_Date,
       allocation_results.Phased,
       phval1.phase_no,
       allocation_results.confidence,
       allocation_results.Success
FROM tasks, allocation_results,
     phased_aspects phval1, phased_aspects phval2
WHERE tasks.run_id = XXX
  AND tasks.verb       = 'Supply'
  AND tasks.run_id             = allocation_results.run_id
  AND tasks.id                 = allocation_results.task_id
  AND tasks.run_id             = phval1.run_id
  AND tasks.id                 = phval1.task_id
  AND tasks.run_id             = phval2.run_id
  AND tasks.id                 = phval2.task_id
  AND phval1.phase_no          = phval2.phase_no
  AND phval1.aspecttype        = 'QUANTITY'
  AND phval2.aspecttype        = 'END_TIME';
),

      "09_Insert_Temp_Stressed_Results" => qq(
INSERT INTO T_XXX_Rslt  (run_id, task_id, Agent, Verb,
                                   Start_Date, End_Date, Rate,
                                   Score_Start_Date, Score_End_Date,
                                   Score_Rate, Phased, Phase_no, Confidence,
                                   Success)
SELECT tasks.run_id,
       tasks.id,
       tasks.agent,
       tasks.Verb,
       phval1.value as Start_Date,
       phval2.value as End_Date,
       phval3.value as Rate,
       phval1.score as Score_Start_Date,
       phval2.score as Score_End_Date,
       phval3.score as Score_Rate,
       allocation_results.Phased,
       phval1.phase_no,
       allocation_results.confidence,
       allocation_results.Success
FROM tasks, allocation_results,
     phased_aspects phval1, phased_aspects phval2,
     phased_aspects phval3
WHERE tasks.run_id = XXX
  AND tasks.verb       = 'ProjectSupply'
  AND tasks.run_id             = allocation_results.run_id
  AND tasks.id                 = allocation_results.task_id
  AND tasks.run_id             = phval1.run_id
  AND tasks.id                 = phval1.task_id
  AND tasks.run_id             = phval2.run_id
  AND tasks.id                 = phval2.task_id
  AND tasks.run_id             = phval3.run_id
  AND tasks.id                 = phval3.task_id
  AND phval1.phase_no          = phval2.phase_no
  AND phval1.phase_no          = phval3.phase_no
  AND phval1.aspecttype        = 'START_TIME'
  AND phval2.aspecttype        = 'END_TIME'
  AND phval3.aspecttype        = '15';
),

      #"10_drop_T_XXX_Phased" => qq(DROP TABLE T_XXX_Phased;),
      "11_T_XXX_Phased" => qq(
 CREATE __TEMP__ TABLE T_XXX_Phased (
  run_id                bigint  NOT NULL,
  task_id               varchar(63) NOT NULL,
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  ClassName             varchar(255)         default NULL,
  SupplyClass           varchar(63)          default NULL,
  SupplyType            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Preferred_Rate        double precision              default NULL,
  Scoring_Fn_Quantity   varchar(255)         default NULL,
  Scoring_Fn_Start_Date varchar(255)         default NULL,
  Scoring_Fn_End_Date   varchar(255)         default NULL,
  Scoring_Fn_Rate       varchar(255)         default NULL,
  Pref_Score_Quantity   double precision                default NULL,
  Pref_Score_Start_Date double precision              default NULL,
  Pref_Score_End_Date   double precision                default NULL,
  Pref_Score_Rate       double precision                default NULL,
  Quantity          double precision                default NULL,
  Start_Date        double precision              default NULL,
  End_Date          double precision              default NULL,
  Rate              double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL
);
),


      "12_Insert_Temp_Temp_Stressed_Phased" => qq(
INSERT INTO T_XXX_Phased (run_id, task_id, Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType,
                           From_Location, To_Location,
                           Preferred_Start_Date,
                           Preferred_End_Date, Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Start_Date, End_Date,
                           Phased, Phase_no, Confidence, Success,
		        Score_Start_Date, Score_End_Date)
SELECT Temp_XXX_OP.run_id, Temp_XXX_OP.task_id,
       Temp_XXX_OP.agent, Temp_XXX_OP.Verb,
       Temp_XXX_OP.NSN_Number,
       Temp_XXX_OP.ClassName,
       Temp_XXX_OP.SupplyClass,
       Temp_XXX_OP.SupplyType,
       Temp_XXX_OP.From_Location,
       Temp_XXX_OP.To_Location,
       Temp_XXX_OP.Preferred_Start_Date,
       Temp_XXX_OP.Preferred_End_Date,
       Temp_XXX_OP.Scoring_Fn_Start_Date,
       Temp_XXX_OP.Scoring_Fn_End_Date,
       Temp_XXX_OP.Pref_Score_Start_Date,
       Temp_XXX_OP.Pref_Score_End_Date,
       T_XXX_Rslt.Start_Date,
       T_XXX_Rslt.End_Date,
       T_XXX_Rslt.Phased,
       T_XXX_Rslt.phase_no,
       T_XXX_Rslt.Confidence,
       T_XXX_Rslt.Success,
       T_XXX_Rslt.Score_Start_Date,
       T_XXX_Rslt.Score_End_Date
FROM Temp_XXX_OP FULL OUTER JOIN T_XXX_Rslt 
       ON (Temp_XXX_OP.task_id = T_XXX_Rslt .task_id AND
           Temp_XXX_OP.run_id  = T_XXX_Rslt .run_id)
WHERE Temp_XXX_OP.verb         = 'Transport';
),

      "13_Insert_T_XXX_Phased" => qq(
INSERT INTO T_XXX_Phased (run_id, task_id, Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType,
                           For_Organization, To_Location,
                           Maintain_Type, Maintain_TypeID,
                           Maintain_ItemID, Maintain_Nomenclature,
                           Preferred_Quantity, Preferred_End_Date,
                           Scoring_Fn_Quantity, Scoring_Fn_End_Date,
                           Pref_Score_Quantity, Pref_Score_End_Date,
                           Quantity, End_Date, Phased, Phase_no, Confidence,
                           Success, Score_Quantity, Score_End_Date)
SELECT DISTINCT
       Temp_XXX_OP.run_id, Temp_XXX_OP.task_id,
       Temp_XXX_OP.Agent, Temp_XXX_OP.Verb,
       Temp_XXX_OP.NSN_Number,
       Temp_XXX_OP.ClassName,
       Temp_XXX_OP.SupplyClass,
       Temp_XXX_OP.SupplyType,
       Temp_XXX_OP.For_Organization,
       Temp_XXX_OP.To_Location,
       Temp_XXX_OP.Maintain_Type,
       Temp_XXX_OP.Maintain_TypeID,
       Temp_XXX_OP.Maintain_ItemID,
       Temp_XXX_OP.Maintain_Nomenclature,
       Temp_XXX_OP.Preferred_Quantity,
       Temp_XXX_OP.Preferred_End_Date,
       Temp_XXX_OP.Scoring_Fn_Quantity,
       Temp_XXX_OP.Scoring_Fn_End_Date,
       Temp_XXX_OP.Pref_Score_Quantity,
       Temp_XXX_OP.Pref_Score_End_Date,
       T_XXX_Rslt.Quantity,
       T_XXX_Rslt.End_Date,
       T_XXX_Rslt.Phased,
       T_XXX_Rslt.Phase_no,
       T_XXX_Rslt.Confidence,
       T_XXX_Rslt.Success,
       T_XXX_Rslt.Score_Quantity,
       T_XXX_Rslt.Score_End_Date
FROM Temp_XXX_OP FULL OUTER JOIN T_XXX_Rslt 
       ON (Temp_XXX_OP.task_id = T_XXX_Rslt .task_id AND
           Temp_XXX_OP.run_id  = T_XXX_Rslt .run_id)
WHERE Temp_XXX_OP.verb       = 'Supply';
),

      "14_Insert_Temp_Stressed_Phased" => qq(
INSERT INTO T_XXX_Phased (run_id, task_id, Agent, Verb, NSN_Number,
                          ClassName, SupplyClass, SupplyType,
                          For_Organization, To_Location,
                          Maintain_Type, Maintain_TypeID,
                          Maintain_ItemID, Maintain_Nomenclature,
                          Preferred_Start_Date, Preferred_End_Date,
                          Preferred_Rate, Scoring_Fn_Start_Date,
                          Scoring_Fn_End_Date, Scoring_Fn_Rate,
                          Pref_Score_Start_Date, Pref_Score_End_Date,
                          Pref_Score_Rate, Start_Date, End_Date, Rate,
                          Phased, Phase_no, Confidence, Success,
                          Score_Start_Date, Score_End_Date,
                          Score_Rate)
SELECT Temp_XXX_OP.run_id, Temp_XXX_OP.task_id,
       Temp_XXX_OP.Agent, Temp_XXX_OP.Verb,
       Temp_XXX_OP.NSN_Number,
       Temp_XXX_OP.ClassName,
       Temp_XXX_OP.SupplyClass,
       Temp_XXX_OP.SupplyType,
       Temp_XXX_OP.For_Organization,
       Temp_XXX_OP.To_Location,
       Temp_XXX_OP.Maintain_Type,
       Temp_XXX_OP.Maintain_TypeID,
       Temp_XXX_OP.Maintain_ItemID,
       Temp_XXX_OP.Maintain_Nomenclature,
       Temp_XXX_OP.Preferred_Start_Date,
       Temp_XXX_OP.Preferred_End_Date,
       Temp_XXX_OP.Preferred_Rate,
       Temp_XXX_OP.Scoring_Fn_Start_Date,
       Temp_XXX_OP.Scoring_Fn_End_Date,
       Temp_XXX_OP.Scoring_Fn_Rate,
       Temp_XXX_OP.Pref_Score_Start_Date,
       Temp_XXX_OP.Pref_Score_End_Date,
       Temp_XXX_OP.Pref_Score_Rate,
       T_XXX_Rslt.Start_Date,
       T_XXX_Rslt.End_Date,
       T_XXX_Rslt.Rate,
       T_XXX_Rslt.Phased,
       T_XXX_Rslt.Phase_no,
       T_XXX_Rslt.Confidence,
       T_XXX_Rslt.Success,
       T_XXX_Rslt.Score_Start_Date,
       T_XXX_Rslt.Score_End_Date,
       T_XXX_Rslt.Score_Rate
FROM Temp_XXX_OP  FULL OUTER JOIN T_XXX_Rslt 
       ON (Temp_XXX_OP.task_id = T_XXX_Rslt .task_id AND
           Temp_XXX_OP.run_id  = T_XXX_Rslt .run_id)
WHERE Temp_XXX_OP.verb       = 'ProjectSupply';
),

      #"15_drop_Temp_Stressed" => qq(DROP TABLE Temp_XXX;),
      "16_Temp_Stressed" => qq(CREATE __TEMP__ TABLE Temp_XXX (
  run_id                bigint  NOT NULL,
  task_id               varchar(63) NOT NULL,
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  ClassName             varchar(255)         default NULL,
  SupplyClass           varchar(63)          default NULL,
  SupplyType            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Preferred_Rate        double precision              default NULL,
  Scoring_Fn_Quantity   varchar(255)         default NULL,
  Scoring_Fn_Start_Date varchar(255)         default NULL,
  Scoring_Fn_End_Date   varchar(255)         default NULL,
  Scoring_Fn_Rate       varchar(255)         default NULL,
  Pref_Score_Quantity   double precision                default NULL,
  Pref_Score_Start_Date double precision              default NULL,
  Pref_Score_End_Date   double precision                default NULL,
  Pref_Score_Rate       double precision                default NULL,
  Quantity          double precision                default NULL,
  Start_Date        double precision              default NULL,
  End_Date          double precision              default NULL,
  Rate              double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL
);
),


      "17_Insert_Temp_Stressed" => qq(
INSERT INTO Temp_XXX (run_id, task_id, Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType,
                           From_Location, For_Organization,
                           To_Location, Maintain_Type,
                           Maintain_TypeID, Maintain_ItemID,
                           Maintain_Nomenclature, Preferred_Quantity,
                           Preferred_Start_Date, Preferred_End_Date,
                           Preferred_Rate, Scoring_Fn_Quantity,
                           Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                           Scoring_Fn_Rate, Pref_Score_Quantity,
                           Pref_Score_Start_Date, Pref_Score_End_Date,
                           Pref_Score_Rate, Phased, Phase_no, Confidence,
                           Success, Quantity, Start_Date, End_Date,
                           Rate, Score_Quantity, Score_Start_Date,
                           Score_End_Date, Score_Rate)
SELECT run_id, task_id, Agent, Verb, NSN_Number,
       ClassName, SupplyClass, SupplyType, From_Location,
       For_Organization, To_Location, Maintain_Type,
       Maintain_TypeID, Maintain_ItemID, Maintain_Nomenclature,
       Preferred_Quantity, Preferred_Start_Date, Preferred_End_Date,
       Preferred_Rate, Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
       Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
       Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
       Phased, Phase_no, Confidence, Success, Quantity, Start_Date, End_Date,
       Rate, Score_Quantity, Score_Start_Date, Score_End_Date,
       Score_Rate
From T_XXX_Phased
WHERE Phased = 0;
),



      "18_Insert_Temp_Stressed" => qq(
INSERT INTO Temp_XXX (run_id, task_id, Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType,
                           For_Organization, To_Location,
                           Maintain_Type, Maintain_TypeID,
                           Maintain_ItemID, Maintain_Nomenclature,
                           Preferred_Quantity, Preferred_End_Date,
                           Scoring_Fn_Quantity, Scoring_Fn_End_Date,
                           Pref_Score_Quantity, Pref_Score_End_Date,
                           Phased, Phase_no, Confidence, Success, Quantity,
                           End_Date, Score_Quantity, Score_End_Date)
SELECT DISTINCT
      t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
      t1.ClassName, t1.SupplyClass, t1.SupplyType,
      t1.For_Organization, t1.To_Location, t1.Maintain_Type,
      t1.Maintain_TypeID, t1.Maintain_ItemID,
      t1.Maintain_Nomenclature, t1.Preferred_Quantity,
      t1.Preferred_End_Date, t1.Scoring_Fn_Quantity,
      t1.Scoring_Fn_End_Date, t1.Pref_Score_Quantity,
      t1.Pref_Score_End_Date, t1.Phased, count(t1.Phase_no),
      sum(t1.Confidence * t1.Quantity / t1.Preferred_Quantity),
      min(t1.Success), sum(t1.Quantity), max(t1.End_Date),
      Consolidated_Quantity.score, Consolidated_End_Date.score
FROM T_XXX_Phased t1,
     consolidated_aspects Consolidated_Quantity,
     consolidated_aspects Consolidated_End_Date
WHERE t1.verb       = 'Supply'
  AND Consolidated_Quantity.task_id    = t1.task_id
  AND Consolidated_Quantity.run_id     = t1.run_id
  AND Consolidated_End_Date.task_id    = t1.task_id
  AND Consolidated_End_Date.run_id     = t1.run_id
  AND Consolidated_Quantity.aspecttype = 'QUANTITY'
  AND Consolidated_End_Date.aspecttype = 'END_TIME'
  AND t1.Phased > 0
GROUP BY t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
         t1.ClassName, t1.SupplyClass, t1.SupplyType,
         t1.For_Organization, t1.To_Location,
         t1.Maintain_Type, t1.Maintain_TypeID, t1.Maintain_ItemID,
         t1.Maintain_Nomenclature, t1.Preferred_Quantity,
         t1.Preferred_End_Date, t1.Scoring_Fn_Quantity,
         t1.Scoring_Fn_End_Date, t1.Pref_Score_Quantity,
         t1.Pref_Score_End_Date, t1.Phased, Consolidated_Quantity.score,
         Consolidated_End_Date.score;
),




      "19_Insert_Temp_Stressed" => qq(
INSERT INTO Temp_XXX (run_id, task_id, Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType,
                           For_Organization, To_Location,
                           Maintain_Type, Maintain_TypeID,
                           Maintain_ItemID, Maintain_Nomenclature,
                           Preferred_Start_Date, Preferred_End_Date,
                           Preferred_Rate, Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Scoring_Fn_Rate,
                           Pref_Score_Start_Date, Pref_Score_End_Date,
                           Pref_Score_Rate, Phased, Phase_no, Confidence,
                           Success, Start_Date, End_Date, Rate,
                           Score_Start_Date, Score_End_Date,
                           Score_Rate)
SELECT t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
       t1.ClassName, t1.SupplyClass, t1.SupplyType,
       t1.For_Organization, t1.To_Location, t1.Maintain_Type,
       t1.Maintain_TypeID, t1.Maintain_ItemID,
       t1.Maintain_Nomenclature, t1.Preferred_Start_Date,
       t1.Preferred_End_Date, t1.Preferred_Rate,
       t1.Scoring_Fn_Start_Date, t1.Scoring_Fn_End_Date,
       t1.Scoring_Fn_Rate, t1.Pref_Score_Start_Date,
       t1.Pref_Score_End_Date, t1.Pref_Score_Rate, t1.Phased,
       count(t1.Phase_no), sum(t1.Confidence * t1.Rate * (t1.End_Date
       - t1.Start_Date)) /
          (t1.Preferred_Rate * (max(t1.End_Date) - min(t1.Start_Date))),
       min(t1.Success), min(t1.Start_Date), max(t1.End_Date),
       sum(t1.Rate * (t1.End_Date - t1.Start_Date))/(max(t1.End_Date) - 
                                                     min(t1.Start_Date)) ,
       Consolidated_Start_Date.score,
       Consolidated_End_Date.score,
       Consolidated_Rate.score
FROM T_XXX_Phased t1,
     consolidated_aspects Consolidated_Start_Date,
     consolidated_aspects Consolidated_End_Date,
     consolidated_aspects Consolidated_Rate
WHERE t1.verb       = 'ProjectSupply'
  AND Consolidated_Start_Date.run_id     = t1.run_id
  AND Consolidated_End_Date.run_id       = t1.run_id
  AND Consolidated_Rate.run_id           = t1.run_id
  AND Consolidated_Start_Date.task_id    = t1.task_id
  AND Consolidated_End_Date.task_id      = t1.task_id
  AND Consolidated_Rate.task_id          = t1.task_id
  AND Consolidated_Start_Date.aspecttype = 'START_TIME'
  AND Consolidated_End_Date.aspecttype   = 'END_TIME'
  AND Consolidated_Rate.aspecttype       = 'RATE'
  AND t1.Phased > 0
GROUP BY t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
         t1.ClassName, t1.SupplyClass, t1.SupplyType,
         t1.For_Organization, t1.To_Location,
         t1.Maintain_Type, t1.Maintain_TypeID, t1.Maintain_ItemID,
         t1.Maintain_Nomenclature, t1.Preferred_Start_Date,
         t1.Preferred_End_Date, t1.Preferred_Rate,
	t1.Scoring_Fn_Start_Date, t1.Scoring_Fn_End_Date,
         t1.Scoring_Fn_Rate, t1.Pref_Score_Start_Date,
         t1.Pref_Score_End_Date, t1.Pref_Score_Rate, t1.Phased,
         Consolidated_Start_Date.score, Consolidated_End_Date.score,
         Consolidated_Rate.score;
),

      #"20_drop_Stressed" => qq(DROP TABLE  Stressed_XXX;),
      "21_Create_Stressed" => qq(
CREATE TABLE Stressed_XXX (
  run_id                bigint  NOT NULL,
  task_id               varchar(63) NOT NULL,
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  ClassName             varchar(255)         default NULL,
  SupplyClass           varchar(63)          default NULL,
  SupplyType            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Preferred_Rate        double precision              default NULL,
  Scoring_Fn_Quantity   varchar(255)         default NULL,
  Scoring_Fn_Start_Date varchar(255)         default NULL,
  Scoring_Fn_End_Date   varchar(255)         default NULL,
  Scoring_Fn_Rate       varchar(255)         default NULL,
  Pref_Score_Quantity   double precision                default NULL,
  Pref_Score_Start_Date double precision              default NULL,
  Pref_Score_End_Date   double precision                default NULL,
  Pref_Score_Rate       double precision                default NULL,
  Quantity          double precision                default NULL,
  Start_Date        double precision              default NULL,
  End_Date          double precision              default NULL,
  Rate              double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL,
  Deviation_Quantity        double precision                default NULL,
  Deviation_Start_Date      double precision                default NULL,
  Deviation_End_Date        double precision                default NULL,
  Deviation_Rate            double precision                default NULL
);
),



      "22_Insert_Stressed" => qq(
INSERT INTO Stressed_XXX (run_id, task_id, Agent, Verb, NSN_Number,
                      ClassName, SupplyClass, SupplyType,
                      From_Location, For_Organization,
                      To_Location, Maintain_Type,
                      Maintain_TypeID, Maintain_ItemID,
                      Maintain_Nomenclature, Preferred_Quantity,
                      Preferred_Start_Date, Preferred_End_Date,
                      Preferred_Rate, Scoring_Fn_Quantity,
                      Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                      Scoring_Fn_Rate, Pref_Score_Quantity,
                      Pref_Score_Start_Date, Pref_Score_End_Date,
                      Pref_Score_Rate, Quantity, Start_Date, End_Date,
                      Rate, Score_Quantity, Score_Start_Date,
                      Score_End_Date, Score_Rate, Phased, Phase_no,
                      Confidence, Success, Deviation_Quantity,
                      Deviation_Start_Date, Deviation_End_Date,
                      Deviation_Rate)
SELECT DISTINCT t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
                t1.ClassName, t1.SupplyClass, t1.SupplyType,
                t1.From_Location, t1.For_Organization,
                t1.To_Location, t1.Maintain_Type,
                t1.Maintain_TypeID, t1.Maintain_ItemID,
                t1.Maintain_Nomenclature, t1.Preferred_Quantity,
                t1.Preferred_Start_Date, t1.Preferred_End_Date,
                t1.Preferred_Rate, t1.Scoring_Fn_Quantity,
                t1.Scoring_Fn_Start_Date, t1.Scoring_Fn_End_Date,
                t1.Scoring_Fn_Rate, t1.Pref_Score_Quantity,
                t1.Pref_Score_Start_Date, t1.Pref_Score_End_Date,
                t1.Pref_Score_Rate, t1.Quantity, t1.Start_Date,
                t1.End_Date, t1.Rate, t1.Score_Quantity,
                t1.Score_Start_Date, t1.Score_End_Date, t1.Score_Rate,
                t1.Phased, t1.Phase_no, t1.Confidence, t1.Success,
                POW((ABS((t1.Preferred_Quantity) -
                     (t1.Quantity)) / 86400000), 4) * t2.E +
                POW((ABS((t1.Preferred_Quantity) -
                     (t1.Quantity)) / 86400000), 3) * t2.D +
                POW((ABS((t1.Preferred_Quantity) -
                     (t1.Quantity)) / 86400000), 2) * t2.C +
                ABS((t1.Preferred_Quantity) -
                    (t1.Quantity)) / 86400000 * t2.B
                + t2.A,
       POW((ABS((t1.Preferred_Start_Date) -
           (t1.Start_Date)) / 86400000), 4) * t2.E +
       POW((ABS((t1.Preferred_Start_Date) -
           (t1.Start_Date)) / 86400000), 3) * t2.D +
       POW((ABS((t1.Preferred_Start_Date) -
           (t1.Start_Date)) / 86400000), 2) * t2.C +
       ABS((t1.Preferred_Start_Date) -
           (t1.Start_Date)) / 86400000 * t2.B
       + t2.A,
       POW((ABS((t1.Preferred_End_Date) -
           (t1.End_Date)) / 86400000), 4) * t2.E +
       POW((ABS((t1.Preferred_End_Date) -
           (t1.End_Date)) / 86400000), 3) * t2.D +
       POW((ABS((t1.Preferred_End_Date) -
           (t1.End_Date)) / 86400000), 2) * t2.C +
       ABS((t1.Preferred_End_Date) -
           (t1.End_Date)) / 86400000 * t2.B
       + t2.A,
       POW((ABS((t1.Preferred_Rate) - (t1.Rate))), 4) * t2.E +
       POW((ABS((t1.Preferred_Rate) - (t1.Rate))), 3) * t2.D +
       POW((ABS((t1.Preferred_Rate) - (t1.Rate))), 2) * t2.C +
                     ABS((t1.Preferred_Rate) - (t1.Rate))      * t2.B
       + t2.A
FROM Temp_XXX t1, Scoring_Constants t2
WHERE t2.ID = 'Default';)

     }
    );
  for my $datum (keys %Stressed ) {
    no strict "refs";
    *$datum = sub {
      use strict "refs";
      my ($self, $newvalue) = @_;
      $Stressed{$datum} = $newvalue if @_ > 1;
      return $Stressed{$datum};
    }
  }
}

sub new{
  my $this = shift;
  my %params = @_;
  my $class = ref($this) || $this;
  my $self = {};
  warn "New CnCCalc::Stressed object" if $::ConfOpts{'TRACE_SUBS'};

  bless $self, $class;

  $self->{' _Debug'} = 0;
  return $self;
}

sub create_tables() {
  my $self = shift;
  my %params = @_;

  warn "CnCCalc::Stressed::create_tables" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'DB Handle' missing"
    unless defined $params{'DB Handle'};
  die "Required parameter 'Stressed RunID' missing"
    unless defined $params{'Stressed RunID'};

  my $hashref = $self->Tables();
  my $dbh = $params{'DB Handle'};
  my $body = "<p>Created entity:</p><ol compact=\"compact\">";


  ### Create a new statement handle to fetch table information
  my %HaveTable = ();
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTable{$name}++;
  }
  $tabsth->finish;

  my $return_code = 1;
  for my $drop_table ($self->Clean()) {
    $drop_table =~ s/XXX/$params{'Stressed RunID'}/g;
    if ($HaveTable{$drop_table}) {
      eval {$dbh->do("DROP TABLE $drop_table;");};
      if ($@) {
	$body .= "<li>Failed to drop table $drop_table</li>\n";
      }
      else {
	my $rc = $dbh->commit;
	if (! $rc) {
	  my $err = $dbh->errstr;
	  $return_code = $dbh->err;
	  warn "Could not commit data ($err)";
	}
	$body .= qq(<li>Dropped table $drop_table</li>\n);
      }
    }
  }

  my $err;
  for my $table_id (sort keys %{ $hashref }) {
    my ($table) = $table_id =~ /^\d\d_(\S+)/;
    my ($count) = $table_id =~ /^(\d\d)/;
    ## We have drop table commands, so we do not check to see if the
    ## table exists. This allows us to interleave commands into the
    ## initialization steps.
    # next if $::ConfOpts{'HaveTable'}{$table};
    my $instruction = $hashref->{$table_id};
    $instruction =~ s/XXX/$params{'Stressed RunID'}/g;
    if ($::ConfOpts{'Keep'}) {
      $instruction =~ s/__TEMP__//g;
    }
    else {
      $instruction =~ s/__TEMP__/TEMPORARY/g;
    }
    my $now_string = gmtime;
    my $retval;
    # sleep 10;
    warn "$now_string: doing instruction $count";
    eval {
      $retval = $dbh->do($instruction);
    };
    if ($@ || ! defined $retval) {
      warn "Instruction number $count failed.";
      warn "undef value returned" unless defined $retval;
      $err = $dbh->errstr;
      warn "$err";
      $body.="<li>Failed instruction number $count ($table).<br>$@<br></li>\n";
      $return_code = $dbh->err;
      last;
    }
    else {
      warn "Instruction number $count worked.";
      my $rc = $dbh->commit;
      if (! $rc) {
	$err = $dbh->errstr;
	$return_code = $dbh->err;
	warn "Could not commit data ($err)";
	last;
      }
      else {
	warn "Committed changes\n";
      }
      $body .= qq(<li>Instruction $count ($table) done</li>\n);
    }
  }
  my $now_string = gmtime;
  warn "$now_string: done";
  $body .= "</ol>\n";
  warn $body if $::ConfOpts{'LOG_INFO'};
  return $return_code;
}

sub dump() {
  my $self = shift;
  my %params = @_;

  warn "CnCCalc::Stressed::dump" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'Stressed RunID' missing"
    unless defined $params{'Stressed RunID'};

  my $hashref = $self->Tables();
  my $body = "";

  for my $table_id (sort keys %{ $hashref }) {
    my ($table) = $table_id =~ /^\d\d_(\S+)/;
    my ($count) = $table_id =~ /^(\d\d)/;
    ## We have drop table commands, so we do not check to see if the
    ## table exists. This allows us to interleave commands into the
    ## initialization steps.
    # next if $::ConfOpts{'HaveTable'}{$table};
    my $instruction = $hashref->{$table_id};
    $instruction =~ s/XXX/$params{'Stressed RunID'}/g;
    $instruction =~ s/__TEMP__//g;
    $body .= qq(-- $count ($table) \n );
    $body .= qq($instruction \n\n);
  }
  $body .= "\n";
  return $body;
}

1;

__END__;
