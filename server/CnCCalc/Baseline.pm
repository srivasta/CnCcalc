#                              -*- Mode: Perl -*-
# Baseline.pm ---
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com )
# Created On       : Wed Apr  2 08:35:51 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Nov 19 18:55:05 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 68
# Status           : Unknown, Use with caution!
# HISTORY          :
# Description      :
#
#

package CnCCalc::Baseline;

use strict;
use DBI;
{
  my %Baseline =
    (
     'Clean' => [qw("XXbaseXX" "T_XXbaseXX_OP" "T_XXbaseXX_Rslt"
                   "T_XXbaseXX_Phased" "T_XXbaseXX")],
     'Tables' =>
     {
      # "00_drop_T_XXbaseXX_OP" => qq(DROP TABLE "T_XXbaseXX_OP";),
      "01_T_XXbaseXX_OP" => qq(
CREATE __TEMP__  TABLE "T_XXbaseXX_OP" (
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
);),


      "02_Insert_Temp_OP" => qq(INSERT INTO "T_XXbaseXX_OP"
                             (run_id, task_id,
                              Agent, Verb, NSN_Number, ClassName,
                              SupplyClass, SupplyType, From_Location,
                              To_Location, Preferred_Start_Date,
                              Preferred_End_Date,
                              Scoring_Fn_Start_Date,
                              Scoring_Fn_End_Date,
                              Pref_Score_Start_Date,
                              Pref_Score_End_Date)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prepositions.From_Location, prepositions.To_Location,
       preferences.Preferred_Start_Date,
       preferences.Preferred_End_Date,
       preferences.Scoring_Fn_Start_Date,
       preferences.Scoring_Fn_End_Date,
       preferences.Pref_Score_Start_Date,
       preferences.Pref_Score_End_Date
FROM tasks, preferences, prepositions, assets
WHERE tasks.run_id in (XXlistXX)
  AND tasks.verb               = 'Transport'
  AND prepositions.task_id     = tasks.id
  AND prepositions.run_id      = tasks.run_id
  AND preferences.task_id            = tasks.id
  AND preferences.run_id             = tasks.run_id
  AND assets.run_id            = tasks.run_id
  AND assets.task_id           = tasks.id;),

      # "03_drop_T_XXbaseXX_Rslt" => qq(DROP TABLE "T_XXbaseXX_Rslt";),
      "04_T_XXbaseXX_Rslt" => qq(
CREATE __TEMP__ TABLE "T_XXbaseXX_Rslt" (
  run_id                bigint  NOT NULL,
  task_id               varchar(63) NOT NULL,
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL,
  Quantity              double precision              default NULL,
  Start_Date            double precision              default NULL,
  End_Date              double precision              default NULL,
  Rate                  double precision              default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL
);),

      "05_Insert_Temp_Results" => qq(
INSERT INTO "T_XXbaseXX_Rslt" (run_id, task_id,
                                   Agent, Verb, Phased, Phase_no,
                                   Confidence, Success,
                                   Start_Date, End_Date,
                                   Score_Start_Date,
                                   Score_End_Date)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       allocation_results.phased, phval1.phase_no,
       allocation_results.confidence, allocation_results.Success,
       phval1.value as Start_Date, phval2.value as End_Date,
       phval1.score as Score_Start_Date, phval2.score as
       Score_End_Date
FROM tasks, allocation_results, phased_aspects phval1, phased_aspects phval2
WHERE tasks.run_id in (XXlistXX)
  AND tasks.verb               = 'Transport'
  AND tasks.run_id             = allocation_results.run_id
  AND tasks.id                 = allocation_results.task_id
  AND tasks.run_id             = phval1.run_id
  AND tasks.id                 = phval1.task_id
  AND tasks.run_id             = phval2.run_id
  AND tasks.id                 = phval2.task_id
  AND phval1.phase_no          = phval2.phase_no
  AND phval1.aspecttype        = 'START_TIME'
  AND phval2.aspecttype        = 'END_TIME';),

      "06_Insert_Temp_OP" => qq(
INSERT INTO "T_XXbaseXX_OP" (run_id, task_id, Agent,
                              Verb, NSN_Number, ClassName,
                              SupplyClass, SupplyType,
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
       prepositions.Maintain_Type, prepositions.Maintain_TypeID,
       prepositions.Maintain_ItemID,
       prepositions.Maintain_Nomenclature,
       preferences.Preferred_Quantity, preferences.Preferred_End_Date,
       preferences.Scoring_Fn_Quantity,
       preferences.Scoring_Fn_End_Date,
       preferences.Pref_Score_Quantity, preferences.Pref_Score_End_Date
FROM tasks, preferences, prepositions, assets
WHERE tasks.run_id in (XXlistXX)
  AND tasks.verb               = 'Supply'
  AND prepositions.run_id           = tasks.run_id
  AND prepositions.task_id          = tasks.id
  AND preferences.run_id             = tasks.run_id
  AND preferences.task_id            = tasks.id
  AND assets.run_id            = tasks.run_id
  AND assets.task_id           = tasks.id;),

      "07_Insert_Temp_Results" => qq(
INSERT INTO "T_XXbaseXX_Rslt" (run_id, task_id,
                                   Agent, Verb, Phased, Phase_no,
                                   Confidence, Success,
                                   Quantity, End_Date, Score_Quantity,
                                   Score_End_Date)
SELECT DISTINCT
       tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       allocation_results.phased, phval1.phase_no,
       allocation_results.confidence,  allocation_results.Success,
       phval1.value as Quantity,
       phval2.value as End_Date,
       phval1.score as Score_Quantity,
       phval2.score as Score_End_Date
FROM tasks, allocation_results, phased_aspects phval1, phased_aspects phval2,
     Scoring_Constants t2
WHERE tasks.run_id in (XXlistXX)
  AND tasks.verb       = 'Supply'
  AND tasks.run_id             = allocation_results.run_id
  AND tasks.id                 = allocation_results.task_id
  AND tasks.run_id             = phval1.run_id
  AND tasks.id                 = phval1.task_id
  AND tasks.run_id             = phval2.run_id
  AND tasks.id                 = phval2.task_id
  AND phval1.phase_no          = phval2.phase_no
  AND phval1.aspecttype        = 'QUANTITY'
  AND phval2.aspecttype        = 'END_TIME';),


      "08_Insert_Temp_OP" => qq(INSERT INTO "T_XXbaseXX_OP" (run_id, task_id,
                              Agent, Verb, NSN_Number, ClassName,
                              SupplyClass, SupplyType,
                              For_Organization, To_Location, 
                              Maintain_Type, Maintain_TypeID,
                              Maintain_ItemID, Maintain_Nomenclature,
                              Preferred_Start_Date,
                              Preferred_End_Date, Preferred_Rate,
                          Scoring_Fn_Start_Date,
                              Scoring_Fn_End_Date, Scoring_Fn_Rate,
                          Pref_Score_Start_Date,
                             Pref_Score_End_Date, Pref_Score_Rate)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prepositions.For_Organization, prepositions.To_Location,
       prepositions.Maintain_Type, prepositions.Maintain_TypeID,
       prepositions.Maintain_ItemID,
       prepositions.Maintain_Nomenclature,
       preferences.Preferred_Start_Date, preferences.Preferred_End_Date,
       preferences.Preferred_Rate,
       preferences.Scoring_Fn_Start_Date,
       preferences.Scoring_Fn_End_Date, preferences.Scoring_Fn_Rate,
       preferences.Pref_Score_Start_Date,
       preferences.Pref_Score_End_Date, preferences.Pref_Score_Rate
FROM tasks, preferences,  prepositions, assets
WHERE tasks.run_id in (XXlistXX)
  AND tasks.verb       = 'ProjectSupply'
  AND prepositions.run_id           = tasks.run_id
  AND prepositions.task_id          = tasks.id
  AND preferences.run_id     = tasks.run_id
  AND preferences.task_id    = tasks.id
  AND assets.run_id    = tasks.run_id
  AND assets.task_id   = tasks.id;),

      "09_Insert_Temp_Results" => qq(
INSERT INTO "T_XXbaseXX_Rslt" (run_id, task_id,
                             Agent, Verb, Phased, Phase_no, Confidence,
                             Success, Start_Date, End_Date, Rate,
                             Score_Start_Date, Score_End_Date,
                             Score_Rate)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       allocation_results.phased, phval1.phase_no,
       allocation_results.confidence,  allocation_results.Success,
       phval1.value as Start_Date,
       phval2.value as End_Date,
       phval3.value as Rate,
       phval1.score as Score_Start_Date,
       phval2.score as Score_End_Date,
       phval3.score as Score_Rate
FROM tasks, allocation_results, phased_aspects phval1, phased_aspects phval2,
     phased_aspects phval3
WHERE tasks.run_id in (XXlistXX)
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
  AND phval3.aspecttype        = '15';),

      "10_update_ops" => qq(
UPDATE "T_XXbaseXX_OP"
SET Maintain_ItemID = '----NULL----'
WHERE NOT Maintain_Type    IS NULL
  AND     Maintain_ItemID  IS NULL;
;),

      # "10_drop_T_XXbaseXX_Phased" => qq(DROP TABLE "T_XXbaseXX_Phased";),
      "11_T_XXbaseXX_Phased" => qq(
CREATE __TEMP__ TABLE "T_XXbaseXX_Phased" (
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
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL,
  Quantity              double precision                default NULL,
  Start_Date            double precision              default NULL,
  End_Date              double precision              default NULL,
  Rate                  double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Deviation_Quantity        double precision                default NULL,
  Deviation_Start_Date      double precision                default NULL,
  Deviation_End_Date        double precision                default NULL,
  Deviation_Rate            double precision                default NULL,
  Scoring_Fn_Quantity   varchar(255)         default NULL,
  Scoring_Fn_Start_Date varchar(255)         default NULL,
  Scoring_Fn_End_Date   varchar(255)         default NULL,
  Scoring_Fn_Rate       varchar(255)         default NULL,
  Pref_Score_Quantity   double precision                default NULL,
  Pref_Score_Start_Date double precision              default NULL,
  Pref_Score_End_Date   double precision                default NULL,
  Pref_Score_Rate       double precision                default NULL
);),


      "12_Insert_Temp_Phased" => qq(
INSERT INTO "T_XXbaseXX_Phased" (run_id, task_id,
                           Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType, From_Location, 
                           To_Location, Preferred_Start_Date,
                           Preferred_End_Date, Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Phased, Phase_no, Confidence,
                           Success, Start_Date, End_Date,
                           Score_Start_Date, Score_End_Date)
SELECT "T_XXbaseXX_OP".run_id, "T_XXbaseXX_OP".task_id,
       "T_XXbaseXX_OP".Agent, "T_XXbaseXX_OP".Verb,
       "T_XXbaseXX_OP".NSN_Number,
       "T_XXbaseXX_OP".ClassName,
       "T_XXbaseXX_OP".SupplyClass,
       "T_XXbaseXX_OP".SupplyType,
       "T_XXbaseXX_OP".From_Location,
       "T_XXbaseXX_OP".To_Location,
       "T_XXbaseXX_OP".Preferred_Start_Date,
       "T_XXbaseXX_OP".Preferred_End_Date,
       "T_XXbaseXX_OP".Scoring_Fn_Start_Date,
       "T_XXbaseXX_OP".Scoring_Fn_End_Date,
       "T_XXbaseXX_OP".Pref_Score_Start_Date,
       "T_XXbaseXX_OP".Pref_Score_End_Date,
       "T_XXbaseXX_Rslt".Phased,
       "T_XXbaseXX_Rslt".Phase_no,
       "T_XXbaseXX_Rslt".confidence,
       "T_XXbaseXX_Rslt".Success,
       "T_XXbaseXX_Rslt".Start_Date,
       "T_XXbaseXX_Rslt".End_Date,
       "T_XXbaseXX_Rslt".Score_Start_Date,
       "T_XXbaseXX_Rslt".Score_End_Date
FROM "T_XXbaseXX_OP" FULL OUTER JOIN "T_XXbaseXX_Rslt"
     ON ("T_XXbaseXX_OP".task_id = "T_XXbaseXX_Rslt".task_id AND
         "T_XXbaseXX_OP".run_id  = "T_XXbaseXX_Rslt".run_id)
WHERE "T_XXbaseXX_OP".verb    = 'Transport';),


      "13_Insert_Temp_Phased" => qq(
INSERT INTO "T_XXbaseXX_Phased" (run_id, task_id,
                           Agent, Verb, NSN_Number, ClassName,
                           SupplyClass, SupplyType, For_Organization,
                           To_Location, Maintain_Type,
                           Maintain_TypeID, Maintain_ItemID,
                           Maintain_Nomenclature, Preferred_Quantity,
                           Preferred_End_Date, Scoring_Fn_Quantity,
                           Scoring_Fn_End_Date, Pref_Score_Quantity,
                           Pref_Score_End_Date, Phased, Phase_no, Confidence,
                           Success, Quantity, End_Date,
                           Score_Quantity, Score_End_Date)
SELECT DISTINCT
       "T_XXbaseXX_OP".run_id, "T_XXbaseXX_OP".task_id,
       "T_XXbaseXX_OP".Agent, "T_XXbaseXX_OP".Verb,
       "T_XXbaseXX_OP".NSN_Number,
       "T_XXbaseXX_OP".ClassName,
       "T_XXbaseXX_OP".SupplyClass,
       "T_XXbaseXX_OP".SupplyType,
       "T_XXbaseXX_OP".For_Organization,
       "T_XXbaseXX_OP".To_Location,
       "T_XXbaseXX_OP".Maintain_Type,
       "T_XXbaseXX_OP".Maintain_TypeID,
       "T_XXbaseXX_OP".Maintain_ItemID,
       "T_XXbaseXX_OP".Maintain_Nomenclature,
       "T_XXbaseXX_OP".Preferred_Quantity,
       "T_XXbaseXX_OP".Preferred_End_Date,
       "T_XXbaseXX_OP".Scoring_Fn_Quantity,
       "T_XXbaseXX_OP".Scoring_Fn_End_Date,
       "T_XXbaseXX_OP".Pref_Score_Quantity,
       "T_XXbaseXX_OP".Pref_Score_End_Date,
       "T_XXbaseXX_Rslt".Phased,
       "T_XXbaseXX_Rslt".Phase_no,
       "T_XXbaseXX_Rslt".Confidence,
       "T_XXbaseXX_Rslt".Success,
       "T_XXbaseXX_Rslt".Quantity,
       "T_XXbaseXX_Rslt".End_Date,
       "T_XXbaseXX_Rslt".Score_Quantity,
       "T_XXbaseXX_Rslt".Score_End_Date
FROM "T_XXbaseXX_OP" FULL OUTER JOIN "T_XXbaseXX_Rslt"
       ON ("T_XXbaseXX_OP".task_id = "T_XXbaseXX_Rslt".task_id AND
           "T_XXbaseXX_OP".run_id  = "T_XXbaseXX_Rslt".run_id)
WHERE "T_XXbaseXX_OP".verb    = 'Supply';),

      "14_Insert_Temp_Phased" => qq(
INSERT INTO "T_XXbaseXX_Phased"(run_id, task_id,
                         Agent, Verb, NSN_Number, ClassName,
                         SupplyClass, SupplyType, For_Organization,
                         To_Location, Maintain_Type, Maintain_TypeID,
                         Maintain_ItemID, Maintain_Nomenclature,
                         Preferred_Start_Date,
                           Preferred_End_Date, Preferred_Rate,
                           Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                         Scoring_Fn_Rate, Pref_Score_Start_Date,
                         Pref_Score_End_Date, Pref_Score_Rate, Phased,
                           Phase_no, Confidence, Success, Start_Date,
                           End_Date, Rate, Score_Start_Date,
                           Score_End_Date, Score_Rate)
SELECT "T_XXbaseXX_OP".run_id, "T_XXbaseXX_OP".task_id,
       "T_XXbaseXX_OP".Agent, "T_XXbaseXX_OP".Verb,
       "T_XXbaseXX_OP".NSN_Number,
       "T_XXbaseXX_OP".ClassName,
       "T_XXbaseXX_OP".SupplyClass,
       "T_XXbaseXX_OP".SupplyType,
       "T_XXbaseXX_OP".For_Organization,
       "T_XXbaseXX_OP".To_Location,
       "T_XXbaseXX_OP".Maintain_Type,
       "T_XXbaseXX_OP".Maintain_TypeID,
       "T_XXbaseXX_OP".Maintain_ItemID,
       "T_XXbaseXX_OP".Maintain_Nomenclature,
       "T_XXbaseXX_OP".Preferred_Start_Date,
       "T_XXbaseXX_OP".Preferred_End_Date,
       "T_XXbaseXX_OP".Preferred_Rate,
       "T_XXbaseXX_OP".Scoring_Fn_Start_Date,
       "T_XXbaseXX_OP".Scoring_Fn_End_Date,
       "T_XXbaseXX_OP".Scoring_Fn_Rate,
       "T_XXbaseXX_OP".Pref_Score_Start_Date,
       "T_XXbaseXX_OP".Pref_Score_End_Date,
       "T_XXbaseXX_OP".Pref_Score_Rate,
       "T_XXbaseXX_Rslt".Phased,
       "T_XXbaseXX_Rslt".Phase_no,
       "T_XXbaseXX_Rslt".Confidence,
       "T_XXbaseXX_Rslt".Success,
       "T_XXbaseXX_Rslt".Start_Date,
       "T_XXbaseXX_Rslt".End_Date,
       "T_XXbaseXX_Rslt".Rate,
       "T_XXbaseXX_Rslt".Score_Start_Date,
       "T_XXbaseXX_Rslt".Score_End_Date,
       "T_XXbaseXX_Rslt".Score_Rate
FROM "T_XXbaseXX_OP" FULL OUTER JOIN "T_XXbaseXX_Rslt"
       ON ("T_XXbaseXX_OP".task_id = "T_XXbaseXX_Rslt".task_id AND
           "T_XXbaseXX_OP".run_id  = "T_XXbaseXX_Rslt".run_id)
WHERE "T_XXbaseXX_OP".verb    = 'ProjectSupply';),

      # "15_drop_T_XXbaseXX" => qq(DROP TABLE "T_XXbaseXX";),
      "16_T_XXbaseXX" => qq(
CREATE TABLE "T_XXbaseXX" (
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
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL,
  Quantity              double precision                default NULL,
  Start_Date            double precision              default NULL,
  End_Date              double precision              default NULL,
  Rate                  double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Deviation_Quantity        double precision                default NULL,
  Deviation_Start_Date      double precision                default NULL,
  Deviation_End_Date        double precision                default NULL,
  Deviation_Rate            double precision                default NULL,
  Scoring_Fn_Quantity   varchar(255)         default NULL,
  Scoring_Fn_Start_Date varchar(255)         default NULL,
  Scoring_Fn_End_Date   varchar(255)         default NULL,
  Scoring_Fn_Rate       varchar(255)         default NULL,
  Pref_Score_Quantity   double precision                default NULL,
  Pref_Score_Start_Date double precision              default NULL,
  Pref_Score_End_Date   double precision                default NULL,
  Pref_Score_Rate       double precision                default NULL
);),



      "17_Insert_Temp_Baseline" => qq(
INSERT INTO "T_XXbaseXX" (run_id, task_id,
                           Agent, Verb, NSN_Number, ClassName,
                           SupplyClass, SupplyType, From_Location,
                           For_Organization, To_Location,
                           Maintain_Type, Maintain_TypeID,
                           Maintain_ItemID, Maintain_Nomenclature,
                           Preferred_Quantity, Preferred_Start_Date,
                           Preferred_End_Date, Preferred_Rate,
                           Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Scoring_Fn_Rate,
                           Pref_Score_Quantity, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Pref_Score_Rate,
                           Phased, Phase_no, Confidence, Success, Quantity,
                           Start_Date, End_Date, Rate, Score_Quantity,
                           Score_Start_Date, Score_End_Date,
                           Score_Rate)
SELECT DISTINCT
       run_id, task_id, Agent, Verb, NSN_Number, ClassName,
       SupplyClass, SupplyType, From_Location, For_Organization,
       To_Location, Maintain_Type, Maintain_TypeID, Maintain_ItemID,
       Maintain_Nomenclature, Preferred_Quantity,
       Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
       Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
       Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
       Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
       Phased, Phase_no, Confidence, Success, Quantity, Start_Date, End_Date,
       Rate, Score_Quantity, Score_Start_Date, Score_End_Date,
       Score_Rate
FROM "T_XXbaseXX_Phased"
WHERE Phased = 0;),

      "18_Insert_Temp_Baseline" => qq(
INSERT INTO "T_XXbaseXX" (run_id, task_id,
                           Agent, Verb, NSN_Number, ClassName,
                           SupplyClass, SupplyType, For_Organization,
                           To_Location, Maintain_Type,
                           Maintain_TypeID, Maintain_ItemID,
                           Maintain_Nomenclature, Preferred_Quantity,
                           Preferred_End_Date, Scoring_Fn_Quantity,
                           Scoring_Fn_End_Date, Pref_Score_Quantity,
                           Pref_Score_End_Date, Phased, Phase_no, Confidence,
                           Success, Quantity, End_Date,
                           Score_Quantity, Score_End_Date)
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
FROM "T_XXbaseXX_Phased" t1,
     consolidated_aspects Consolidated_Quantity,
     consolidated_aspects Consolidated_End_Date
WHERE t1.verb    = 'Supply'
  AND Consolidated_Quantity.run_id     = t1.run_id
  AND Consolidated_End_Date.run_id     = t1.run_id
  AND Consolidated_Quantity.task_id    = t1.task_id
  AND Consolidated_End_Date.task_id    = t1.task_id
  AND Consolidated_Quantity.aspecttype = 'QUANTITY'
  AND Consolidated_End_Date.aspecttype = 'END_TIME'
  AND t1.Phased > 0
GROUP BY t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
         t1.ClassName, t1.SupplyClass, t1.SupplyType,
         t1.For_Organization, t1.To_Location, t1.Maintain_Type,
         t1.Maintain_TypeID, t1.Maintain_ItemID,
         t1.Maintain_Nomenclature, t1.Preferred_Quantity,
         t1.Preferred_End_Date, t1.Scoring_Fn_Quantity,
         t1.Scoring_Fn_End_Date, t1.Pref_Score_Quantity,
         t1.Pref_Score_End_Date, t1.Phased,
         Consolidated_Quantity.score, Consolidated_End_Date.score;),

      "19_Insert_Temp_Baseline" => qq(
 INSERT INTO "T_XXbaseXX" (run_id, task_id,
                           Agent, Verb, NSN_Number, ClassName,
                           SupplyClass, SupplyType, For_Organization,
                           To_Location, Maintain_Type,
                           Maintain_TypeID, Maintain_ItemID,
                           Maintain_Nomenclature,
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
       t1.Maintain_TypeID, t1.Maintain_ItemID, t1.Maintain_Nomenclature,
       t1.Preferred_Start_Date, t1.Preferred_End_Date,
       t1.Preferred_Rate, t1.Scoring_Fn_Start_Date,
       t1.Scoring_Fn_End_Date, t1.Scoring_Fn_Rate,
       t1.Pref_Score_Start_Date, t1.Pref_Score_End_Date,
       t1.Pref_Score_Rate, t1.Phased, count(t1.Phase_no), sum(t1.Confidence *
       t1.Rate * (t1.End_Date - t1.Start_Date)) /
          (t1.Preferred_Rate * (max(t1.End_Date) - min(t1.Start_Date))),
       min(t1.Success), min(t1.Start_Date), max(t1.End_Date),
       sum(t1.Rate * (t1.End_Date - t1.Start_Date))/(max(t1.End_Date) - min(t1.Start_Date)) ,
       Consolidated_Start_Date.score,
       Consolidated_End_Date.score,
       Consolidated_Rate.score
FROM "T_XXbaseXX_Phased" t1,
     consolidated_aspects Consolidated_Start_Date,
     consolidated_aspects Consolidated_End_Date,
     consolidated_aspects Consolidated_Rate
WHERE t1.verb    = 'ProjectSupply'
  AND Consolidated_Start_Date.run_id     = t1.run_id
  AND Consolidated_End_Date.run_id       = t1.run_id
  AND Consolidated_Rate.run_id           = t1.run_id
  AND Consolidated_Start_Date.run_id     = t1.task_id
  AND Consolidated_End_Date.run_id       = t1.task_id
  AND Consolidated_Rate.run_id           = t1.task_id
  AND Consolidated_Start_Date.aspecttype = 'START_TIME'
  AND Consolidated_End_Date.aspecttype   = 'END_TIME'
  AND Consolidated_Rate.aspecttype       = 'RATE'
 AND  t1.Phased > 0
GROUP BY t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
         t1.ClassName, t1.SupplyClass, t1.SupplyType,
         t1.For_Organization, t1.To_Location, t1.Maintain_Type,
         t1.Maintain_TypeID, t1.Maintain_ItemID,
         t1.Maintain_Nomenclature, t1.Preferred_Start_Date,
         t1.Preferred_End_Date, t1.Preferred_Rate,
         t1.Scoring_Fn_Start_Date, t1.Scoring_Fn_End_Date,
         t1.Scoring_Fn_Rate, t1.Pref_Score_Start_Date,
         t1.Pref_Score_End_Date, t1.Pref_Score_Rate, t1.Phased,
         Consolidated_Start_Date.score, Consolidated_End_Date.score,
         Consolidated_Rate.score;),

      "20_Update_Temp_Baseline" => qq(
UPDATE "T_XXbaseXX"
SET Deviation_Start_Date =
     POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 4) * t2.E +
     POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 3) * t2.D +
     POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 2) * t2.C +
          ABS(Preferred_Start_Date - Start_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'Transport'
  AND t2.ID      = 'Default';),


      "21_Update_Temp_Baseline" => qq(UPDATE "T_XXbaseXX"
SET Deviation_End_Date =
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 2) * t2.C +
             ABS(Preferred_End_Date - End_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'Transport'
  AND t2.ID      = 'Default';),


      "22_Update_Temp_Baseline" => qq(UPDATE "T_XXbaseXX"
SET Deviation_End_Date =
      (Preferred_Quantity / Quantity ) *
       (POW((ABS(Preferred_End_Date - End_Date) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 2) * t2.C +
             ABS(Preferred_End_Date - End_Date) / 86400000      * t2.B + t2.A)
FROM Scoring_Constants t2
WHERE verb       = 'Supply'
  AND Quantity   > 0
  AND t2.ID      = 'Default';),

      "23_Update_Temp_Baseline" => qq(UPDATE "T_XXbaseXX"
SET Deviation_Quantity =
       (Preferred_Quantity / Quantity ) *
       (POW((ABS(Preferred_Quantity - Quantity) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_Quantity - Quantity) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_Quantity - Quantity) / 86400000), 2) * t2.C +
             ABS(Preferred_Quantity - Quantity) / 86400000      * t2.B +  t2.A)
FROM Scoring_Constants t2
WHERE verb    = 'Supply'
  AND Quantity   > 0
  AND t2.ID      = 'Default';),

      "24_Update_Temp_Baseline" => qq(UPDATE "T_XXbaseXX"
SET Deviation_Start_Date =
      POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 4) * t2.E +
      POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 3) * t2.D +
      POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 2) * t2.C +
           ABS(Preferred_Start_Date - Start_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'ProjectSupply'
  AND t2.ID      = 'Default';),

      "25_Update_Temp_Baseline" => qq(UPDATE "T_XXbaseXX"
SET Deviation_End_Date =
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 2) * t2.C +
             ABS(Preferred_End_Date - End_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'ProjectSupply'
  AND t2.ID      = 'Default';),

      "26_Update_Temp_Baseline" => qq(UPDATE "T_XXbaseXX"
SET Deviation_Rate =
        POW((ABS(Preferred_Rate - Rate) ), 4) * t2.E +
        POW((ABS(Preferred_Rate - Rate) ), 3) * t2.D +
        POW((ABS(Preferred_Rate - Rate) ), 2) * t2.C +
             ABS(Preferred_Rate - Rate)       * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'ProjectSupply'
  AND t2.ID      = 'Default';),


      # "27_XXbaseXX" => qq(DROP TABLE  XXbaseXX;),
      "28_XXbaseXX" => qq(
CREATE TABLE "XXbaseXX" (
  num_runs              integer,
  num_tasks             integer,
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
  Phased                char(1)                       default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL,
  MIN_Quantity              double precision                default NULL,
  MIN_Start_Date            double precision              default NULL,
  MIN_End_Date              double precision              default NULL,
  MIN_Rate                  double precision                default NULL,
  MAX_Quantity              double precision                default NULL,
  MAX_Start_Date            double precision              default NULL,
  MAX_End_Date              double precision              default NULL,
  MAX_Rate                  double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Deviation_Quantity        double precision                default NULL,
  Deviation_Start_Date      double precision                default NULL,
  Deviation_End_Date        double precision                default NULL,
  Deviation_Rate            double precision                default NULL,
  Scoring_Fn_Quantity   varchar(255)         default NULL,
  Scoring_Fn_Start_Date varchar(255)         default NULL,
  Scoring_Fn_End_Date   varchar(255)         default NULL,
  Scoring_Fn_Rate       varchar(255)         default NULL,
  Pref_Score_Quantity   double precision                default NULL,
  Pref_Score_Start_Date double precision              default NULL,
  Pref_Score_End_Date   double precision                default NULL,
  Pref_Score_Rate       double precision                default NULL
);),



      "29_Insert_Baseline" => qq(
INSERT INTO "XXbaseXX"(
  Num_Runs, Num_Tasks,
  Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
  From_Location, To_Location, Preferred_Start_Date,
  Preferred_End_Date, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Pref_Score_Start_Date, Pref_Score_End_Date, Phased, Phase_no, Confidence,
  Success, MIN_Start_Date, MIN_End_Date, MAX_Start_Date, MAX_End_Date,
  Score_Start_Date, Score_End_Date, Deviation_Start_Date,
  Deviation_End_Date)
Select DISTINCT
       count(run_Id), count(task_id), Agent, Verb, NSN_Number,
       ClassName, SupplyClass, SupplyType, From_Location, To_Location,
       Preferred_Start_Date, Preferred_End_Date,
       Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
       Pref_Score_Start_Date, Pref_Score_End_Date, Phased, Phase_no,
       Confidence, Success, min(Start_Date) as MIN_Start_Date,
       min(End_Date) as MIN_End_Date, max(Start_Date) as
       MAX_Start_Date, max(End_Date) as MAX_End_Date,
       max(Score_Start_Date) as Score_Start_Date, max(Score_End_Date)
       as Score_End_Date, max(Deviation_Start_Date) as
       Deviation_Start_Date, max(Deviation_End_Date) as
       Deviation_End_Date
FROM "T_XXbaseXX"
WHERE Verb = 'Transport'
GROUP BY agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType, From_Location, 
         To_Location, Preferred_Start_Date, Preferred_End_Date,
         Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
         Pref_Score_Start_Date, Pref_Score_End_Date,
         Phased, Phase_no, Confidence, Success;),

      "30_Insert_Baseline" => qq(
INSERT INTO "XXbaseXX"(
  Num_Runs, Num_Tasks, Agent, Verb, NSN_Number, ClassName,
  SupplyClass, SupplyType, For_Organization, To_Location,
  Maintain_Type, Maintain_TypeID, Maintain_ItemID,
  Maintain_Nomenclature, Preferred_Quantity, Preferred_End_Date,
  Scoring_Fn_Quantity, Scoring_Fn_End_Date, Pref_Score_Quantity,
  Pref_Score_End_Date, Phased, Phase_no, Confidence, Success, MIN_Quantity,
  MIN_End_Date, MAX_Quantity, MAX_End_Date, Score_Quantity,
  Score_End_Date, Deviation_Quantity, Deviation_End_Date)
Select DISTINCT
       count(run_Id), count(task_id), Agent, Verb, NSN_Number,
       ClassName, SupplyClass, SupplyType, For_Organization,
       To_Location, Maintain_Type, Maintain_TypeID, Maintain_ItemID,
       Maintain_Nomenclature, Preferred_Quantity, Preferred_End_Date,
       Scoring_Fn_Quantity, Scoring_Fn_End_Date, Pref_Score_Quantity,
       Pref_Score_End_Date, Phased, Phase_no, Confidence, Success,
       min(Quantity) as MIN_Quantity, min(End_Date) as MIN_End_Date,
       max(Quantity) as MAX_Quantity, max(End_Date) as MAX_End_Date,
       max(Score_Quantity) as Score_Quantity, max(Score_End_Date) as
       Score_End_Date, max(Deviation_Quantity) as Deviation_Quantity,
       max(Deviation_End_Date) as Deviation_End_Date
FROM "T_XXbaseXX"
WHERE Verb = 'Supply'
GROUP BY agent, Verb, NSN_Number, ClassName, SupplyClass,
         SupplyType, For_Organization, To_Location, Maintain_Type,
         Maintain_TypeID, Maintain_ItemID, Maintain_Nomenclature,
         Preferred_Quantity, Preferred_End_Date, Scoring_Fn_Quantity,
         Scoring_Fn_End_Date, Pref_Score_Quantity,
         Pref_Score_End_Date, Phased, Phase_no, Confidence, Success;),


      "31_Insert_Baseline" => qq(
INSERT INTO "XXbaseXX"(
  Num_Runs, Num_Tasks, Agent, Verb, NSN_Number, ClassName,
  SupplyClass, SupplyType, For_Organization, To_Location,
  Maintain_Type, Maintain_TypeID, Maintain_ItemID,
  Maintain_Nomenclature, Preferred_Start_Date, Preferred_End_Date,
  Preferred_Rate, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Scoring_Fn_Rate, Pref_Score_Start_Date, Pref_Score_End_Date,
  Pref_Score_Rate, Phased, Phase_no, Confidence, Success, MIN_Start_Date,
  MIN_End_Date, MIN_Rate, MAX_Start_Date, MAX_End_Date, MAX_Rate,
  Score_Start_Date, Score_End_Date, Score_Rate, Deviation_Start_Date,
  Deviation_End_Date, Deviation_Rate)
Select DISTINCT
       count(run_Id), count(task_id), Agent, Verb, NSN_Number,
       ClassName, SupplyClass, SupplyType, For_Organization,
       To_Location, Maintain_Type, Maintain_TypeID, Maintain_ItemID,
       Maintain_Nomenclature, Preferred_Start_Date,
       Preferred_End_Date, Preferred_Rate, Scoring_Fn_Start_Date,
       Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Start_Date,
       Pref_Score_End_Date, Pref_Score_Rate, Phased, Phase_no, Confidence,
       Success, min(Start_Date) as MIN_Start_Date, min(End_Date) as
       MIN_End_Date, min(Rate) as MIN_Rate, max(Start_Date) as
       MAX_Start_Date, max(End_Date) as MAX_End_Date, max(Rate) as
       MAX_Rate, max(Score_Start_Date) as Score_Start_Date,
       max(Score_End_Date) as Score_End_Date, max(Score_Rate) as
       Score_Rate, max(Deviation_Start_Date) as Deviation_Start_Date,
       max(Deviation_End_Date) as Deviation_End_Date,
       max(Deviation_Rate) as Deviation_Rate
FROM "T_XXbaseXX"
WHERE Verb = 'ProjectSupply'
GROUP BY agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
         For_Organization,To_Location, Maintain_Type, Maintain_TypeID,
         Maintain_ItemID, Maintain_Nomenclature, Preferred_Start_Date,
         Preferred_End_Date, Preferred_Rate, Scoring_Fn_Start_Date,
         Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Start_Date,
         Pref_Score_End_Date, Pref_Score_Rate, Phased, Phase_no, Confidence,
         Success;),



     }
    );
  for my $datum (keys %Baseline ) {
    no strict "refs";
    *$datum = sub {
      use strict "refs";
      my ($self, $newvalue) = @_;
      $Baseline{$datum} = $newvalue if @_ > 1;
      return $Baseline{$datum};
    }
  }
}

