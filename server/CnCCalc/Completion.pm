#                              -*- Mode: Perl -*-
# Completion.pm ---
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com )
# Created On       : Wed Apr  2 08:35:51 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Jun 30 11:57:01 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 99
# Status           : Unknown, Use with caution!
# HISTORY          :
# Description      :
#
#

package CnCCalc::Completion;

use strict;
use DBI;
{
  my %Completion =
    (
     'Clean' => [qw("XXbaseXX_XXX_L2" "XXbaseXX_XXX_L6"
                   "XXbaseXX_XXX_Completion"
                   "XXbaseXX_XXX_Matched_L6"
                   "XXbaseXX_XXX_Missing_L6"
                   "XXbaseXX_XXX_MISSING_L2"
                   "XXbaseXX_XXX_MATCHED_L2"
                   "XXbaseXX_XXX_Part_Cred"
                   )],
     'Tables' =>
     {
      #  Select Level 6 tasks in the baseline not present in the
      #  stressed case. These are the tasks for which partial credit
      #  would be given if the corresponding level 2 tasks were indeed
      #  completed correctly.

      #"00_DROP_TABLEXXbaseXX_XXX_L2" => qq(DROP TABLE "XXbaseXX_XXX_L2";),
      "01_CREATE TABLE XXbaseXX_XXX_L2" => qq(
CREATE __TEMP__ TABLE "XXbaseXX_XXX_L2" AS
SELECT * FROM Stressed_XXX
WHERE NSN_Number LIKE 'Level2%';),

      #"03 DROP TABLE XXbaseXX_XXX_L6" => qq(DROP TABLE "XXbaseXX_XXX_L6";),
      "04 CREATE TABLE XXbaseXX_XXX_L6" => qq(
CREATE __TEMP__ TABLE "XXbaseXX_XXX_L6" AS
SELECT * FROM Stressed_XXX
WHERE NSN_Number NOT LIKE 'Level2%';),

      ## This is the final completion table from which results shall be
      ## generated.
      #"05 DROP TABLE Completion" => qq(DROP TABLE "XXbaseXX_XXX_Completion";),
      "06 CREATE TABLE Completion" => qq(
CREATE TABLE "XXbaseXX_XXX_Completion" (
  Run_ID                    integer               default '-1',
  Task_ID                   varchar(255)          default 'NONE SET',
  Agent                     varchar(255) NOT NULL default 'NONE SET',
  Verb                      varchar(255) NOT NULL default 'NONE SET',
  NSN_Number                varchar(255)          default NULL,
  ClassName                 varchar(255)          default NULL,
  SupplyClass               varchar(255)           default NULL,
  SupplyType                varchar(255)           default NULL,
  From_Location             varchar(255)           default NULL,
  For_Organization          varchar(255)           default NULL,
  To_Location               varchar(255)           default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity        double precision      default NULL,
  Preferred_Start_Date      double precision      default NULL,
  Preferred_End_Date        double precision      default NULL,
  Preferred_Rate            double precision      default NULL,
  Scoring_Fn_Quantity       varchar(255)          default NULL,
  Scoring_Fn_Start_Date     varchar(255)          default NULL,
  Scoring_Fn_End_Date       varchar(255)          default NULL,
  Scoring_Fn_Rate           varchar(255)          default NULL,
  Pref_Score_Quantity       double precision      default NULL,
  Pref_Score_Start_Date     double precision      default NULL,
  Pref_Score_End_Date       double precision      default NULL,
  Pref_Score_Rate           double precision      default NULL,
  Quantity                  double precision      default NULL,
  Start_Date                double precision      default NULL,
  End_Date                  double precision      default NULL,
  Rate                      double precision      default NULL,
  Score_Start_Date          double precision      default NULL,
  Score_End_Date            double precision      default NULL,
  Score_Quantity            double precision      default NULL,
  Score_Rate                double precision      default NULL,
  Phased                    char(1)               default NULL,
  Phase_no                  integer               default NULL,
  Confidence                double precision      default NULL,
  Success                   char(1)               default NULL,
  Deviation_Quantity        double precision      default NULL,
  Deviation_Start_Date      double precision      default NULL,
  Deviation_End_Date        double precision      default NULL,
  Deviation_Rate            double precision      default NULL,
  Base_Deviation_Quantity   double precision      default NULL,
  Base_Deviation_Start_Date double precision      default NULL,
  Base_Deviation_End_Date   double precision      default NULL,
  Base_Deviation_Rate       double precision      default NULL,
  Dev_Is_CC_Quantity        smallint              default NULL,
  Dev_Is_CC_Start_Date      smallint              default NULL,
  Dev_Is_CC_End_Date        smallint              default NULL,
  Dev_Is_CC_Rate            smallint              default NULL,
  Is_CC_Quantity            smallint              default NULL,
  Is_CC_Start_Date          smallint              default NULL,
  Is_CC_End_Date            smallint              default NULL,
  Is_CC_Rate                smallint              default NULL

);),

#  CONSTRAINT "XXbaseXX_XXX_Comp_pkey" PRIMARY KEY ( Run_ID, Task_ID ),
#  CONSTRAINT "XXbaseXX_XXX_Comp__of" FOREIGN KEY (run_id) REFERENCES 
#             runs (id)
#             DEFERRABLE

      ## Matching directly the level 6 tasks: Transport
      "07 INSERT INTO XXbaseXX_XXX_Completion" => qq(
INSERT INTO "XXbaseXX_XXX_Completion" (
  Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName,
  From_Location, To_Location, Preferred_Start_Date,
  Preferred_End_Date, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Pref_Score_Start_Date, Pref_Score_End_Date, Start_Date, End_Date,
  Score_Start_Date, Score_End_Date, Phased, Phase_no, Confidence, Success,
  Deviation_Start_Date, Deviation_End_Date, Base_Deviation_Start_Date,
  Base_Deviation_End_Date, Dev_Is_CC_Start_Date, Dev_Is_CC_End_Date,
  Is_CC_Start_Date, Is_CC_End_Date)
SELECT DISTINCT "XXbaseXX_XXX_L6".Run_ID,
                "XXbaseXX_XXX_L6".Task_ID,
                case
                when "XXbaseXX_XXX_L6".Agent IS NULL
                     then "XXbaseXX".Agent
                else "XXbaseXX_XXX_L6".Agent
                end,
                case
                when "XXbaseXX_XXX_L6".Verb IS NULL
                     then "XXbaseXX".Verb
                else "XXbaseXX_XXX_L6".Verb
                end,
                case
                when "XXbaseXX_XXX_L6".NSN_Number IS NULL
                     then "XXbaseXX".NSN_Number
                else "XXbaseXX_XXX_L6".NSN_Number
                end,
                case
                when "XXbaseXX_XXX_L6".ClassName IS NULL
                     then "XXbaseXX".ClassName
                else "XXbaseXX_XXX_L6".ClassName
                end,
                case
                when "XXbaseXX_XXX_L6".From_Location IS NULL
                     then "XXbaseXX".From_Location
                else "XXbaseXX_XXX_L6".From_Location
                end,
                case
                when "XXbaseXX_XXX_L6".To_Location IS NULL
                     then "XXbaseXX".To_Location
                else "XXbaseXX_XXX_L6".To_Location
                end,
                case
                when "XXbaseXX_XXX_L6".Preferred_Start_Date IS NULL
                     then "XXbaseXX".Preferred_Start_Date
                else "XXbaseXX_XXX_L6".Preferred_Start_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Preferred_End_Date IS NULL
                     then "XXbaseXX".Preferred_End_Date
                else "XXbaseXX_XXX_L6".Preferred_End_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Scoring_Fn_Start_Date IS NULL
                     then "XXbaseXX".Scoring_Fn_Start_Date
                else "XXbaseXX_XXX_L6".Scoring_Fn_Start_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Scoring_Fn_End_Date IS NULL
                     then "XXbaseXX".Scoring_Fn_End_Date
                else "XXbaseXX_XXX_L6".Scoring_Fn_End_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Pref_Score_Start_Date IS NULL
                     then "XXbaseXX".Pref_Score_Start_Date
                else "XXbaseXX_XXX_L6".Pref_Score_Start_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Pref_Score_End_Date IS NULL
                     then "XXbaseXX".Pref_Score_End_Date
                else "XXbaseXX_XXX_L6".Pref_Score_End_Date
                end,
                "XXbaseXX_XXX_L6".Start_Date,
                "XXbaseXX_XXX_L6".End_Date,
                "XXbaseXX_XXX_L6".Score_Start_Date,
                "XXbaseXX_XXX_L6".Score_End_Date,
                "XXbaseXX_XXX_L6".Phased,
                "XXbaseXX_XXX_L6".Phase_no,
                "XXbaseXX_XXX_L6".Confidence,
                "XXbaseXX_XXX_L6".Success,
                "XXbaseXX_XXX_L6".Score_Start_Date,
                "XXbaseXX_XXX_L6".Score_End_Date,
                "XXbaseXX".Score_Start_Date,
                "XXbaseXX".Score_End_Date,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Success    = '0'             then 0
                when "XXbaseXX_XXX_L6".Deviation_Start_Date IS NULL then NULL
                when "XXbaseXX".Deviation_Start_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Deviation_Start_Date >
                              0.05 + "XXbaseXX".Deviation_Start_Date then 0
                else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Success    = '0'             then 0
                when "XXbaseXX_XXX_L6".Deviation_End_Date IS NULL then NULL
                when "XXbaseXX".Deviation_End_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Deviation_End_Date >
                              0.05 + "XXbaseXX".Deviation_End_Date then 0
                     else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Score_Start_Date IS NULL then NULL
                when "XXbaseXX".Score_Start_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Score_Start_Date >
                     "XXbaseXX".Score_Start_Date         then 0
                else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Score_End_Date IS NULL then NULL
                when "XXbaseXX".Score_End_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Score_End_Date >
                     "XXbaseXX".Score_End_Date          then 0
                     else 1
                end
FROM "XXbaseXX_XXX_L6", "XXbaseXX"
WHERE     "XXbaseXX_XXX_L6".Agent                = "XXbaseXX".Agent
      AND "XXbaseXX_XXX_L6".Verb                 = "XXbaseXX".Verb
      AND "XXbaseXX_XXX_L6".NSN_Number           = "XXbaseXX".NSN_Number
      AND "XXbaseXX_XXX_L6".ClassName            = "XXbaseXX".ClassName
      AND "XXbaseXX_XXX_L6".To_Location          = "XXbaseXX".To_Location
      AND "XXbaseXX_XXX_L6".From_Location        = "XXbaseXX".From_Location
      AND "XXbaseXX_XXX_L6".Preferred_End_Date   = "XXbaseXX".Preferred_End_Date
      AND "XXbaseXX_XXX_L6".Preferred_Start_Date = "XXbaseXX".Preferred_Start_Date
      AND "XXbaseXX_XXX_L6".Phase_no             = "XXbaseXX".Phase_no
      AND "XXbaseXX_XXX_L6".Phased               = "XXbaseXX".Phased 
      AND "XXbaseXX_XXX_L6".Verb                 = 'Transport';),


      ## Matching directly the level 6 tasks: Supply
      "08 INSERT INTO XXbaseXX_XXX_Completion" => qq(
INSERT INTO "XXbaseXX_XXX_Completion"(
  Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, For_Organization, To_Location, Maintain_Type,
  Maintain_TypeID, Maintain_ItemID, Maintain_Nomenclature,
  Preferred_Quantity, Preferred_End_Date, Scoring_Fn_Quantity,
  Scoring_Fn_End_Date, Pref_Score_Quantity, Pref_Score_End_Date,
  Quantity, End_Date, Score_Quantity, Score_End_Date, Phased, Phase_no,
  Confidence, Success, Deviation_Quantity, Deviation_End_Date,
  Base_Deviation_Quantity, Base_Deviation_End_Date,
  Dev_Is_CC_Quantity, Dev_Is_CC_End_Date, Is_CC_Quantity,
  Is_CC_End_Date)
SELECT DISTINCT "XXbaseXX_XXX_L6".Run_ID,
                "XXbaseXX_XXX_L6".Task_ID,
                case
                when "XXbaseXX_XXX_L6".Agent IS NULL then "XXbaseXX".Agent
                else "XXbaseXX_XXX_L6".Agent
                end,
                case
                when "XXbaseXX_XXX_L6".Verb IS NULL
                     then "XXbaseXX".Verb
                else "XXbaseXX_XXX_L6".Verb
                end,
                case
                when "XXbaseXX_XXX_L6".NSN_Number IS NULL
                     then "XXbaseXX".NSN_Number
                else "XXbaseXX_XXX_L6".NSN_Number
                end,
                case
                when "XXbaseXX_XXX_L6".ClassName IS NULL
                     then "XXbaseXX".ClassName
                else "XXbaseXX_XXX_L6".ClassName
                end,
                case
                when "XXbaseXX_XXX_L6".SupplyClass IS NULL
                     then "XXbaseXX".SupplyClass
                else "XXbaseXX_XXX_L6".SupplyClass
                end,
                case
                when "XXbaseXX_XXX_L6".SupplyType IS NULL
                     then "XXbaseXX".SupplyType
                else "XXbaseXX_XXX_L6".SupplyType
                end,
                case
                when "XXbaseXX_XXX_L6".For_Organization IS NULL
                     then "XXbaseXX".For_Organization
                else "XXbaseXX_XXX_L6".For_Organization
                end,
                case
                when "XXbaseXX_XXX_L6".To_Location IS NULL
                     then "XXbaseXX".To_Location
                else "XXbaseXX_XXX_L6".To_Location
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_Type IS NULL
                     then "XXbaseXX".Maintain_Type
                else "XXbaseXX_XXX_L6".Maintain_Type
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_TypeID IS NULL
                     then "XXbaseXX".Maintain_TypeID
                else "XXbaseXX_XXX_L6".Maintain_TypeID
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_ItemID IS NULL
                     then "XXbaseXX".Maintain_ItemID
                else "XXbaseXX_XXX_L6".Maintain_ItemID
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_Nomenclature IS NULL
                     then "XXbaseXX".Maintain_Nomenclature
                else "XXbaseXX_XXX_L6".Maintain_Nomenclature
                end,
                case
                when "XXbaseXX_XXX_L6".Preferred_Quantity IS NULL
                     then "XXbaseXX".Preferred_Quantity
                else "XXbaseXX_XXX_L6".Preferred_Quantity
                end,
                case
                when "XXbaseXX_XXX_L6".Preferred_End_Date IS NULL
                then "XXbaseXX".Preferred_End_Date
                else "XXbaseXX_XXX_L6".Preferred_End_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Scoring_Fn_Quantity IS NULL
                then "XXbaseXX".Scoring_Fn_Quantity
                else "XXbaseXX_XXX_L6".Scoring_Fn_Quantity
                end,
                case
                when "XXbaseXX_XXX_L6".Scoring_Fn_End_Date IS NULL
                then "XXbaseXX".Scoring_Fn_End_Date
                else "XXbaseXX_XXX_L6".Scoring_Fn_End_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Pref_Score_Quantity IS NULL
                then "XXbaseXX".Pref_Score_Quantity
                else "XXbaseXX_XXX_L6".Pref_Score_Quantity
                end,
                case
                when "XXbaseXX_XXX_L6".Pref_Score_End_Date IS NULL
                then "XXbaseXX".Pref_Score_End_Date
                else "XXbaseXX_XXX_L6".Pref_Score_End_Date
                end,
                "XXbaseXX_XXX_L6".Quantity,
                "XXbaseXX_XXX_L6".End_Date,
                "XXbaseXX_XXX_L6".Score_Quantity,
                "XXbaseXX_XXX_L6".Score_End_Date,
                "XXbaseXX_XXX_L6".Phased,
                "XXbaseXX_XXX_L6".Phase_no,
                "XXbaseXX_XXX_L6".Confidence,
                "XXbaseXX_XXX_L6".Success,
                "XXbaseXX_XXX_L6".Score_Quantity,
                "XXbaseXX_XXX_L6".Score_End_Date ,
                "XXbaseXX".Score_Quantity,
                "XXbaseXX".Score_End_Date ,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Success    = '0'             then 0
                when "XXbaseXX_XXX_L6".Deviation_Quantity IS NULL then NULL
                when "XXbaseXX".Deviation_Quantity IS NULL then 1
                when "XXbaseXX_XXX_L6".Deviation_Quantity >
                                    0.05 + "XXbaseXX".Deviation_Quantity then 0
                else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Success    = '0'             then 0
                when "XXbaseXX_XXX_L6".Deviation_End_Date IS NULL then NULL
                when "XXbaseXX".Deviation_End_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Deviation_End_Date  >
                                    0.05 + "XXbaseXX".Deviation_End_Date then 0
                else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Score_Quantity IS NULL then NULL
                when "XXbaseXX".Score_Quantity IS NULL then 1
                when "XXbaseXX_XXX_L6".Score_Quantity >
                     "XXbaseXX".Score_Quantity then 0
                else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Score_End_Date IS NULL then NULL
                when "XXbaseXX".Score_End_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Score_End_Date  >
                     "XXbaseXX".Score_End_Date then 0
                else 1
                end
FROM "XXbaseXX_XXX_L6", "XXbaseXX"
WHERE     "XXbaseXX_XXX_L6".Agent                = "XXbaseXX".Agent
      AND "XXbaseXX_XXX_L6".Verb                 = "XXbaseXX".Verb
      AND "XXbaseXX_XXX_L6".NSN_Number           = "XXbaseXX".NSN_Number
      AND "XXbaseXX_XXX_L6".ClassName            = "XXbaseXX".ClassName
      AND "XXbaseXX_XXX_L6".SupplyClass          = "XXbaseXX".SupplyClass
      AND "XXbaseXX_XXX_L6".SupplyType           = "XXbaseXX".SupplyType
      AND "XXbaseXX_XXX_L6".For_Organization     = "XXbaseXX".For_Organization
      AND "XXbaseXX_XXX_L6".To_Location          = "XXbaseXX".To_Location
      AND "XXbaseXX_XXX_L6".Maintain_TypeID      = "XXbaseXX".Maintain_TypeID
      AND "XXbaseXX_XXX_L6".Maintain_Type        = "XXbaseXX".Maintain_Type
      AND "XXbaseXX_XXX_L6".Maintain_ItemID      = "XXbaseXX".Maintain_ItemID
      AND "XXbaseXX_XXX_L6".Maintain_Nomenclature= "XXbaseXX".Maintain_Nomenclature
      AND "XXbaseXX_XXX_L6".Preferred_Quantity   = "XXbaseXX".Preferred_Quantity
      AND "XXbaseXX_XXX_L6".Preferred_End_Date   = "XXbaseXX".Preferred_End_Date
      AND "XXbaseXX_XXX_L6".Phase_no             = "XXbaseXX".Phase_no
      AND "XXbaseXX_XXX_L6".Phased               = "XXbaseXX".Phased 
      AND "XXbaseXX_XXX_L6".Verb                 = 'Supply';),

      ## Matching directly the level 6 tasks: ProjectSupply
      "09 INSERT INTO XXbaseXX_XXX_Completion" => qq(
INSERT INTO "XXbaseXX_XXX_Completion"(
  Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, For_Organization, To_Location, Maintain_Type,
  Maintain_TypeID, Maintain_ItemID, Maintain_Nomenclature,
  Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
  Scoring_Fn_Start_Date, Scoring_Fn_End_Date, Scoring_Fn_Rate,
  Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
  Start_Date, End_Date, Rate, Score_Start_Date, Score_End_Date,
  Score_Rate, Phased, Phase_no, Confidence, Success, Deviation_Start_Date,
  Deviation_End_Date, Deviation_Rate, Base_Deviation_Start_Date,
  Base_Deviation_End_Date, Base_Deviation_Rate, Dev_Is_CC_Start_Date,
  Dev_Is_CC_End_Date, Dev_Is_CC_Rate, Is_CC_Start_Date,
  Is_CC_End_Date, Is_CC_Rate)
SELECT DISTINCT "XXbaseXX_XXX_L6".Run_ID,
                "XXbaseXX_XXX_L6".Task_ID,
                case
                when "XXbaseXX_XXX_L6".Agent IS NULL
                then "XXbaseXX".Agent
                else "XXbaseXX_XXX_L6".Agent
                end,
                case
                when "XXbaseXX_XXX_L6".Verb IS NULL
                then "XXbaseXX".Verb
                else "XXbaseXX_XXX_L6".Verb
                end,
                case
                when "XXbaseXX_XXX_L6".NSN_Number IS NULL
                then "XXbaseXX".NSN_Number
                else "XXbaseXX_XXX_L6".NSN_Number
                end,
                case
                when "XXbaseXX_XXX_L6".ClassName IS NULL
                     then "XXbaseXX".ClassName
                else "XXbaseXX_XXX_L6".ClassName
                end,
                case
                when "XXbaseXX_XXX_L6".SupplyClass IS NULL
                then "XXbaseXX".SupplyClass
                else "XXbaseXX_XXX_L6".SupplyClass
                end,
                case
                when "XXbaseXX_XXX_L6".SupplyType IS NULL
                then "XXbaseXX".SupplyType
                else "XXbaseXX_XXX_L6".SupplyType
                end,
                case
                when "XXbaseXX_XXX_L6".For_Organization IS NULL
                then "XXbaseXX".For_Organization
                else "XXbaseXX_XXX_L6".For_Organization
                end,
                case
                when "XXbaseXX_XXX_L6".To_Location IS NULL
                then "XXbaseXX".To_Location
                else "XXbaseXX_XXX_L6".To_Location
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_Type IS NULL
                then "XXbaseXX".Maintain_Type
                else "XXbaseXX_XXX_L6".Maintain_Type
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_TypeID IS NULL
                then "XXbaseXX".Maintain_TypeID
                else "XXbaseXX_XXX_L6".Maintain_TypeID
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_ItemID IS NULL
                then "XXbaseXX".Maintain_ItemID
                else "XXbaseXX_XXX_L6".Maintain_ItemID
                end,
                case
                when "XXbaseXX_XXX_L6".Maintain_Nomenclature IS NULL
                then "XXbaseXX".Maintain_Nomenclature
                else "XXbaseXX_XXX_L6".Maintain_Nomenclature
                end,
                case
                when "XXbaseXX_XXX_L6".Preferred_Start_Date IS NULL
                then "XXbaseXX".Preferred_Start_Date
                else "XXbaseXX_XXX_L6".Preferred_Start_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Preferred_End_Date IS NULL
                then "XXbaseXX".Preferred_End_Date
                else "XXbaseXX_XXX_L6".Preferred_End_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Preferred_Rate IS NULL
                then "XXbaseXX".Preferred_Rate
                else "XXbaseXX_XXX_L6".Preferred_Rate
                end,
                case
                when "XXbaseXX_XXX_L6".Scoring_Fn_Start_Date IS NULL
                then "XXbaseXX".Scoring_Fn_Start_Date
                else "XXbaseXX_XXX_L6".Scoring_Fn_Start_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Scoring_Fn_End_Date IS NULL
                then "XXbaseXX".Scoring_Fn_End_Date
                else "XXbaseXX_XXX_L6".Scoring_Fn_End_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Scoring_Fn_Rate IS NULL
                then "XXbaseXX".Scoring_Fn_Rate
                else "XXbaseXX_XXX_L6".Scoring_Fn_Rate
                end,
                case
                when "XXbaseXX_XXX_L6".Pref_Score_Start_Date IS NULL
                then "XXbaseXX".Pref_Score_Start_Date
                else "XXbaseXX_XXX_L6".Pref_Score_Start_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Pref_Score_End_Date IS NULL
                then "XXbaseXX".Pref_Score_End_Date
                else "XXbaseXX_XXX_L6".Pref_Score_End_Date
                end,
                case
                when "XXbaseXX_XXX_L6".Pref_Score_Rate IS NULL
                then "XXbaseXX".Pref_Score_Rate
                else "XXbaseXX_XXX_L6".Pref_Score_Rate
                end,
                "XXbaseXX_XXX_L6".Start_Date,
                "XXbaseXX_XXX_L6".End_Date,
                "XXbaseXX_XXX_L6".Rate,
                "XXbaseXX_XXX_L6".Score_Start_Date,
                "XXbaseXX_XXX_L6".Score_End_Date,
                "XXbaseXX_XXX_L6".Score_Rate,
                "XXbaseXX_XXX_L6".Phased,
                "XXbaseXX_XXX_L6".Phase_no,
                "XXbaseXX_XXX_L6".Confidence,
                "XXbaseXX_XXX_L6".Success,
                "XXbaseXX_XXX_L6".Score_Start_Date,
                "XXbaseXX_XXX_L6".Score_End_Date ,
                "XXbaseXX_XXX_L6".Score_Rate,
                "XXbaseXX".Score_Start_Date,
                "XXbaseXX".Score_End_Date ,
                "XXbaseXX".Score_Rate ,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Success    = '0'             then 0
                when "XXbaseXX_XXX_L6".Deviation_Start_Date IS NULL then NULL
                when "XXbaseXX".Deviation_Start_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Deviation_Start_Date >
                                    0.05 + "XXbaseXX".Deviation_Start_Date then 0
                else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Success    = '0'             then 0
                when "XXbaseXX_XXX_L6".Deviation_End_Date IS NULL then NULL
                when "XXbaseXX".Deviation_End_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Deviation_End_Date  >
                                    0.05 + "XXbaseXX".Deviation_End_Date then 0
                else  1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Success    = '0'             then 0
                when "XXbaseXX_XXX_L6".Deviation_Rate IS NULL then NULL
                when "XXbaseXX".Deviation_Rate IS NULL then 1
                when "XXbaseXX_XXX_L6".Deviation_Rate  >
                                    0.05 + "XXbaseXX".Deviation_Rate then 0
                else  1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Score_Start_Date IS NULL then NULL
                when "XXbaseXX".Score_Start_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Score_Start_Date >
                     "XXbaseXX".Score_Start_Date         then 0
                else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Score_End_Date IS NULL then NULL
                when "XXbaseXX".Score_End_Date IS NULL then 1
                when "XXbaseXX_XXX_L6".Score_End_Date >
                     "XXbaseXX".Score_End_Date          then 0
                     else 1
                end,
                case
                when "XXbaseXX_XXX_L6".Confidence < 0.89            then NULL
                when "XXbaseXX_XXX_L6".Score_Rate IS NULL then NULL
                when "XXbaseXX".Score_Rate IS NULL then 1
                when "XXbaseXX_XXX_L6".Score_Rate >
                     "XXbaseXX".Score_Rate          then 0
                     else 1
                end
FROM "XXbaseXX_XXX_L6", "XXbaseXX"
WHERE     "XXbaseXX_XXX_L6".Agent                = "XXbaseXX".Agent
      AND "XXbaseXX_XXX_L6".Verb                 = "XXbaseXX".Verb
      AND "XXbaseXX_XXX_L6".NSN_Number           = "XXbaseXX".NSN_Number
      AND "XXbaseXX_XXX_L6".ClassName            = "XXbaseXX".ClassName
      AND "XXbaseXX_XXX_L6".SupplyClass          = "XXbaseXX".SupplyClass
      AND "XXbaseXX_XXX_L6".SupplyType           = "XXbaseXX".SupplyType
      AND "XXbaseXX_XXX_L6".For_Organization     = "XXbaseXX".For_Organization
      AND "XXbaseXX_XXX_L6".To_Location          = "XXbaseXX".To_Location
      AND "XXbaseXX_XXX_L6".Maintain_Type        = "XXbaseXX".Maintain_Type
      AND "XXbaseXX_XXX_L6".Maintain_TypeID      = "XXbaseXX".Maintain_TypeID
      AND "XXbaseXX_XXX_L6".Maintain_ItemID      = "XXbaseXX".Maintain_ItemID
      AND "XXbaseXX_XXX_L6".Maintain_Nomenclature= "XXbaseXX".Maintain_Nomenclature
      AND "XXbaseXX_XXX_L6".Preferred_Start_Date = "XXbaseXX".Preferred_Start_Date
      AND "XXbaseXX_XXX_L6".Preferred_End_Date   = "XXbaseXX".Preferred_End_Date
      AND "XXbaseXX_XXX_L6".Phase_no             = "XXbaseXX".Phase_no
      AND "XXbaseXX_XXX_L6".Phased               = "XXbaseXX".Phased
      AND "XXbaseXX_XXX_L6".Verb                 = 'ProjectSupply';),

      # Create a table for all level 6 tasks that matched
      #"10 drop table" => qq(drop table "XXbaseXX_XXX_Matched_L6";),

      "11 CREATE TABLE XXbaseXX_XXX_Matched_L6" => qq(
CREATE __TEMP__ TABLE "XXbaseXX_XXX_Matched_L6"
(
  run_id                bigint,
  task_id               varchar(255), 
  num_runs              integer,
  num_tasks             integer,
  Agent                     varchar(255) NOT NULL default '',
  Verb                      varchar(31) NOT NULL default '',
  NSN_Number                varchar(255)          default NULL,
  ClassName                 varchar(255)         default NULL,
  SupplyClass               varchar(255)          default NULL,
  SupplyType                varchar(255)          default NULL,
  From_Location             varchar(255)          default NULL,
  For_Organization          varchar(255)          default NULL,
  To_Location               varchar(255)          default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity        double precision                default NULL,
  Preferred_Start_Date      double precision              default NULL,
  Preferred_End_Date        double precision              default NULL,
  Preferred_Rate            double precision              default NULL,
  Phased                    char(1)               default NULL,
  Phase_no                  integer                       default NULL,
  Confidence                double precision              default NULL,
  Success                       char(1)                       default NULL,
  MIN_Quantity              double precision                default NULL,
  MIN_Start_Date            double precision              default NULL,
  MIN_End_Date              double precision              default NULL,
  MIN_Rate                  double precision                default NULL,
  MAX_Quantity              double precision                default NULL,
  MAX_Start_Date            double precision              default NULL,
  MAX_End_Date              double precision              default NULL,
  MAX_Rate                  double precision                default NULL,
  Score_Quantity        double precision               default NULL,
  Score_Start_Date      double precision               default NULL,
  Score_End_Date        double precision               default NULL,
  Score_Rate            double precision               default NULL,
  Deviation_Quantity        double precision                default NULL,
  Deviation_Start_Date      double precision                default NULL,
  Deviation_End_Date        double precision                default NULL,
  Deviation_Rate            double precision                default NULL,
  Scoring_Fn_Quantity           varchar(255)         default NULL,
  Scoring_Fn_Start_Date         varchar(255)         default NULL,
  Scoring_Fn_End_Date           varchar(255)         default NULL,
  Scoring_Fn_Rate               varchar(255)         default NULL,
  Pref_Score_Quantity           double precision                default NULL,
  Pref_Score_Start_Date         double precision              default NULL,
  Pref_Score_End_Date           double precision                default NULL,
  Pref_Score_Rate               double precision                default NULL
);),

      ## populate the matched table: transport
      "12 INSERT INTO XXbaseXX_XXX_Matched_L6" => qq(
INSERT INTO "XXbaseXX_XXX_Matched_L6"
SELECT "XXbaseXX_XXX_L6".run_id, "XXbaseXX_XXX_L6".task_id, 
       "XXbaseXX".num_runs, "XXbaseXX".num_tasks,
       "XXbaseXX".Agent, "XXbaseXX".Verb, "XXbaseXX".NSN_Number,
       "XXbaseXX".ClassName, "XXbaseXX".SupplyClass, "XXbaseXX".SupplyType,
       "XXbaseXX".From_Location, "XXbaseXX".For_Organization,
       "XXbaseXX".To_Location, "XXbaseXX".Maintain_Type,
       "XXbaseXX".Maintain_TypeID, "XXbaseXX".Maintain_ItemID,
       "XXbaseXX".Maintain_Nomenclature, "XXbaseXX".Preferred_Quantity,
       "XXbaseXX".Preferred_Start_Date, "XXbaseXX".Preferred_End_Date,
       "XXbaseXX".Preferred_Rate, "XXbaseXX".Phased, "XXbaseXX".Phase_no,
       "XXbaseXX".Confidence, "XXbaseXX".Success, "XXbaseXX".MIN_Quantity,
       "XXbaseXX".MIN_Start_Date, "XXbaseXX".MIN_End_Date,
       "XXbaseXX".MIN_Rate, "XXbaseXX".MAX_Quantity,
       "XXbaseXX".MAX_Start_Date, "XXbaseXX".MAX_End_Date,
       "XXbaseXX".MAX_Rate, "XXbaseXX".Score_Quantity,
       "XXbaseXX".Score_Start_Date, "XXbaseXX".Score_End_Date,
       "XXbaseXX".Score_Rate, "XXbaseXX".Deviation_Quantity,
       "XXbaseXX".Deviation_Start_Date, "XXbaseXX".Deviation_End_Date,
       "XXbaseXX".Deviation_Rate, "XXbaseXX".Scoring_Fn_Quantity,
       "XXbaseXX".Scoring_Fn_Start_Date, "XXbaseXX".Scoring_Fn_End_Date,
       "XXbaseXX".Scoring_Fn_Rate, "XXbaseXX".Pref_Score_Quantity,
       "XXbaseXX".Pref_Score_Start_Date, "XXbaseXX".Pref_Score_End_Date,
       "XXbaseXX".Pref_Score_Rate
FROM  "XXbaseXX" LEFT OUTER JOIN "XXbaseXX_XXX_L6"
ON    (   "XXbaseXX_XXX_L6".Agent                = "XXbaseXX".Agent
      AND "XXbaseXX_XXX_L6".Verb                 = "XXbaseXX".Verb
      AND "XXbaseXX_XXX_L6".NSN_Number           = "XXbaseXX".NSN_Number
      AND "XXbaseXX_XXX_L6".ClassName            = "XXbaseXX".ClassName
      AND "XXbaseXX_XXX_L6".To_Location          = "XXbaseXX".To_Location
      AND "XXbaseXX_XXX_L6".From_Location        = "XXbaseXX".From_Location
      AND "XXbaseXX_XXX_L6".Preferred_End_Date   = "XXbaseXX".Preferred_End_Date
      AND "XXbaseXX_XXX_L6".Preferred_Start_Date = "XXbaseXX".Preferred_Start_Date
      AND "XXbaseXX_XXX_L6".Phase_no             = "XXbaseXX".Phase_no
      AND "XXbaseXX_XXX_L6".Phased               = "XXbaseXX".Phased)
WHERE "XXbaseXX".Verb                        = 'Transport';),

      ## populate the matched table: supply
      "13 INSERT INTO XXbaseXX_XXX_Matched_L6" => qq(
INSERT INTO "XXbaseXX_XXX_Matched_L6"
SELECT "XXbaseXX_XXX_L6".run_id, "XXbaseXX_XXX_L6".task_id, 
       "XXbaseXX".num_runs, "XXbaseXX".num_tasks,
       "XXbaseXX".Agent, "XXbaseXX".Verb, "XXbaseXX".NSN_Number,
       "XXbaseXX".ClassName, "XXbaseXX".SupplyClass, "XXbaseXX".SupplyType,
       "XXbaseXX".From_Location, "XXbaseXX".For_Organization,
       "XXbaseXX".To_Location, "XXbaseXX".Maintain_Type,
       "XXbaseXX".Maintain_TypeID, "XXbaseXX".Maintain_ItemID,
       "XXbaseXX".Maintain_Nomenclature, "XXbaseXX".Preferred_Quantity,
       "XXbaseXX".Preferred_Start_Date, "XXbaseXX".Preferred_End_Date,
       "XXbaseXX".Preferred_Rate, "XXbaseXX".Phased, "XXbaseXX".Phase_no,
       "XXbaseXX".Confidence, "XXbaseXX".Success, "XXbaseXX".MIN_Quantity,
       "XXbaseXX".MIN_Start_Date, "XXbaseXX".MIN_End_Date,
       "XXbaseXX".MIN_Rate, "XXbaseXX".MAX_Quantity,
       "XXbaseXX".MAX_Start_Date, "XXbaseXX".MAX_End_Date,
       "XXbaseXX".MAX_Rate, "XXbaseXX".Score_Quantity,
       "XXbaseXX".Score_Start_Date, "XXbaseXX".Score_End_Date,
       "XXbaseXX".Score_Rate, "XXbaseXX".Deviation_Quantity,
       "XXbaseXX".Deviation_Start_Date, "XXbaseXX".Deviation_End_Date,
       "XXbaseXX".Deviation_Rate, "XXbaseXX".Scoring_Fn_Quantity,
       "XXbaseXX".Scoring_Fn_Start_Date, "XXbaseXX".Scoring_Fn_End_Date,
       "XXbaseXX".Scoring_Fn_Rate, "XXbaseXX".Pref_Score_Quantity,
       "XXbaseXX".Pref_Score_Start_Date, "XXbaseXX".Pref_Score_End_Date,
       "XXbaseXX".Pref_Score_Rate
FROM  "XXbaseXX" LEFT OUTER JOIN "XXbaseXX_XXX_L6"
ON   (    "XXbaseXX_XXX_L6".Agent                = "XXbaseXX".Agent
      AND "XXbaseXX_XXX_L6".Verb                 = "XXbaseXX".Verb
      AND "XXbaseXX_XXX_L6".NSN_Number           = "XXbaseXX".NSN_Number
      AND "XXbaseXX_XXX_L6".ClassName            = "XXbaseXX".ClassName
      AND "XXbaseXX_XXX_L6".SupplyClass          = "XXbaseXX".SupplyClass
      AND "XXbaseXX_XXX_L6".SupplyType           = "XXbaseXX".SupplyType
      AND "XXbaseXX_XXX_L6".For_Organization     = "XXbaseXX".For_Organization
      AND "XXbaseXX_XXX_L6".To_Location          = "XXbaseXX".To_Location
      AND "XXbaseXX_XXX_L6".Maintain_Type        = "XXbaseXX".Maintain_Type
      AND "XXbaseXX_XXX_L6".Maintain_TypeID      = "XXbaseXX".Maintain_TypeID
      AND "XXbaseXX_XXX_L6".Maintain_ItemID      = "XXbaseXX".Maintain_ItemID
      AND "XXbaseXX_XXX_L6".Maintain_Nomenclature= "XXbaseXX".Maintain_Nomenclature
      AND "XXbaseXX_XXX_L6".Preferred_Quantity = "XXbaseXX".Preferred_Quantity
      AND "XXbaseXX_XXX_L6".Preferred_End_Date = "XXbaseXX".Preferred_End_Date
      AND "XXbaseXX_XXX_L6".Phase_no           = "XXbaseXX".Phase_no
      AND "XXbaseXX_XXX_L6".Phased             = "XXbaseXX".Phased)
WHERE "XXbaseXX".Verb                      = 'Supply';),

      ## populate the matched table: projectsupply
      "14 INSERT INTO XXbaseXX_XXX_Matched_L6" => qq(
INSERT INTO "XXbaseXX_XXX_Matched_L6"
SELECT "XXbaseXX_XXX_L6".run_id, "XXbaseXX_XXX_L6".task_id, 
       "XXbaseXX".num_runs, "XXbaseXX".num_tasks,
       "XXbaseXX".Agent, "XXbaseXX".Verb, "XXbaseXX".NSN_Number,
       "XXbaseXX".ClassName, "XXbaseXX".SupplyClass, "XXbaseXX".SupplyType,
       "XXbaseXX".From_Location, 
       "XXbaseXX".For_Organization, "XXbaseXX".To_Location,
       "XXbaseXX".Maintain_Type,
       "XXbaseXX".Maintain_TypeID, "XXbaseXX".Maintain_ItemID,
       "XXbaseXX".Maintain_Nomenclature, "XXbaseXX".Preferred_Quantity,
       "XXbaseXX".Preferred_Start_Date, "XXbaseXX".Preferred_End_Date,
       "XXbaseXX".Preferred_Rate, "XXbaseXX".Phased, "XXbaseXX".Phase_no,
       "XXbaseXX".Confidence, "XXbaseXX".Success, "XXbaseXX".MIN_Quantity,
       "XXbaseXX".MIN_Start_Date, "XXbaseXX".MIN_End_Date,
       "XXbaseXX".MIN_Rate, "XXbaseXX".MAX_Quantity,
       "XXbaseXX".MAX_Start_Date, "XXbaseXX".MAX_End_Date,
       "XXbaseXX".MAX_Rate, "XXbaseXX".Score_Quantity,
       "XXbaseXX".Score_Start_Date, "XXbaseXX".Score_End_Date,
       "XXbaseXX".Score_Rate, "XXbaseXX".Deviation_Quantity,
       "XXbaseXX".Deviation_Start_Date, "XXbaseXX".Deviation_End_Date,
       "XXbaseXX".Deviation_Rate, "XXbaseXX".Scoring_Fn_Quantity,
       "XXbaseXX".Scoring_Fn_Start_Date, "XXbaseXX".Scoring_Fn_End_Date,
       "XXbaseXX".Scoring_Fn_Rate, "XXbaseXX".Pref_Score_Quantity,
       "XXbaseXX".Pref_Score_Start_Date, "XXbaseXX".Pref_Score_End_Date,
       "XXbaseXX".Pref_Score_Rate
FROM "XXbaseXX" LEFT OUTER JOIN "XXbaseXX_XXX_L6"
ON   (
     "XXbaseXX_XXX_L6".Agent                = "XXbaseXX".Agent
 AND "XXbaseXX_XXX_L6".Verb                 = "XXbaseXX".Verb
 AND "XXbaseXX_XXX_L6".NSN_Number           = "XXbaseXX".NSN_Number
 AND "XXbaseXX_XXX_L6".ClassName            = "XXbaseXX".ClassName
 AND "XXbaseXX_XXX_L6".SupplyClass          = "XXbaseXX".SupplyClass
 AND "XXbaseXX_XXX_L6".SupplyType           = "XXbaseXX".SupplyType
 AND "XXbaseXX_XXX_L6".For_Organization     = "XXbaseXX".For_Organization
 AND "XXbaseXX_XXX_L6".To_Location          = "XXbaseXX".To_Location
 AND "XXbaseXX_XXX_L6".Maintain_Type        = "XXbaseXX".Maintain_Type
 AND "XXbaseXX_XXX_L6".Maintain_TypeID      = "XXbaseXX".Maintain_TypeID
 AND "XXbaseXX_XXX_L6".Maintain_ItemID      = "XXbaseXX".Maintain_ItemID
 AND "XXbaseXX_XXX_L6".Maintain_Nomenclature = "XXbaseXX".Maintain_Nomenclature
 AND "XXbaseXX_XXX_L6".Preferred_Start_Date = "XXbaseXX".Preferred_Start_Date
 AND "XXbaseXX_XXX_L6".Preferred_End_Date   = "XXbaseXX".Preferred_End_Date
 AND "XXbaseXX_XXX_L6".Phased               = "XXbaseXX".Phased
 AND "XXbaseXX_XXX_L6".Phase_no             = "XXbaseXX".Phase_no)
WHERE "XXbaseXX_XXX_L6".Verb                 = 'ProjectSupply';),

      ## create a table of the level 6 tasks missing in the stressed run
      #"15 drop table" => qq(drop table "XXbaseXX_XXX_Missing_L6";),

#       "16 CREATE TABLE XXbaseXX_XXX_Missing_L6" => qq(
# CREATE __TEMP__ TABLE "XXbaseXX_XXX_Missing_L6"
# (
#   num_runs              integer,
#   num_tasks             integer,
#   Agent                     varchar(255) NOT NULL default '',
#   Verb                      varchar(31) NOT NULL default '',
#   NSN_Number                varchar(255)          default NULL,
#   ClassName                 varchar(255)         default NULL,
#   SupplyClass               varchar(255)          default NULL,
#   SupplyType                varchar(255)          default NULL,
#   From_Location             varchar(255)          default NULL,
#   For_Organization          varchar(255)          default NULL,
#   To_Location               varchar(255)          default NULL,
#   Maintain_Type         varchar(255)          default NULL,
#   Maintain_TypeID       varchar(255)          default NULL,
#   Maintain_ItemID       varchar(255)          default NULL,
#   Maintain_Nomenclature varchar(255)          default NULL,
#   Preferred_Quantity        double precision                default NULL,
#   Preferred_Start_Date      double precision              default NULL,
#   Preferred_End_Date        double precision              default NULL,
#   Preferred_Rate            double precision              default NULL,
#   Phased                    char(1)               default NULL,
#   Phase_no                  integer                       default NULL,
#   Confidence                double precision              default NULL,
#   Success                       char(1)                       default NULL,
#   MIN_Quantity              double precision                default NULL,
#   MIN_Start_Date            double precision              default NULL,
#   MIN_End_Date              double precision              default NULL,
#   MIN_Rate                  double precision                default NULL,
#   MAX_Quantity              double precision                default NULL,
#   MAX_Start_Date            double precision              default NULL,
#   MAX_End_Date              double precision              default NULL,
#   MAX_Rate                  double precision                default NULL,
#   Score_Quantity        double precision               default NULL,
#   Score_Start_Date      double precision               default NULL,
#   Score_End_Date        double precision               default NULL,
#   Score_Rate            double precision               default NULL,
#   Deviation_Quantity        double precision                default NULL,
#   Deviation_Start_Date      double precision                default NULL,
#   Deviation_End_Date        double precision                default NULL,
#   Deviation_Rate            double precision                default NULL,
#   Scoring_Fn_Quantity           varchar(255)         default NULL,
#   Scoring_Fn_Start_Date         varchar(255)         default NULL,
#   Scoring_Fn_End_Date           varchar(255)         default NULL,
#   Scoring_Fn_Rate               varchar(255)         default NULL,
#   Pref_Score_Quantity           double precision                default NULL,
#   Pref_Score_Start_Date         double precision              default NULL,
#   Pref_Score_End_Date           double precision                default NULL,
#   Pref_Score_Rate               double precision                default NULL
# );),

#       ## populate the missing table: transport (there is no point in doing
#       ## this, really, for credit, since there are no level 2 transport
#       ## tasks)
#       "17 INSERT INTO XXbaseXX_XXX_Missing_L6" => qq(
# INSERT INTO "XXbaseXX_XXX_Missing_L6"
# SELECT   num_runs, num_tasks, Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
#          From_Location, For_Organization, To_Location,
#          Maintain_Type, Maintain_TypeID, Maintain_ItemID,
#          Maintain_Nomenclature, Preferred_Quantity,
#          Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
#          Phased, Phase_no, Confidence, Success, MIN_Quantity, MIN_Start_Date,
#          MIN_End_Date, MIN_Rate, MAX_Quantity, MAX_Start_Date,
#          MAX_End_Date, MAX_Rate, Score_Quantity, Score_Start_Date,
#          Score_End_Date, Score_Rate, Deviation_Quantity,
#          Deviation_Start_Date, Deviation_End_Date, Deviation_Rate,
#          Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
#          Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
#          Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate
# FROM "XXbaseXX"
# WHERE
#  (Agent, Verb, NSN_Number, ClassName, To_Location,
#   From_Location, Preferred_End_Date,
#   Preferred_Start_Date, Phased, Phase_no) NOT IN
#   (SELECT Agent, Verb, NSN_Number, ClassName, To_Location, From_Location,
#           Preferred_End_Date, Preferred_Start_Date, Phased, Phase_no
#     FROM "XXbaseXX_XXX_Matched_L6"
#     WHERE   Verb  = 'Transport')
#      AND   Verb  = 'Transport';),

#       ## populate the missing table: Supply
#       "18 INSERT INTO XXbaseXX_XXX_Missing_L6" => qq(
# INSERT INTO "XXbaseXX_XXX_Missing_L6"
# SELECT   num_runs, num_tasks, Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
#          From_Location, For_Organization, To_Location,
#          Maintain_Type, Maintain_TypeID, Maintain_ItemID,
#          Maintain_Nomenclature, Preferred_Quantity,
#          Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
#          Phased, Phase_no, Confidence, Success, MIN_Quantity, MIN_Start_Date,
#          MIN_End_Date, MIN_Rate, MAX_Quantity, MAX_Start_Date,
#          MAX_End_Date, MAX_Rate, Score_Quantity, Score_Start_Date,
#          Score_End_Date, Score_Rate, Deviation_Quantity,
#          Deviation_Start_Date, Deviation_End_Date, Deviation_Rate,
#          Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
#          Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
#          Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate
# FROM  "XXbaseXX"
# WHERE
#  (Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
#   For_Organization, To_Location, Maintain_Type,
#   Maintain_TypeID, Maintain_ItemID, Maintain_Nomenclature,
#   Preferred_Quantity, Preferred_End_Date, Phased, Phase_no)
#   NOT IN (SELECT Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
#                For_Organization, To_Location,
#                Maintain_Type, Maintain_TypeID,
#                Maintain_ItemID,
#                Maintain_Nomenclature,
#                Preferred_Quantity,
#                Preferred_End_Date, Phased, Phase_no
#        FROM "XXbaseXX_XXX_Matched_L6"
#        WHERE Verb                 = 'Supply')
#         AND Verb                 = 'Supply'
#         AND NSN_Number NOT LIKE 'Level2%';),

#       ## populate the missing table: Supply
#       "19 INSERT INTO XXbaseXX_XXX_Missing_L6" => qq(
# INSERT INTO "XXbaseXX_XXX_Missing_L6"
# SELECT   num_runs, num_tasks, Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
#          From_Location, For_Organization, To_Location,
#          Maintain_Type, Maintain_TypeID, Maintain_ItemID,
#          Maintain_Nomenclature, Preferred_Quantity,
#          Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
#          Phased, Phase_no, Confidence, Success, MIN_Quantity, MIN_Start_Date,
#          MIN_End_Date, MIN_Rate, MAX_Quantity, MAX_Start_Date,
#          MAX_End_Date, MAX_Rate, Score_Quantity, Score_Start_Date,
#          Score_End_Date, Score_Rate, Deviation_Quantity,
#          Deviation_Start_Date, Deviation_End_Date, Deviation_Rate,
#          Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
#          Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
#          Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate
# FROM   "XXbaseXX"
# WHERE 
#  (Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
#   For_Organization, To_Location,  Maintain_Type,
#   Maintain_TypeID, Maintain_ItemID, Maintain_Nomenclature,
#   Preferred_Start_Date, Preferred_End_Date, Phased, Phase_no)
#  NOT IN (SELECT Agent, Verb,
#               NSN_Number, ClassName,
#               SupplyClass, SupplyType,
#               For_Organization, To_Location,
#               Maintain_Type,
#               Maintain_TypeID, Maintain_ItemID,
#               Maintain_Nomenclature,
#               Preferred_Start_Date,
#               Preferred_End_Date, Phased, Phase_no
#       FROM "XXbaseXX_XXX_Matched_L6"
#       WHERE Verb                 = 'ProjectSupply')
#        AND Verb                 = 'ProjectSupply'
#        AND NSN_Number NOT LIKE 'Level2%';),

      ## Find the level 2 tasks in the baseline that correspond to the
      ## missing level 6 tasks. First, create the table

      #"20 drop table" => qq(DROP TABLE "XXbaseXX_XXX_MISSING_L2";),
      "21 CREATE TABLE XXbaseXX_XXX_MISSING_L2" => qq(
CREATE __TEMP__ TABLE "XXbaseXX_XXX_MISSING_L2" (
  Agent                      varchar(255) NOT NULL default '',
  Verb                       varchar(31) NOT NULL default '',
  NSN_Number                 varchar(255)          default NULL,
  ClassName                  varchar(255)         default NULL,
  SupplyClass                varchar(255)          default NULL,
  SupplyType                 varchar(255)          default NULL,
  From_Location              varchar(255)          default NULL,
  For_Organization           varchar(255)          default NULL,
  To_Location                varchar(255)          default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity         double precision                default NULL,
  Preferred_Start_Date       double precision              default NULL,
  Preferred_End_Date         double precision              default NULL,
  Preferred_Rate             double precision              default NULL,
  Phased                    char(1)               default NULL,
  Phase_no                   integer                       default NULL,
  Confidence                 double precision              default NULL,
  Success                    char(1)                       default NULL,
  MIN_Quantity               double precision                default NULL,
  MIN_Start_Date             double precision              default NULL,
  MIN_End_Date               double precision              default NULL,
  MIN_Rate                   double precision                default NULL,
  MAX_Quantity               double precision                default NULL,
  MAX_Start_Date             double precision              default NULL,
  MAX_End_Date               double precision              default NULL,
  MAX_Rate                   double precision                default NULL,
  Score_Quantity             double precision               default NULL,
  Score_Start_Date           double precision               default NULL,
  Score_End_Date             double precision               default NULL,
  Score_Rate                 double precision               default NULL,
  Deviation_Quantity         double precision                default NULL,
  Deviation_Start_Date       double precision                default NULL,
  Deviation_End_Date         double precision                default NULL,
  Deviation_Rate             double precision                default NULL,
  Scoring_Fn_Quantity        varchar(255)         default NULL,
  Scoring_Fn_Start_Date      varchar(255)         default NULL,
  Scoring_Fn_End_Date        varchar(255)         default NULL,
  Scoring_Fn_Rate            varchar(255)         default NULL,
  Pref_Score_Quantity        double precision                default NULL,
  Pref_Score_Start_Date      double precision              default NULL,
  Pref_Score_End_Date        double precision                default NULL,
  Pref_Score_Rate            double precision                default NULL
);),

## So, here are the corresponding level 2 tasks
      "22 INSERT INTO XXbaseXX_XXX_MISSING_L2" => qq(
INSERT INTO "XXbaseXX_XXX_MISSING_L2" (
  Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
  From_Location, For_Organization, To_Location,
  Maintain_Type, Maintain_TypeID, Maintain_ItemID,
  Maintain_Nomenclature, Preferred_Quantity, Preferred_Start_Date,
  Preferred_End_Date, Preferred_Rate, Phased, Phase_no, Confidence, Success,
  MIN_Quantity, MIN_Start_Date, MIN_End_Date, MIN_Rate, MAX_Quantity,
  MAX_Start_Date, MAX_End_Date, MAX_Rate, Score_Quantity,
  Score_Start_Date, Score_End_Date, Score_Rate, Deviation_Quantity,
  Deviation_Start_Date, Deviation_End_Date, Deviation_Rate,
  Scoring_Fn_Quantity, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Scoring_Fn_Rate, Pref_Score_Quantity, Pref_Score_Start_Date,
  Pref_Score_End_Date, Pref_Score_Rate)
SELECT DISTINCT
  "XXbaseXX".Agent, "XXbaseXX".Verb, "XXbaseXX".NSN_Number,
  "XXbaseXX".ClassName, "XXbaseXX".SupplyClass, "XXbaseXX".SupplyType,
  "XXbaseXX".From_Location, "XXbaseXX".For_Organization,
  "XXbaseXX".To_Location, "XXbaseXX".Maintain_Type,
  "XXbaseXX".Maintain_TypeID, "XXbaseXX".Maintain_ItemID,
  "XXbaseXX".Maintain_Nomenclature, "XXbaseXX".Preferred_Quantity,
  "XXbaseXX".Preferred_Start_Date, "XXbaseXX".Preferred_End_Date,
  "XXbaseXX".Preferred_Rate, "XXbaseXX".Phased, "XXbaseXX".Phase_no,
  "XXbaseXX".Confidence, "XXbaseXX".Success, "XXbaseXX".MIN_Quantity,
  "XXbaseXX".MIN_Start_Date, "XXbaseXX".MIN_End_Date, "XXbaseXX".MIN_Rate,
  "XXbaseXX".MAX_Quantity, "XXbaseXX".MAX_Start_Date,
  "XXbaseXX".MAX_End_Date, "XXbaseXX".MAX_Rate, "XXbaseXX".Score_Quantity,
  "XXbaseXX".Score_Start_Date, "XXbaseXX".Score_End_Date,
  "XXbaseXX".Score_Rate, "XXbaseXX".Deviation_Quantity,
  "XXbaseXX".Deviation_Start_Date, "XXbaseXX".Deviation_End_Date,
  "XXbaseXX".Deviation_Rate, "XXbaseXX".Scoring_Fn_Quantity,
  "XXbaseXX".Scoring_Fn_Start_Date, "XXbaseXX".Scoring_Fn_End_Date,
  "XXbaseXX".Scoring_Fn_Rate, "XXbaseXX".Pref_Score_Quantity,
  "XXbaseXX".Pref_Score_Start_Date, "XXbaseXX".Pref_Score_End_Date,
  "XXbaseXX".Pref_Score_Rate
FROM "XXbaseXX", "XXbaseXX_XXX_Matched_L6"
WHERE
     "XXbaseXX".agent                = "XXbaseXX_XXX_Matched_L6".agent
 and "XXbaseXX".verb                 = "XXbaseXX_XXX_Matched_L6".verb
 and "XXbaseXX".preferred_end_date   = "XXbaseXX_XXX_Matched_L6".preferred_end_date
 and "XXbaseXX".preferred_Quantity   = "XXbaseXX_XXX_Matched_L6".preferred_Quantity
 and "XXbaseXX".To_Location          = "XXbaseXX_XXX_Matched_L6".To_Location
 and "XXbaseXX".SupplyClass          = "XXbaseXX_XXX_Matched_L6".SupplyClass
 and "XXbaseXX".SupplyType           = "XXbaseXX_XXX_Matched_L6".SupplyType
 and "XXbaseXX".for_organization     = "XXbaseXX_XXX_Matched_L6".for_organization
 and "XXbaseXX".maintain_Type        = "XXbaseXX_XXX_Matched_L6".maintain_Type
 and "XXbaseXX".maintain_TypeID      = "XXbaseXX_XXX_Matched_L6".maintain_TypeID
 and "XXbaseXX".maintain_ItemID      = "XXbaseXX_XXX_Matched_L6".maintain_ItemID
 and "XXbaseXX".maintain_Nomenclature = "XXbaseXX_XXX_Matched_L6".maintain_Nomenclature
 AND "XXbaseXX".verb                 = 'Supply'
 AND "XXbaseXX".NSN_Number LIKE 'Level2%'
 AND "XXbaseXX_XXX_Matched_L6".run_id IS NULL;),
     # These are level 2 tasks corresponding to missing level 6 tasks in baseline
      "23 INSERT INTO XXbaseXX_XXX_MISSING_L2" => qq(
INSERT INTO "XXbaseXX_XXX_MISSING_L2" (
  Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
  From_Location, For_Organization, To_Location,
  Maintain_Type, Maintain_TypeID, Maintain_ItemID,
  Maintain_Nomenclature, Preferred_Quantity, Preferred_Start_Date,
  Preferred_End_Date, Preferred_Rate, Phased, Phase_no, Confidence, Success,
  MIN_Quantity, MIN_Start_Date, MIN_End_Date, MIN_Rate, MAX_Quantity,
  MAX_Start_Date, MAX_End_Date, MAX_Rate, Score_Quantity,
  Score_Start_Date, Score_End_Date, Score_Rate, Deviation_Quantity,
  Deviation_Start_Date, Deviation_End_Date, Deviation_Rate,
  Scoring_Fn_Quantity, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Scoring_Fn_Rate, Pref_Score_Quantity, Pref_Score_Start_Date,
  Pref_Score_End_Date, Pref_Score_Rate)
SELECT DISTINCT
  "XXbaseXX".Agent, "XXbaseXX".Verb, "XXbaseXX".NSN_Number,
  "XXbaseXX".ClassName, "XXbaseXX".SupplyClass, "XXbaseXX".SupplyType,
  "XXbaseXX".From_Location, "XXbaseXX".For_Organization,
  "XXbaseXX".To_Location, "XXbaseXX".Maintain_Type,
  "XXbaseXX".Maintain_TypeID, "XXbaseXX".Maintain_ItemID,
  "XXbaseXX".Maintain_Nomenclature, "XXbaseXX".Preferred_Quantity,
  "XXbaseXX".Preferred_Start_Date, "XXbaseXX".Preferred_End_Date,
  "XXbaseXX".Preferred_Rate, "XXbaseXX".Phased, "XXbaseXX".Phase_no,
  "XXbaseXX".Confidence, "XXbaseXX".Success, "XXbaseXX".MIN_Quantity,
  "XXbaseXX".MIN_Start_Date, "XXbaseXX".MIN_End_Date, "XXbaseXX".MIN_Rate,
  "XXbaseXX".MAX_Quantity, "XXbaseXX".MAX_Start_Date,
  "XXbaseXX".MAX_End_Date, "XXbaseXX".MAX_Rate, "XXbaseXX".Score_Quantity,
  "XXbaseXX".Score_Start_Date, "XXbaseXX".Score_End_Date,
  "XXbaseXX".Score_Rate, "XXbaseXX".Deviation_Quantity,
  "XXbaseXX".Deviation_Start_Date, "XXbaseXX".Deviation_End_Date,
  "XXbaseXX".Deviation_Rate, "XXbaseXX".Scoring_Fn_Quantity,
  "XXbaseXX".Scoring_Fn_Start_Date, "XXbaseXX".Scoring_Fn_End_Date,
  "XXbaseXX".Scoring_Fn_Rate, "XXbaseXX".Pref_Score_Quantity,
  "XXbaseXX".Pref_Score_Start_Date, "XXbaseXX".Pref_Score_End_Date,
  "XXbaseXX".Pref_Score_Rate
FROM "XXbaseXX", "XXbaseXX_XXX_Matched_L6"
WHERE
      "XXbaseXX".agent                = "XXbaseXX_XXX_Matched_L6".agent
  and "XXbaseXX".verb                 = "XXbaseXX_XXX_Matched_L6".verb
  and "XXbaseXX".preferred_end_date   = "XXbaseXX_XXX_Matched_L6".preferred_end_date
  and "XXbaseXX".preferred_start_date = "XXbaseXX_XXX_Matched_L6".preferred_start_date
  and "XXbaseXX".SupplyClass          = "XXbaseXX_XXX_Matched_L6".SupplyClass
  and "XXbaseXX".SupplyType           = "XXbaseXX_XXX_Matched_L6".SupplyType
  and "XXbaseXX".for_organization     = "XXbaseXX_XXX_Matched_L6".for_organization
  and "XXbaseXX".maintain_Type        = "XXbaseXX_XXX_Matched_L6".maintain_Type
  and "XXbaseXX".maintain_TypeID      = "XXbaseXX_XXX_Matched_L6".maintain_TypeID
  and "XXbaseXX".maintain_ItemID      = "XXbaseXX_XXX_Matched_L6".maintain_ItemID
  and "XXbaseXX".maintain_Nomenclature = "XXbaseXX_XXX_Matched_L6".maintain_Nomenclature
  AND "XXbaseXX".verb                 = 'ProjectSupply'
  AND "XXbaseXX".NSN_Number LIKE 'Level2%'
  AND "XXbaseXX_XXX_Matched_L6".run_id IS NULL;),

      #"24 DROP TABLE" => qq(DROP TABLE "XXbaseXX_XXX_MATCHED_L2";),
      "25 CREATE TABLE XXbaseXX_XXX_MATCHED_L2" => qq(
CREATE __TEMP__ TABLE "XXbaseXX_XXX_MATCHED_L2" (
  run_id                     integer  NOT NULL,
  task_id                    varchar(255) NOT NULL,
  Agent                      varchar(255) NOT NULL default '',
  Verb                       varchar(31) NOT NULL default '',
  NSN_Number                 varchar(255)          default NULL,
  ClassName                  varchar(255)         default NULL,
  SupplyClass                varchar(255)          default NULL,
  SupplyType                 varchar(255)          default NULL,
  From_Location              varchar(255)          default NULL,
  For_Organization           varchar(255)          default NULL,
  To_Location                varchar(255)          default NULL,
  Maintain_Type         varchar(255)              default NULL,
  Maintain_TypeID       varchar(255)              default NULL,
  Maintain_ItemID       varchar(255)              default NULL,
  Maintain_Nomenclature varchar(255)              default NULL,
  Preferred_Quantity         double precision     default NULL,
  Preferred_Start_Date       double precision     default NULL,
  Preferred_End_Date         double precision     default NULL,
  Preferred_Rate             double precision     default NULL,
  Phased                    char(1)               default NULL,
  Phase_no                   integer              default NULL,
  Confidence                 double precision     default NULL,
  Success                    char(1)              default NULL,
  quantity                   double precision     default NULL,
  start_date                 double precision     default NULL,
  end_date                   double precision     default NULL,
  rate                       double precision     default NULL,
  Score_Quantity             double precision     default NULL,
  Score_Start_Date           double precision     default NULL,
  Score_End_Date             double precision     default NULL,
  Score_Rate                 double precision     default NULL,
  Deviation_Quantity         double precision     default NULL,
  Deviation_Start_Date       double precision     default NULL,
  Deviation_End_Date         double precision     default NULL,
  Deviation_Rate             double precision     default NULL,
  Scoring_Fn_Quantity        varchar(255)         default NULL,
  Scoring_Fn_Start_Date      varchar(255)         default NULL,
  Scoring_Fn_End_Date        varchar(255)         default NULL,
  Scoring_Fn_Rate            varchar(255)         default NULL,
  Pref_Score_Quantity        double precision     default NULL,
  Pref_Score_Start_Date      double precision     default NULL,
  Pref_Score_End_Date        double precision     default NULL,
  Pref_Score_Rate            double precision     default NULL,
  Base_Confidence            double precision     default NULL,
  Base_Score_Quantity        double precision     default NULL,
  Base_Score_Start_Date      double precision     default NULL,
  Base_Score_End_Date        double precision     default NULL,
  Base_Score_Rate            double precision     default NULL,
  Base_Deviation_Quantity    double precision     default NULL,
  Base_Deviation_Start_Date  double precision     default NULL,
  Base_Deviation_End_Date    double precision     default NULL,
  Base_Deviation_Rate        double precision     default NULL
);),
      # These are the level 2 tasks in stressed run that correspond to
      # the level 2 tasks in the baseline 
      "26 INSERT INTO XXbaseXX_XXX_MATCHED_L2" => qq(
INSERT INTO "XXbaseXX_XXX_MATCHED_L2" (
  run_id, task_id, Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, From_Location, For_Organization, To_Location,
  Maintain_Type, Maintain_TypeID, Maintain_ItemID,
  Maintain_Nomenclature, Preferred_Quantity, Preferred_Start_Date,
  Preferred_End_Date, Preferred_Rate, Phased, Phase_no, Confidence, Success,
  Quantity, Start_Date, End_Date, Rate, Score_Quantity,
  Score_Start_Date, Score_End_Date, Score_Rate, Deviation_Quantity,
  Deviation_Start_Date, Deviation_End_Date, Deviation_Rate,
  Scoring_Fn_Quantity, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Scoring_Fn_Rate, Pref_Score_Quantity, Pref_Score_Start_Date,
  Pref_Score_End_Date, Pref_Score_Rate, Base_Confidence,
  Base_Score_Quantity, Base_Score_Start_Date, Base_Score_End_Date,
  Base_Score_Rate, Base_Deviation_Quantity, Base_Deviation_Start_Date,
  Base_Deviation_End_Date, Base_Deviation_Rate)
SELECT DISTINCT
  Stressed_XXX.Run_ID,
  Stressed_XXX.Task_ID,
  Stressed_XXX.Agent,
  Stressed_XXX.Verb,
  Stressed_XXX.NSN_Number,
  Stressed_XXX.ClassName,
  Stressed_XXX.SupplyClass,
  Stressed_XXX.SupplyType,
  Stressed_XXX.From_Location,
  Stressed_XXX.For_Organization,
  Stressed_XXX.To_Location,
  Stressed_XXX.Maintain_Type,
  Stressed_XXX.Maintain_TypeID,
  Stressed_XXX.Maintain_ItemID,
  Stressed_XXX.Maintain_Nomenclature,
  Stressed_XXX.Preferred_Quantity,
  Stressed_XXX.Preferred_Start_Date,
  Stressed_XXX.Preferred_End_Date,
  Stressed_XXX.Preferred_Rate,
  Stressed_XXX.Phased,
  Stressed_XXX.Phase_no,
  Stressed_XXX.Confidence,
  Stressed_XXX.Success,
  Stressed_XXX.Quantity,
  Stressed_XXX.Start_Date,
  Stressed_XXX.End_Date,
  Stressed_XXX.Rate,
  Stressed_XXX.Score_Quantity,
  Stressed_XXX.Score_Start_Date,
  Stressed_XXX.Score_End_Date,
  Stressed_XXX.Score_Rate,
  Stressed_XXX.Deviation_Quantity,
  Stressed_XXX.Deviation_Start_Date,
  Stressed_XXX.Deviation_End_Date,
  Stressed_XXX.Deviation_Rate,
  Stressed_XXX.Scoring_Fn_Quantity,
  Stressed_XXX.Scoring_Fn_Start_Date,
  Stressed_XXX.Scoring_Fn_End_Date,
  Stressed_XXX.Scoring_Fn_Rate,
  Stressed_XXX.Pref_Score_Quantity,
  Stressed_XXX.Pref_Score_Start_Date,
  Stressed_XXX.Pref_Score_End_Date,
  Stressed_XXX.Pref_Score_Rate,
  "XXbaseXX_XXX_MISSING_L2".Confidence,
  "XXbaseXX_XXX_MISSING_L2".Score_Quantity,
  "XXbaseXX_XXX_MISSING_L2".Score_Start_Date,
  "XXbaseXX_XXX_MISSING_L2".Score_End_Date,
  "XXbaseXX_XXX_MISSING_L2".Score_Rate,
  "XXbaseXX_XXX_MISSING_L2".Deviation_Quantity,
  "XXbaseXX_XXX_MISSING_L2".Deviation_Start_Date,
  "XXbaseXX_XXX_MISSING_L2".Deviation_End_Date,
  "XXbaseXX_XXX_MISSING_L2".Deviation_Rate
FROM "XXbaseXX_XXX_MISSING_L2", Stressed_XXX
WHERE
      "XXbaseXX_XXX_MISSING_L2".agent                = Stressed_XXX.agent
  and "XXbaseXX_XXX_MISSING_L2".verb                 = Stressed_XXX.verb
  and "XXbaseXX_XXX_MISSING_L2".NSN_Number           = Stressed_XXX.NSN_Number
  and "XXbaseXX_XXX_MISSING_L2".ClassName            = Stressed_XXX.ClassName
  and "XXbaseXX_XXX_MISSING_L2".SupplyClass          = Stressed_XXX.SupplyClass
  and "XXbaseXX_XXX_MISSING_L2".SupplyType           = Stressed_XXX.SupplyType
  and "XXbaseXX_XXX_MISSING_L2".preferred_end_date   = Stressed_XXX.preferred_end_date
  and "XXbaseXX_XXX_MISSING_L2".preferred_Quantity   = Stressed_XXX.preferred_Quantity
  and "XXbaseXX_XXX_MISSING_L2".To_Location          = Stressed_XXX.To_Location
  and "XXbaseXX_XXX_MISSING_L2".for_organization     = Stressed_XXX.for_organization
  and "XXbaseXX_XXX_MISSING_L2".maintain_Type        = Stressed_XXX.maintain_Type
  and "XXbaseXX_XXX_MISSING_L2".maintain_TypeID      = Stressed_XXX.maintain_TypeID
  and "XXbaseXX_XXX_MISSING_L2".maintain_ItemID      = Stressed_XXX.maintain_ItemID
  and "XXbaseXX_XXX_MISSING_L2".maintain_Nomenclature= Stressed_XXX.maintain_Nomenclature
  and "XXbaseXX_XXX_MISSING_L2".Phased               = Stressed_XXX.Phased
  and "XXbaseXX_XXX_MISSING_L2".Phase_no             = Stressed_XXX.Phase_no
  AND "XXbaseXX_XXX_MISSING_L2".verb                 = 'Supply';),

      "27 INSERT INTO XXbaseXX_XXX_MATCHED_L2" => qq(
INSERT INTO "XXbaseXX_XXX_MATCHED_L2" (
  Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, From_Location, For_Organization, To_Location,
  Maintain_Type, Maintain_TypeID, Maintain_ItemID,
  Maintain_Nomenclature, Preferred_Quantity, Preferred_Start_Date,
  Preferred_End_Date, Preferred_Rate, Phased, Phase_no, Confidence, Success,
  Quantity, Start_Date, End_Date, Rate, Score_Quantity,
  Score_Start_Date, Score_End_Date, Score_Rate, Deviation_Quantity,
  Deviation_Start_Date, Deviation_End_Date, Deviation_Rate,
  Scoring_Fn_Quantity, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Scoring_Fn_Rate, Pref_Score_Quantity, Pref_Score_Start_Date,
  Pref_Score_End_Date, Pref_Score_Rate, Base_Confidence,
  Base_Score_Quantity, Base_Score_Start_Date, Base_Score_End_Date,
  Base_Score_Rate, Base_Deviation_Quantity, Base_Deviation_Start_Date,
  Base_Deviation_End_Date, Base_Deviation_Rate)
SELECT DISTINCT
  Stressed_XXX.Run_ID,
  Stressed_XXX.Task_ID,
  Stressed_XXX.Agent,
  Stressed_XXX.Verb,
  Stressed_XXX.NSN_Number,
  Stressed_XXX.ClassName,
  Stressed_XXX.SupplyClass,
  Stressed_XXX.SupplyType,
  Stressed_XXX.From_Location,
  Stressed_XXX.For_Organization,
  Stressed_XXX.To_Location,
  Stressed_XXX.Maintain_Type,
  Stressed_XXX.Maintain_TypeID,
  Stressed_XXX.Maintain_ItemID,
  Stressed_XXX.Maintain_Nomenclature,
  Stressed_XXX.Preferred_Quantity,
  Stressed_XXX.Preferred_Start_Date,
  Stressed_XXX.Preferred_End_Date,
  Stressed_XXX.Preferred_Rate,
  Stressed_XXX.Phased,
  Stressed_XXX.Phase_no,
  Stressed_XXX.Confidence,
  Stressed_XXX.Success,
  Stressed_XXX.Quantity,
  Stressed_XXX.Start_Date,
  Stressed_XXX.End_Date,
  Stressed_XXX.Rate,
  Stressed_XXX.Score_Quantity,
  Stressed_XXX.Score_Start_Date,
  Stressed_XXX.Score_End_Date,
  Stressed_XXX.Score_Rate,
  Stressed_XXX.Deviation_Quantity,
  Stressed_XXX.Deviation_Start_Date,
  Stressed_XXX.Deviation_End_Date,
  Stressed_XXX.Deviation_Rate,
  Stressed_XXX.Scoring_Fn_Quantity,
  Stressed_XXX.Scoring_Fn_Start_Date,
  Stressed_XXX.Scoring_Fn_End_Date,
  Stressed_XXX.Scoring_Fn_Rate,
  Stressed_XXX.Pref_Score_Quantity,
  Stressed_XXX.Pref_Score_Start_Date,
  Stressed_XXX.Pref_Score_End_Date,
  Stressed_XXX.Pref_Score_Rate,
  "XXbaseXX_XXX_MISSING_L2".Confidence,
  "XXbaseXX_XXX_MISSING_L2".Score_Quantity,
  "XXbaseXX_XXX_MISSING_L2".Score_Start_Date,
  "XXbaseXX_XXX_MISSING_L2".Score_End_Date,
  "XXbaseXX_XXX_MISSING_L2".Score_Rate,
  "XXbaseXX_XXX_MISSING_L2".Deviation_Quantity,
  "XXbaseXX_XXX_MISSING_L2".Deviation_Start_Date,
  "XXbaseXX_XXX_MISSING_L2".Deviation_End_Date,
  "XXbaseXX_XXX_MISSING_L2".Deviation_Rate
FROM "XXbaseXX_XXX_MISSING_L2", Stressed_XXX
WHERE
      "XXbaseXX_XXX_MISSING_L2".agent                = Stressed_XXX.agent
  and "XXbaseXX_XXX_MISSING_L2".verb                 = Stressed_XXX.verb
  and "XXbaseXX_XXX_MISSING_L2".NSN_Number           = Stressed_XXX.NSN_Number
  and "XXbaseXX_XXX_MISSING_L2".preferred_end_date   = Stressed_XXX.preferred_end_date
  and "XXbaseXX_XXX_MISSING_L2".preferred_start_date = Stressed_XXX.preferred_start_date
  and "XXbaseXX_XXX_MISSING_L2".ClassName            = Stressed_XXX.ClassName
  and "XXbaseXX_XXX_MISSING_L2".SupplyClass          = Stressed_XXX.SupplyClass
  and "XXbaseXX_XXX_MISSING_L2".SupplyType           = Stressed_XXX.SupplyType
  and "XXbaseXX_XXX_MISSING_L2".for_organization     = Stressed_XXX.for_organization
  and "XXbaseXX_XXX_MISSING_L2".maintain_Type        = Stressed_XXX.maintain_Type
  and "XXbaseXX_XXX_MISSING_L2".maintain_TypeID      = Stressed_XXX.maintain_TypeID
  and "XXbaseXX_XXX_MISSING_L2".maintain_ItemID      = Stressed_XXX.maintain_ItemID
  and "XXbaseXX_XXX_MISSING_L2".maintain_Nomenclature= Stressed_XXX.maintain_Nomenclature
  and "XXbaseXX_XXX_MISSING_L2".Phased               = Stressed_XXX.Phased
  and "XXbaseXX_XXX_MISSING_L2".Phase_no             = Stressed_XXX.Phase_no
  AND "XXbaseXX_XXX_MISSING_L2".verb                 = 'ProjectSupply';),

## Now, to match these level 2 tasks with the missing level 6 tasks,
## and assign put them into another table, with scores.


## create a table of the level 6 tasks that should be given partial credit
      #"28 drop table" => qq(drop table "XXbaseXX_XXX_Part_Cred";),
      "29 CREATE TABLE XXbaseXX_XXX_Part_Cred" => qq(
CREATE TABLE "XXbaseXX_XXX_Part_Cred"
(
  Run_ID                    integer               default '-1',
  Task_ID                   varchar(255)          default 'NONE SET',
  Agent                     varchar(255) NOT NULL default '',
  Verb                      varchar(31) NOT NULL default '',
  L2_NSN_Number             varchar(255)          default NULL,
  NSN_Number                varchar(255)          default NULL,
  ClassName                 varchar(255)         default NULL,
  SupplyClass               varchar(255)          default NULL,
  SupplyType                varchar(255)          default NULL,
  From_Location             varchar(255)          default NULL,
  For_Organization          varchar(255)          default NULL,
  To_Location               varchar(255)          default NULL,
  Maintain_Type         varchar(255)          default NULL,
  Maintain_TypeID       varchar(255)          default NULL,
  Maintain_ItemID       varchar(255)          default NULL,
  Maintain_Nomenclature varchar(255)          default NULL,
  Preferred_Quantity        double precision                default NULL,
  Preferred_Start_Date      double precision              default NULL,
  Preferred_End_Date        double precision              default NULL,
  Preferred_Rate            double precision              default NULL,
  Phased                    char(1)               default NULL,
  Phase_no                  integer                       default NULL,
  Confidence                double precision              default NULL,
  Success                       char(1)                       default NULL,
  Quantity              double precision                default NULL,
  Start_Date            double precision              default NULL,
  End_Date              double precision              default NULL,
  Rate                  double precision                default NULL,
  Score_Quantity        double precision               default NULL,
  Score_Start_Date      double precision               default NULL,
  Score_End_Date        double precision               default NULL,
  Score_Rate            double precision               default NULL,
  Deviation_Quantity        double precision                default NULL,
  Deviation_Start_Date      double precision                default NULL,
  Deviation_End_Date        double precision                default NULL,
  Deviation_Rate            double precision                default NULL,
  Scoring_Fn_Quantity           varchar(255)         default NULL,
  Scoring_Fn_Start_Date         varchar(255)         default NULL,
  Scoring_Fn_End_Date           varchar(255)         default NULL,
  Scoring_Fn_Rate               varchar(255)         default NULL,
  Pref_Score_Quantity           double precision                default NULL,
  Pref_Score_Start_Date         double precision              default NULL,
  Pref_Score_End_Date           double precision                default NULL,
  Pref_Score_Rate               double precision                default NULL,
  Base_Confidence                 double precision              default NULL,
  Base_Score_Quantity             double precision               default NULL,
  Base_Score_Start_Date           double precision               default NULL,
  Base_Score_End_Date             double precision               default NULL,
  Base_Score_Rate                 double precision               default NULL,
  Base_Deviation_Quantity         double precision                default NULL,
  Base_Deviation_Start_Date       double precision                default NULL,
  Base_Deviation_End_Date         double precision                default NULL,
  Base_Deviation_Rate             double precision                default NULL,
  Dev_Is_CC_Quantity        smallint              default NULL,
  Dev_Is_CC_Start_Date      smallint              default NULL,
  Dev_Is_CC_End_Date        smallint              default NULL,
  Dev_Is_CC_Rate            smallint              default NULL,
  Is_CC_Quantity            smallint              default NULL,
  Is_CC_Start_Date          smallint              default NULL,
  Is_CC_End_Date            smallint              default NULL,
  Is_CC_Rate                smallint              default NULL
);),

      "30 INSERT INTO XXbaseXX_XXX_Part_Cred" => qq(
INSERT INTO "XXbaseXX_XXX_Part_Cred" (
  Run_ID, Task_ID, Agent, Verb, L2_NSN_Number, NSN_Number, ClassName,
  SupplyClass, SupplyType, From_Location, For_Organization,
  To_Location, Maintain_Type, Maintain_TypeID,
  Maintain_ItemID, Maintain_Nomenclature, Preferred_Quantity,
  Preferred_Start_Date, Preferred_End_Date, Preferred_Rate, Phased, Phase_no,
  Confidence, Success, Quantity, Start_Date, End_Date, Rate,
  Score_Quantity, Score_Start_Date, Score_End_Date, Score_Rate,
  Deviation_Quantity, Deviation_Start_Date, Deviation_End_Date,
  Deviation_Rate, Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
  Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
  Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
  Base_Confidence, Base_Score_Quantity, Base_Score_Start_Date,
  Base_Score_End_Date, Base_Score_Rate, Base_Deviation_Quantity,
  Base_Deviation_Start_Date, Base_Deviation_End_Date,
  Base_Deviation_Rate)
SELECT DISTINCT
  "XXbaseXX_XXX_MATCHED_L2".Run_ID,
  "XXbaseXX_XXX_MATCHED_L2".Task_ID,
  "XXbaseXX_XXX_Matched_L6".Agent,
  "XXbaseXX_XXX_Matched_L6".Verb,
  "XXbaseXX_XXX_MATCHED_L2".NSN_Number,
  "XXbaseXX_XXX_Matched_L6".NSN_Number,
  "XXbaseXX_XXX_Matched_L6".ClassName,
  "XXbaseXX_XXX_Matched_L6".SupplyClass,
  "XXbaseXX_XXX_Matched_L6".SupplyType,
  "XXbaseXX_XXX_Matched_L6".From_Location,
  "XXbaseXX_XXX_Matched_L6".For_Organization,
  "XXbaseXX_XXX_Matched_L6".To_Location,
  "XXbaseXX_XXX_Matched_L6".Maintain_Type,
  "XXbaseXX_XXX_Matched_L6".Maintain_TypeID,
  "XXbaseXX_XXX_Matched_L6".Maintain_ItemID,
  "XXbaseXX_XXX_Matched_L6".Maintain_Nomenclature,
  "XXbaseXX_XXX_Matched_L6".Preferred_Quantity,
  "XXbaseXX_XXX_Matched_L6".Preferred_Start_Date,
  "XXbaseXX_XXX_Matched_L6".Preferred_End_Date,
  "XXbaseXX_XXX_Matched_L6".Preferred_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Phased,
  "XXbaseXX_XXX_MATCHED_L2".Phase_no,
  "XXbaseXX_XXX_MATCHED_L2".Confidence,
  "XXbaseXX_XXX_MATCHED_L2".Success,
  "XXbaseXX_XXX_MATCHED_L2".Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Rate,
  "XXbaseXX_XXX_MATCHED_L2".Score_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Score_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Score_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Score_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Base_Confidence,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_Rate
FROM "XXbaseXX_XXX_MATCHED_L2", "XXbaseXX_XXX_Matched_L6"
WHERE "XXbaseXX_XXX_MATCHED_L2".Agent             = "XXbaseXX_XXX_Matched_L6".Agent
 AND "XXbaseXX_XXX_MATCHED_L2".Verb               = "XXbaseXX_XXX_Matched_L6".Verb
 AND "XXbaseXX_XXX_MATCHED_L2".ClassName          = "XXbaseXX_XXX_Matched_L6".ClassName
 AND "XXbaseXX_XXX_MATCHED_L2".SupplyClass        = "XXbaseXX_XXX_Matched_L6".SupplyClass
 AND "XXbaseXX_XXX_MATCHED_L2".SupplyType         = "XXbaseXX_XXX_Matched_L6".SupplyType
 AND "XXbaseXX_XXX_MATCHED_L2".For_Organization   = "XXbaseXX_XXX_Matched_L6".For_Organization
 AND "XXbaseXX_XXX_MATCHED_L2".To_Location        = "XXbaseXX_XXX_Matched_L6".To_Location
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_Type      = "XXbaseXX_XXX_Matched_L6".Maintain_Type
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_TypeID    = "XXbaseXX_XXX_Matched_L6".Maintain_TypeID
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_ItemID    = "XXbaseXX_XXX_Matched_L6".Maintain_ItemID
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_Nomenclature = "XXbaseXX_XXX_Matched_L6".Maintain_Nomenclature
 AND "XXbaseXX_XXX_MATCHED_L2".Preferred_Quantity = "XXbaseXX_XXX_Matched_L6".Preferred_Quantity
 AND "XXbaseXX_XXX_MATCHED_L2".Preferred_End_Date = "XXbaseXX_XXX_Matched_L6".Preferred_End_Date
 AND "XXbaseXX_XXX_MATCHED_L2".Phased           = "XXbaseXX_XXX_Matched_L6".Phased
 AND "XXbaseXX_XXX_MATCHED_L2".Phase_no           = "XXbaseXX_XXX_Matched_L6".Phase_no
 AND "XXbaseXX_XXX_MATCHED_L2".Verb               = 'Supply'
  AND "XXbaseXX_XXX_Matched_L6".run_id IS NULL;),

      "31 INSERT INTO XXbaseXX_XXX_Part_Cred" => qq(
INSERT INTO "XXbaseXX_XXX_Part_Cred" (
  Run_ID, Task_ID, Agent, Verb, L2_NSN_Number, NSN_Number, ClassName,
  SupplyClass, SupplyType, From_Location, For_Organization,
  To_Location, Maintain_Type, Maintain_TypeID,
  Maintain_ItemID, Maintain_Nomenclature, Preferred_Quantity,
  Preferred_Start_Date, Preferred_End_Date, Preferred_Rate, Phased, Phase_no,
  Confidence, Success, Quantity, Start_Date, End_Date, Rate,
  Score_Quantity, Score_Start_Date, Score_End_Date, Score_Rate,
  Deviation_Quantity, Deviation_Start_Date, Deviation_End_Date,
  Deviation_Rate, Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
  Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
  Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
  Base_Confidence, Base_Score_Quantity, Base_Score_Start_Date,
  Base_Score_End_Date, Base_Score_Rate, Base_Deviation_Quantity,
  Base_Deviation_Start_Date, Base_Deviation_End_Date,
  Base_Deviation_Rate)
SELECT DISTINCT
  "XXbaseXX_XXX_MATCHED_L2".Run_ID,
  "XXbaseXX_XXX_MATCHED_L2".Task_ID,
  "XXbaseXX_XXX_Matched_L6".Agent,
  "XXbaseXX_XXX_Matched_L6".Verb,
  "XXbaseXX_XXX_MATCHED_L2".NSN_Number,
  "XXbaseXX_XXX_Matched_L6".NSN_Number,
  "XXbaseXX_XXX_Matched_L6".ClassName,
  "XXbaseXX_XXX_Matched_L6".SupplyClass,
  "XXbaseXX_XXX_Matched_L6".SupplyType,
  "XXbaseXX_XXX_Matched_L6".From_Location,
  "XXbaseXX_XXX_Matched_L6".For_Organization,
  "XXbaseXX_XXX_Matched_L6".To_Location,
  "XXbaseXX_XXX_Matched_L6".Maintain_Type,
  "XXbaseXX_XXX_Matched_L6".Maintain_TypeID,
  "XXbaseXX_XXX_Matched_L6".Maintain_ItemID,
  "XXbaseXX_XXX_Matched_L6".Maintain_Nomenclature,
  "XXbaseXX_XXX_Matched_L6".Preferred_Quantity,
  "XXbaseXX_XXX_Matched_L6".Preferred_Start_Date,
  "XXbaseXX_XXX_Matched_L6".Preferred_End_Date,
  "XXbaseXX_XXX_Matched_L6".Preferred_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Phased,
  "XXbaseXX_XXX_MATCHED_L2".Phase_no,
  "XXbaseXX_XXX_MATCHED_L2".Confidence,
  "XXbaseXX_XXX_MATCHED_L2".Success,
  "XXbaseXX_XXX_MATCHED_L2".Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Rate,
  "XXbaseXX_XXX_MATCHED_L2".Score_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Score_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Score_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Score_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Deviation_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Scoring_Fn_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Pref_Score_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Base_Confidence,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Score_Rate,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_Quantity,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_Start_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_End_Date,
  "XXbaseXX_XXX_MATCHED_L2".Base_Deviation_Rate
FROM "XXbaseXX_XXX_MATCHED_L2", "XXbaseXX_XXX_Matched_L6"
WHERE "XXbaseXX_XXX_MATCHED_L2".Agent             = "XXbaseXX_XXX_Matched_L6".Agent
 AND "XXbaseXX_XXX_MATCHED_L2".Verb               = "XXbaseXX_XXX_Matched_L6".Verb
 AND "XXbaseXX_XXX_MATCHED_L2".ClassName          = "XXbaseXX_XXX_Matched_L6".ClassName
 AND "XXbaseXX_XXX_MATCHED_L2".SupplyClass        = "XXbaseXX_XXX_Matched_L6".SupplyClass
 AND "XXbaseXX_XXX_MATCHED_L2".SupplyType         = "XXbaseXX_XXX_Matched_L6".SupplyType
 AND "XXbaseXX_XXX_MATCHED_L2".For_Organization   = "XXbaseXX_XXX_Matched_L6".For_Organization
 AND "XXbaseXX_XXX_MATCHED_L2".To_Location        = "XXbaseXX_XXX_Matched_L6".To_Location
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_Type      = "XXbaseXX_XXX_Matched_L6".Maintain_Type
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_TypeID    = "XXbaseXX_XXX_Matched_L6".Maintain_TypeID
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_ItemID    = "XXbaseXX_XXX_Matched_L6".Maintain_ItemID
 AND "XXbaseXX_XXX_MATCHED_L2".Maintain_Nomenclature = "XXbaseXX_XXX_Matched_L6".Maintain_Nomenclature
 AND "XXbaseXX_XXX_MATCHED_L2".Preferred_Start_Date = "XXbaseXX_XXX_Matched_L6".Preferred_Start_Date
 AND "XXbaseXX_XXX_MATCHED_L2".Preferred_End_Date = "XXbaseXX_XXX_Matched_L6".Preferred_End_Date
 AND "XXbaseXX_XXX_MATCHED_L2".Phased           = "XXbaseXX_XXX_Matched_L6".Phased
 AND "XXbaseXX_XXX_MATCHED_L2".Phase_no           = "XXbaseXX_XXX_Matched_L6".Phase_no
 AND "XXbaseXX_XXX_MATCHED_L2".Verb               = 'ProjectSupply'
  AND "XXbaseXX_XXX_Matched_L6".run_id IS NULL;),

      "32 INSERT INTO XXbaseXX_XXX_Part_Cred" => qq(
INSERT INTO "XXbaseXX_XXX_Part_Cred" (
  Run_ID, Task_ID, Agent, Verb, L2_NSN_Number, NSN_Number, ClassName,
  SupplyClass, SupplyType, From_Location, For_Organization,
  To_Location, Maintain_Type, Maintain_TypeID,
  Maintain_ItemID, Maintain_Nomenclature, Preferred_Quantity,
  Preferred_Start_Date, Preferred_End_Date, Preferred_Rate, Phased, Phase_no,
  Confidence, Success, Quantity, Start_Date, End_Date, Rate,
  Score_Quantity, Score_Start_Date, Score_End_Date, Score_Rate,
  Deviation_Quantity, Deviation_Start_Date, Deviation_End_Date,
  Deviation_Rate, Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
  Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
  Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
  Base_Confidence, Base_Score_Quantity, Base_Score_Start_Date,
  Base_Score_End_Date, Base_Score_Rate, Base_Deviation_Quantity,
  Base_Deviation_Start_Date, Base_Deviation_End_Date,
  Base_Deviation_Rate)
SELECT DISTINCT
  "Stressed_L2".Run_ID,
  "Stressed_L2".Task_ID,
  "Incomplete_L6".Agent,
  "Incomplete_L6".Verb,
  "Stressed_L2".NSN_Number,
  "Incomplete_L6".NSN_Number,
  "Incomplete_L6".ClassName,
  "Incomplete_L6".SupplyClass,
  "Incomplete_L6".SupplyType,
  "Incomplete_L6".From_Location,
  "Incomplete_L6".For_Organization,
  "Incomplete_L6".To_Location,
  "Incomplete_L6".Maintain_Type,
  "Incomplete_L6".Maintain_TypeID,
  "Incomplete_L6".Maintain_ItemID,
  "Incomplete_L6".Maintain_Nomenclature,
  "Incomplete_L6".Preferred_Quantity,
  "Incomplete_L6".Preferred_Start_Date,
  "Incomplete_L6".Preferred_End_Date,
  "Incomplete_L6".Preferred_Rate,
  "Stressed_L2".Phased,
  "Stressed_L2".Phase_no,
  "Stressed_L2".Confidence,
  "Stressed_L2".Success,
  "Stressed_L2".Quantity,
  "Stressed_L2".Start_Date,
  "Stressed_L2".End_Date,
  "Stressed_L2".Rate,
  "Stressed_L2".Score_Quantity,
  "Stressed_L2".Score_Start_Date,
  "Stressed_L2".Score_End_Date,
  "Stressed_L2".Score_Rate,
  "Stressed_L2".Deviation_Quantity,
  "Stressed_L2".Deviation_Start_Date,
  "Stressed_L2".Deviation_End_Date,
  "Stressed_L2".Deviation_Rate,
  "Stressed_L2".Scoring_Fn_Quantity,
  "Stressed_L2".Scoring_Fn_Start_Date,
  "Stressed_L2".Scoring_Fn_End_Date,
  "Stressed_L2".Scoring_Fn_Rate,
  "Stressed_L2".Pref_Score_Quantity,
  "Stressed_L2".Pref_Score_Start_Date,
  "Stressed_L2".Pref_Score_End_Date,
  "Stressed_L2".Pref_Score_Rate,
  "XXbaseXX".Confidence,
  "XXbaseXX".Score_Quantity,
  "XXbaseXX".Score_Start_Date,
  "XXbaseXX".Score_End_Date,
  "XXbaseXX".Score_Rate,
  "XXbaseXX".Deviation_Quantity,
  "XXbaseXX".Deviation_Start_Date,
  "XXbaseXX".Deviation_End_Date,
  "XXbaseXX".Deviation_Rate
FROM Stressed_XXX "Stressed_L2", Stressed_XXX "Incomplete_L6", "XXbaseXX"
WHERE "Stressed_L2".Agent             = "Incomplete_L6".Agent
 AND "Stressed_L2".Verb               = "Incomplete_L6".Verb
 AND "Stressed_L2".ClassName          = "Incomplete_L6".ClassName
 AND "Stressed_L2".SupplyClass        = "Incomplete_L6".SupplyClass
 AND "Stressed_L2".SupplyType         = "Incomplete_L6".SupplyType
 AND "Stressed_L2".For_Organization   = "Incomplete_L6".For_Organization
 AND "Stressed_L2".To_Location        = "Incomplete_L6".To_Location
 AND "Stressed_L2".Maintain_Type      = "Incomplete_L6".Maintain_Type
 AND "Stressed_L2".Maintain_TypeID    = "Incomplete_L6".Maintain_TypeID
 AND "Stressed_L2".Maintain_ItemID    = "Incomplete_L6".Maintain_ItemID
 AND "Stressed_L2".Maintain_Nomenclature = "Incomplete_L6".Maintain_Nomenclature
 AND "Stressed_L2".Preferred_Quantity = "Incomplete_L6".Preferred_Quantity
 AND "Stressed_L2".Preferred_End_Date = "Incomplete_L6".Preferred_End_Date
 AND "Stressed_L2".Phased             = "Incomplete_L6".Phased
 AND "Stressed_L2".Phase_no           = "Incomplete_L6".Phase_no
 AND "Stressed_L2".Agent              = "XXbaseXX".Agent
 AND "Stressed_L2".Verb               = "XXbaseXX".Verb
 AND "Stressed_L2".ClassName          = "XXbaseXX".ClassName
 AND "Stressed_L2".SupplyClass        = "XXbaseXX".SupplyClass
 AND "Stressed_L2".SupplyType         = "XXbaseXX".SupplyType
 AND "Stressed_L2".For_Organization   = "XXbaseXX".For_Organization
 AND "Stressed_L2".To_Location        = "XXbaseXX".To_Location
 AND "Stressed_L2".Maintain_Type      = "XXbaseXX".Maintain_Type
 AND "Stressed_L2".Maintain_TypeID    = "XXbaseXX".Maintain_TypeID
 AND "Stressed_L2".Maintain_ItemID    = "XXbaseXX".Maintain_ItemID
 AND "Stressed_L2".Maintain_Nomenclature = "XXbaseXX".Maintain_Nomenclature
 AND "Stressed_L2".Preferred_Quantity = "XXbaseXX".Preferred_Quantity
 AND "Stressed_L2".Preferred_End_Date = "XXbaseXX".Preferred_End_Date
 AND "Stressed_L2".Phased             = "XXbaseXX".Phased
 AND "Stressed_L2".Phase_no           = "XXbaseXX".Phase_no
 AND "XXbaseXX".NSN_Number LIKE 'Level2%'
 AND "Stressed_L2".NSN_Number LIKE 'Level2%'
 AND "Incomplete_L6".Confidence  < 0.89
 AND "Stressed_L2".Verb               = 'Supply';),

      "33 INSERT INTO XXbaseXX_XXX_Part_Cred" => qq(
INSERT INTO "XXbaseXX_XXX_Part_Cred" (
  Run_ID, Task_ID, Agent, Verb, L2_NSN_Number, NSN_Number, ClassName,
  SupplyClass, SupplyType, From_Location, For_Organization,
  To_Location, Maintain_Type, Maintain_TypeID,
  Maintain_ItemID, Maintain_Nomenclature, Preferred_Quantity,
  Preferred_Start_Date, Preferred_End_Date, Preferred_Rate, Phased, Phase_no,
  Confidence, Success, Quantity, Start_Date, End_Date, Rate,
  Score_Quantity, Score_Start_Date, Score_End_Date, Score_Rate,
  Deviation_Quantity, Deviation_Start_Date, Deviation_End_Date,
  Deviation_Rate, Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
  Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
  Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
  Base_Confidence, Base_Score_Quantity, Base_Score_Start_Date,
  Base_Score_End_Date, Base_Score_Rate, Base_Deviation_Quantity,
  Base_Deviation_Start_Date, Base_Deviation_End_Date,
  Base_Deviation_Rate)
SELECT DISTINCT
  "Stressed_L2".Run_ID,
  "Stressed_L2".Task_ID,
  "Incomplete_L6".Agent,
  "Incomplete_L6".Verb,
  "Stressed_L2".NSN_Number,
  "Incomplete_L6".NSN_Number,
  "Incomplete_L6".ClassName,
  "Incomplete_L6".SupplyClass,
  "Incomplete_L6".SupplyType,
  "Incomplete_L6".From_Location,
  "Incomplete_L6".For_Organization,
  "Incomplete_L6".To_Location,
  "Incomplete_L6".Maintain_Type,
  "Incomplete_L6".Maintain_TypeID,
  "Incomplete_L6".Maintain_ItemID,
  "Incomplete_L6".Maintain_Nomenclature,
  "Incomplete_L6".Preferred_Quantity,
  "Incomplete_L6".Preferred_Start_Date,
  "Incomplete_L6".Preferred_End_Date,
  "Incomplete_L6".Preferred_Rate,
  "Stressed_L2".Phased,
  "Stressed_L2".Phase_no,
  "Stressed_L2".Confidence,
  "Stressed_L2".Success,
  "Stressed_L2".Quantity,
  "Stressed_L2".Start_Date,
  "Stressed_L2".End_Date,
  "Stressed_L2".Rate,
  "Stressed_L2".Score_Quantity,
  "Stressed_L2".Score_Start_Date,
  "Stressed_L2".Score_End_Date,
  "Stressed_L2".Score_Rate,
  "Stressed_L2".Deviation_Quantity,
  "Stressed_L2".Deviation_Start_Date,
  "Stressed_L2".Deviation_End_Date,
  "Stressed_L2".Deviation_Rate,
  "Stressed_L2".Scoring_Fn_Quantity,
  "Stressed_L2".Scoring_Fn_Start_Date,
  "Stressed_L2".Scoring_Fn_End_Date,
  "Stressed_L2".Scoring_Fn_Rate,
  "Stressed_L2".Pref_Score_Quantity,
  "Stressed_L2".Pref_Score_Start_Date,
  "Stressed_L2".Pref_Score_End_Date,
  "Stressed_L2".Pref_Score_Rate,
  "XXbaseXX".Confidence,
  "XXbaseXX".Score_Quantity,
  "XXbaseXX".Score_Start_Date,
  "XXbaseXX".Score_End_Date,
  "XXbaseXX".Score_Rate,
  "XXbaseXX".Deviation_Quantity,
  "XXbaseXX".Deviation_Start_Date,
  "XXbaseXX".Deviation_End_Date,
  "XXbaseXX".Deviation_Rate
FROM Stressed_XXX "Stressed_L2", Stressed_XXX "Incomplete_L6", "XXbaseXX"
WHERE "Stressed_L2".Agent             = "Incomplete_L6".Agent
 AND "Stressed_L2".Verb               = "Incomplete_L6".Verb
 AND "Stressed_L2".ClassName          = "Incomplete_L6".ClassName
 AND "Stressed_L2".SupplyClass        = "Incomplete_L6".SupplyClass
 AND "Stressed_L2".SupplyType         = "Incomplete_L6".SupplyType
 AND "Stressed_L2".For_Organization   = "Incomplete_L6".For_Organization
 AND "Stressed_L2".To_Location        = "Incomplete_L6".To_Location
 AND "Stressed_L2".Maintain_Type      = "Incomplete_L6".Maintain_Type
 AND "Stressed_L2".Maintain_TypeID    = "Incomplete_L6".Maintain_TypeID
 AND "Stressed_L2".Maintain_ItemID    = "Incomplete_L6".Maintain_ItemID
 AND "Stressed_L2".Maintain_Nomenclature = "Incomplete_L6".Maintain_Nomenclature
 AND "Stressed_L2".Preferred_Start_Date = "Incomplete_L6".Preferred_Start_Date
 AND "Stressed_L2".Preferred_End_Date = "Incomplete_L6".Preferred_End_Date
 AND "Stressed_L2".Phased           = "Incomplete_L6".Phased
 AND "Stressed_L2".Phase_no           = "Incomplete_L6".Phase_no
 AND "Stressed_L2".Agent              = "XXbaseXX".Agent
 AND "Stressed_L2".Verb               = "XXbaseXX".Verb
 AND "Stressed_L2".ClassName          = "XXbaseXX".ClassName
 AND "Stressed_L2".SupplyClass        = "XXbaseXX".SupplyClass
 AND "Stressed_L2".SupplyType         = "XXbaseXX".SupplyType
 AND "Stressed_L2".For_Organization   = "XXbaseXX".For_Organization
 AND "Stressed_L2".To_Location        = "XXbaseXX".To_Location
 AND "Stressed_L2".Maintain_Type      = "XXbaseXX".Maintain_Type
 AND "Stressed_L2".Maintain_TypeID    = "XXbaseXX".Maintain_TypeID
 AND "Stressed_L2".Maintain_ItemID    = "XXbaseXX".Maintain_ItemID
 AND "Stressed_L2".Maintain_Nomenclature = "XXbaseXX".Maintain_Nomenclature
 AND "Stressed_L2".Preferred_Quantity = "XXbaseXX".Preferred_Quantity
 AND "Stressed_L2".Preferred_End_Date = "XXbaseXX".Preferred_End_Date
 AND "Stressed_L2".Phased             = "XXbaseXX".Phased
 AND "Stressed_L2".Phase_no           = "XXbaseXX".Phase_no
 AND "XXbaseXX".NSN_Number LIKE 'Level2%'
 AND "Stressed_L2".NSN_Number LIKE 'Level2%'
 AND "Stressed_L2".Confidence  > 0.89
 AND "Incomplete_L6".Confidence  < 0.89
 AND "Stressed_L2".Verb               = 'ProjectSupply';),

      "34 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Dev_Is_CC_Quantity =
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Quantity IS NULL then NULL
                when Base_Deviation_Quantity IS NULL then 1
                when Deviation_Quantity >
                                    0.05 + Base_Deviation_Quantity then 0
                else 1
                end
WHERE Verb               = 'Supply';),

      "35 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Dev_Is_CC_End_Date =
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_End_Date IS NULL then NULL
                when Base_Deviation_End_Date IS NULL then 1
                when Deviation_End_Date  >
                                    0.05 + Base_Deviation_End_Date then 0
                else 1
                end
WHERE Verb               = 'Supply';),

      "36 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Is_CC_Quantity =
                case
                when Confidence < 0.89            then NULL
                when Score_Quantity IS NULL then NULL
                when Base_Score_Quantity IS NULL then 1
                when Score_Quantity > Base_Score_Quantity then 0
                else 1
                end
WHERE Verb               = 'Supply';),

      "37 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Is_CC_End_Date =
                case
                when Confidence < 0.89            then NULL
                when Score_End_Date IS NULL then NULL
                when Base_Score_End_Date IS NULL then 1
                when Score_End_Date  >
                     Base_Score_End_Date then 0
                else 1
                end
WHERE Verb               = 'Supply';),

      "38 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Dev_Is_CC_Start_Date =
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Start_Date IS NULL then NULL
                when Base_Deviation_Start_Date IS NULL then 1
                when Deviation_Start_Date >
                                    0.05 + Base_Deviation_Start_Date then 0
                else 1
                end
WHERE Verb               = 'ProjectSupply';),

      "39 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Dev_Is_CC_End_Date =
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_End_Date IS NULL then NULL
                when Base_Deviation_End_Date IS NULL then 1
                when Deviation_End_Date  >
                                    0.05 + Base_Deviation_End_Date then 0
                else  1
                end
WHERE Verb               = 'ProjectSupply';),


      "40 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Is_CC_Start_Date =
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Rate IS NULL then NULL
                when Base_Deviation_Rate IS NULL then 1
                when Deviation_Rate  >
                                    0.05 + Base_Deviation_Rate then 0
                else  1
                end
WHERE Verb               = 'ProjectSupply';),

      "41 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Is_CC_End_Date =
                case
                when Confidence < 0.89            then NULL
                when Score_Start_Date IS NULL then NULL
                when Base_Score_Start_Date IS NULL then 1
                when Score_Start_Date >
                     Base_Score_Start_Date         then 0
                else 1
                end
WHERE Verb               = 'ProjectSupply';),


      "42 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Is_CC_Start_Date =
                case
                when Confidence < 0.89            then NULL
                when Score_End_Date IS NULL then NULL
                when Base_Score_End_Date IS NULL then 1
                when Score_End_Date >
                     Base_Score_End_Date          then 0
                     else 1
                end