sub new{
  my $this = shift;
  my %params = @_;
  my $class = ref($this) || $this;
  my $self = {};
  warn "New CnCCalc::Baseline object" if $::ConfOpts{'TRACE_SUBS'};

  bless $self, $class;

  $self->{' _Debug'} = 0;
  return $self;
}

sub create_tables() {
  my $self = shift;
  my %params = @_;

  warn "CnCCalc::Baseline::create_tables" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'DB Handle' missing"
    unless defined $params{'DB Handle'};
  die "Required parameter 'Baseline Name' missing"
    unless defined $params{'Baseline Name'};
  die "Required parameter 'Candidate List' missing"
    unless defined $params{'Candidate List'};

  my $hashref = $self->Tables();
  my $dbh = $params{'DB Handle'};
  my $body = qq(<p>Created entity:</p><ol compact="compact">);

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
  for my $drop_table (@{$self->Clean()}) {
    $drop_table =~ s/XXbaseXX/$params{'Baseline Name'}/g;
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
    #  my ($table) = $table_id =~ /^\d\d_(\S+)/;
    my $count = 0;
    ($count) = $table_id =~ /^(\d\d)/;

    ## We have drop table commands, so we do not check to see if the
    ## table exists. This allows us to interleave commands into the
    ## initialization steps.
    # next if $::ConfOpts{'HaveTable'}{$table};
    my $instruction = $hashref->{$table_id};
    $instruction =~ s/XXbaseXX/$params{'Baseline Name'}/g;
    $instruction =~ s/XXlistXX/$params{'Candidate List'}/g;
    if ($::ConfOpts{'Keep'}) {
      $instruction =~ s/__TEMP__//g;
    }
    else {
      $instruction =~ s/__TEMP__/TEMPORARY/g;
    }
    #
    my $now_string = gmtime;
    my $retval;
    # sleep 10;
    warn "$now_string: doing instruction $count" if $count;
    eval {
      $retval = $dbh->do($instruction);
    };
    if ($@ || ! defined $retval) {
      warn "Instruction number $count failed.";
      warn "undef value returned" unless defined $retval;
      $err = $dbh->errstr;
      warn "$err";
      $body .= "<li>Failed instruction number $count . <br>$@<br></li>\n";
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
      $body .= qq(<li>Instruction $count done.</li>\n);
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

  warn "CnCCalc::Baseline::dump" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'Baseline Name' missing"
    unless defined $params{'Baseline Name'};
  die "Required parameter 'Candidate List' missing"
    unless defined $params{'Candidate List'};

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
    $instruction =~ s/XXbaseXX/$params{'Baseline Name'}/g;
    $instruction =~ s/XXlistXX/$params{'Candidate List'}/g;
    $instruction =~ s/__TEMP__//g;
    $body .= qq(-- $count ($table) \n );
    $body .= qq($instruction \n\n);
  }
  $body .= "\n";
  return $body;
}

1;

__END__;