WHERE Verb               = 'ProjectSupply';),

      "43 UPDATE  XXbaseXX_XXX_Part_Cred" => qq(
UPDATE  "XXbaseXX_XXX_Part_Cred"
SET Is_CC_End_Date =
                case
                when Confidence < 0.89            then NULL
                when Score_Rate IS NULL then NULL
                when Base_Score_Rate IS NULL then 1
                when Score_Rate >
                     Base_Score_Rate          then 0
                     else 1
                end
WHERE Verb               = 'ProjectSupply';)
     }
    );
  for my $datum (keys %Completion ) {
    no strict "refs";
    *$datum = sub {
      use strict "refs";
      my ($self, $newvalue) = @_;
      $Completion{$datum} = $newvalue if @_ > 1;
      return $Completion{$datum};
    }
  }
}

sub new{
  my $this = shift;
  my %params = @_;
  my $class = ref($this) || $this;
  my $self = {};
  warn "New CnCCalc::Completion object" if $::ConfOpts{'TRACE_SUBS'};

  bless $self, $class;

  $self->{' _Debug'} = 0;
  return $self;
}

sub create_tables() {
  my $self = shift;
  my %params = @_;

  warn "CnCCalc::Completion::create_tables" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'DB Handle' missing"
    unless defined $params{'DB Handle'};
  die "Required parameter 'Baseline Name' missing"
    unless defined $params{'Baseline Name'};
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
  for my $drop_table (@{$self->Clean()}) {
    $drop_table =~ s/XXbaseXX/$params{'Baseline Name'}/g;
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
	  warn "Could not drop table ($err)";
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
    $instruction =~ s/XXbaseXX/$params{'Baseline Name'}/g;
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
    warn "$now_string: doing instruction $count" if $count;
    eval {
      $retval = $dbh->do($instruction);
    };
    if ($@ || ! defined $retval) {
      warn "Instruction number $count failed.";
      warn "undef value returned" unless defined $retval;
      $err = $dbh->errstr;
      warn "$err";
      $body .= "Failed instruction number $count ($table).<br>$@<br></li>\n";
      $return_code = $dbh->err;
      last;
    }
    else {
      warn "Instruction number $count worked.";
      my $rc = $dbh->commit;
      if (! $rc) {
	$return_code = $dbh->err;
	$err = $dbh->errstr;
	warn "Could not commit data ($err)";
	last;
      }
      else {
	warn "Committed changes\n";
      }
      $body .= qq(<li>Instruction $count\n);
      $body .= qq( ($table)) if $table;
      $body .= qq( done</li>\n);
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

  warn "CnCCalc::Completion::dump" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'Baseline Name' missing"
    unless defined $params{'Baseline Name'};
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
    $instruction =~ s/XXbaseXX/$params{'Baseline Name'}/g;
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
