\!date

-- 00 (drop_Scoring_Constants) 
 DROP TABLE  Scoring_Constants; 

-- 01 (Scoring_Constants) 
 CREATE TABLE Scoring_Constants (
ID          varchar(31) PRIMARY KEY  default '',
A           double precision          default '0',
B           double precision          default '10',
C           double precision          default 0,
D           double precision          default 0,
E           double precision          default 0,
F           double precision          default 0,
G           double precision          default 0,
H           double precision          default 0,
I           double precision          default '2.5'
); 

-- 02 (Insert_Scoring_Constant) 
 INSERT INTO Scoring_Constants
VALUES ('Default', '0', '10', '0', '0', '0', '0', '0', '0', '2.5'); 

-- 03 (drop_Temp_Seventh_day) 
 DROP TABLE Temp_Seventh_day; 

-- 04 (Temp_Seventh_day) 
 CREATE TABLE Temp_Seventh_day (
   Boundary        double  precision     default '1124323200000.0'
); 

-- 05 (Insert_Temp_Seventh_day) 
 INSERT INTO Temp_Seventh_day VALUES ('1124323200000.0'); 

-- 06 (drop_Temp_XXbaseXX_Results) 
 DROP TABLE Temp_Baseline_Results; 

-- 07 (Temp_XXbaseXX_Results) 
 CREATE  TABLE Temp_Baseline_Results (
  run_id                integer  NOT NULL,
  task_id               varchar(63) NOT NULL,
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
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
); 

-- 08 (drop_Temp_XXbaseXX_OP) 
 DROP TABLE Temp_Baseline_OP; 

-- 09 (Temp_XXbaseXX_OP) 
 CREATE   TABLE Temp_Baseline_OP (
  run_id                integer  NOT NULL,
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
  Maintaining           varchar(63)          default NULL,
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

-- 10 (drop_Temp_XXbaseXX) 
 DROP TABLE Temp_Baseline; 

-- 11 (Temp_XXbaseXX) 
 CREATE  TABLE Temp_Baseline (
  run_id                integer  NOT NULL,
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
  Maintaining           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Preferred_Rate        double precision              default NULL,
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
); 

-- 12 (drop_Temp_XXbaseXX_Phased) 
 DROP TABLE Temp_Baseline_Phased; 

-- 13 (Temp_XXbaseXX_Phased) 
 CREATE  TABLE Temp_Baseline_Phased (
  run_id                integer  NOT NULL,
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
  Maintaining           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Preferred_Rate        double precision              default NULL,
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
); 

-- 14 (XXbaseXX) 
 DROP TABLE  Baseline; 

-- 15 (XXbaseXX) 
 CREATE TABLE Baseline (
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  ClassName             varchar(255)         default NULL,
  SupplyClass           varchar(63)          default NULL,
  SupplyType            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Maintaining           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Preferred_Rate        double precision              default NULL,
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
); 

\!date

-- 16 (Insert_Temp_OP) 
 INSERT INTO Temp_Baseline_OP (run_id, task_id, 
                              Agent, Verb, NSN_Number,
                              ClassName, SupplyClass,
                              SupplyType, From_Location, To_Location,
                              Preferred_Start_Date,
                              Preferred_End_Date,
                              Scoring_Fn_Start_Date,
                              Scoring_Fn_End_Date,
                              Pref_Score_Start_Date,
                              Pref_Score_End_Date)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb, 
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prep2.val as From_Location, prep1.val as To_Location,
       pref2.bestvalue as Preferred_Start_Date, pref1.bestvalue as
       Preferred_End_Date, pref2.scoringfunction as
       Scoring_Fn_Start_Date, pref1.scoringfunction as
       Scoring_Fn_End_Date, pref2.score as Pref_Score_Start_Date,
       pref1.score as Pref_Score_End_Date
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, assets
WHERE tasks.run_id in (SELECT ID FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb               = 'Transport'
  AND prep1.prep               = 'To'
  AND prep1.task_id            = tasks.id
  AND prep1.run_id             = tasks.run_id
  AND prep2.prep               = 'From'
  AND prep2.task_id            = tasks.id
  AND prep2.run_id             = tasks.run_id
  AND pref1.aspecttype         = 'END_TIME'
  AND pref1.task_id            = tasks.id
  AND pref1.run_id             = tasks.run_id
  AND pref2.aspecttype         = 'START_TIME' 
  AND pref2.task_id            = tasks.id
  AND pref2.run_id             = tasks.run_id
  AND assets.run_id            = tasks.run_id
  AND assets.task_id           = tasks.id; 

\!date

-- 17 (Insert_Temp_Results) 
 
INSERT INTO Temp_Baseline_Results (run_id, task_id,
                                   Agent, Verb, Phase_no,
                                   Confidence, Success,
                                   Start_Date, End_Date, 
                                   Score_Start_Date,
                                   Score_End_Date)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb, 
       phval1.phase_no, allocation_results.confidence,
       allocation_results.Success, phval1.value as Start_Date,
       phval2.value as End_Date, phval1.score as Score_Start_Date,
       phval2.score as Score_End_Date
FROM tasks, allocation_results, 
     phased_aspects phval1, phased_aspects phval2
WHERE tasks.run_id in (SELECT ID FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
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

\!date

-- 18 (Insert_Temp_OP) 
 
INSERT INTO Temp_Baseline_OP (run_id, task_id, Agent,
                              Verb, NSN_Number,
                              ClassName, SupplyClass, SupplyType,
                              For_Organization, To_Location,
                              Maintaining, Preferred_Quantity,
                              Preferred_End_Date, Scoring_Fn_Quantity,
                              Scoring_Fn_End_Date,
                              Pref_Score_Quantity,
                              Pref_Score_End_Date)
SELECT DISTINCT
       tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prep2.val as For_Organization, prep1.val as To_Location,
       prep3.val as Maintaining,
       pref2.bestvalue as Preferred_Quantity, 
       pref1.bestvalue as Preferred_End_Date,
       pref2.scoringfunction as Scoring_Fn_Quantity,
       pref1.scoringfunction as Scoring_Fn_End_Date,
       pref2.score as Pref_Score_Quantity,
       pref1.score as Pref_Score_End_Date
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, prepositions prep3, assets
WHERE tasks.run_id in (SELECT ID FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb       = 'Supply'
  AND prep1.prep       = 'To'
  AND prep1.run_id     = tasks.run_id
  AND prep1.task_id    = tasks.id
  AND prep2.prep       = 'For'
  AND prep2.run_id     = tasks.run_id
  AND prep2.task_id    = tasks.id
  AND prep3.prep       = 'Maintaining'
  AND prep3.run_id     = tasks.run_id
  AND prep3.task_id    = tasks.id
  AND pref1.aspecttype = 'END_TIME'
  AND pref1.run_id     = tasks.run_id
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'QUANTITY'
  AND pref2.run_id     = tasks.run_id
  AND pref2.task_id    = tasks.id
  AND assets.run_id    = tasks.run_id
  AND assets.task_id   = tasks.id; 

\!date

-- 19 (Insert_Temp_Results) 
 
INSERT INTO Temp_Baseline_Results (run_id, task_id,
                                   Agent, Verb, Phase_no, 
                                   Confidence, Success,
                                   Quantity, End_Date, Score_Quantity, 
                                   Score_End_Date)
SELECT DISTINCT
       tasks.run_id, tasks.id, tasks.agent, tasks.Verb,
       phval1.phase_no, 
       allocation_results.confidence,  allocation_results.Success,
       phval1.value as Quantity,
       phval2.value as End_Date,    
       phval1.score as Score_Quantity,
       phval2.score as Score_End_Date
FROM tasks, allocation_results, phased_aspects phval1, phased_aspects phval2,
     Scoring_Constants t2
WHERE tasks.run_id in (SELECT ID FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
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

\!date

-- 20 (Insert_Temp_OP) 
 INSERT INTO Temp_Baseline_OP (run_id, task_id,
                              Agent, Verb, NSN_Number, 
                              ClassName, SupplyClass, SupplyType,
                              For_Organization, To_Location,
                              Maintaining, Preferred_Start_Date,
            	      	      Preferred_End_Date, Preferred_Rate,
			      Scoring_Fn_Start_Date,
                              Scoring_Fn_End_Date, Scoring_Fn_Rate,
			      Pref_Score_Start_Date,
                              Pref_Score_End_Date, Pref_Score_Rate)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb, 
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prep2.val as For_Organization, prep1.val as To_Location, 
       prep3.val as Maintaining, 
       pref2.bestvalue as Preferred_Start_Date, 
       pref1.bestvalue as Preferred_End_Date,
       pref3.bestvalue as Preferred_Rate,
       pref2.scoringfunction as Scoring_Fn_Start_Date,
       pref1.scoringfunction as Scoring_Fn_End_Date,
       pref3.scoringfunction as Scoring_Fn_Rate,
       pref2.score as Pref_Score_Start_Date,
       pref1.score as Pref_Score_End_Date,
       pref3.score as Pref_Score_Rate
FROM tasks, preferences pref1, preferences pref2, preferences pref3,
     prepositions prep1, prepositions prep2, prepositions prep3,
     assets
WHERE tasks.run_id in (SELECT ID FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb       = 'ProjectSupply'
  AND prep1.prep       = 'To'
  AND prep1.task_id    = tasks.id
	AND prep1.run_id     = tasks.run_id
  AND prep2.prep       = 'For'
	AND prep2.run_id     = tasks.run_id
  AND prep2.task_id    = tasks.id
  AND prep3.prep       = 'Maintaining'
	AND prep3.run_id     = tasks.run_id
  AND prep3.task_id    = tasks.id
  AND pref1.aspecttype = 'END_TIME'
	AND pref1.run_id     = tasks.run_id
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'START_TIME'
	AND pref2.run_id     = tasks.run_id
  AND pref2.task_id    = tasks.id
  AND pref3.aspecttype = '15'
	AND pref3.run_id     = tasks.run_id
  AND pref3.task_id    = tasks.id
	AND assets.run_id    = tasks.run_id
  AND assets.task_id   = tasks.id; 

\!date

-- 21 (Insert_Temp_Results) 
 
INSERT INTO Temp_Baseline_Results (run_id, task_id,
                           	   Agent, Verb, 
                           	   Phase_no, Confidence, Success,
                                   Start_Date, End_Date, Rate,
                                   Score_Start_Date, Score_End_Date,
                                   Score_Rate)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb, 
       phval1.phase_no,
       allocation_results.confidence,  allocation_results.Success,
       phval1.value as Start_Date,
       phval2.value as End_Date,
       phval3.value as Rate,
       phval1.score as Score_Start_Date,
       phval2.score as Score_End_Date,
       phval3.score as Score_Rate
FROM tasks, allocation_results, phased_aspects phval1, phased_aspects phval2,
     phased_aspects phval3
WHERE tasks.run_id in (SELECT ID FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
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

\!date

-- 22 (Insert_Temp_Phased) 
 
INSERT INTO Temp_Baseline_Phased (run_id, task_id,
                           Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType, From_Location,
                           To_Location, Preferred_Start_Date,
                           Preferred_End_Date, Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Phase_no, Confidence,
                           Success, Start_Date, End_Date,
                           Score_Start_Date, Score_End_Date)
SELECT Temp_Baseline_OP.run_id, Temp_Baseline_OP.task_id,
       Temp_Baseline_OP.Agent, Temp_Baseline_OP.Verb,
       Temp_Baseline_OP.NSN_Number, 
       Temp_Baseline_OP.ClassName, 
       Temp_Baseline_OP.SupplyClass, 
       Temp_Baseline_OP.SupplyType, 
       Temp_Baseline_OP.From_Location,
       Temp_Baseline_OP.To_Location,
       Temp_Baseline_OP.Preferred_Start_Date,
       Temp_Baseline_OP.Preferred_End_Date,
       Temp_Baseline_OP.Scoring_Fn_Start_Date,
       Temp_Baseline_OP.Scoring_Fn_End_Date,
       Temp_Baseline_OP.Pref_Score_Start_Date,
       Temp_Baseline_OP.Pref_Score_End_Date,
       Temp_Baseline_Results.Phase_no,
       Temp_Baseline_Results.confidence,  
       Temp_Baseline_Results.Success,
       Temp_Baseline_Results.Start_Date,
       Temp_Baseline_Results.End_Date,
       Temp_Baseline_Results.Score_Start_Date,
       Temp_Baseline_Results.Score_End_Date
FROM Temp_Baseline_OP FULL OUTER JOIN Temp_Baseline_Results
     ON (Temp_Baseline_OP.task_id = Temp_Baseline_Results.task_id AND
         Temp_Baseline_OP.run_id  = Temp_Baseline_Results.run_id)
WHERE Temp_Baseline_OP.verb    = 'Transport'; 

\!date

-- 23 (Insert_Temp_Phased) 
 
INSERT INTO Temp_Baseline_Phased (run_id, task_id,
                           Agent, Verb, NSN_Number,
                           ClassName, SupplyClass, SupplyType, 
                           For_Organization, To_Location, Maintaining,
                           Preferred_Quantity,
            	      	   Preferred_End_Date, Scoring_Fn_Quantity,
                           Scoring_Fn_End_Date, Pref_Score_Quantity,
                           Pref_Score_End_Date, Phase_no, Confidence,
                           Success, Quantity, End_Date,
            	      	   Score_Quantity, Score_End_Date)
SELECT DISTINCT
       Temp_Baseline_OP.run_id, Temp_Baseline_OP.task_id,
       Temp_Baseline_OP.Agent, Temp_Baseline_OP.Verb,
       Temp_Baseline_OP.NSN_Number, 
       Temp_Baseline_OP.ClassName, 
       Temp_Baseline_OP.SupplyClass,
       Temp_Baseline_OP.SupplyType,
       Temp_Baseline_OP.For_Organization,
       Temp_Baseline_OP.To_Location,
       Temp_Baseline_OP.Maintaining,
       Temp_Baseline_OP.Preferred_Quantity,
       Temp_Baseline_OP.Preferred_End_Date,
       Temp_Baseline_OP.Scoring_Fn_Quantity,
       Temp_Baseline_OP.Scoring_Fn_End_Date,
       Temp_Baseline_OP.Pref_Score_Quantity,
       Temp_Baseline_OP.Pref_Score_End_Date,
       Temp_Baseline_Results.Phase_no, 
       Temp_Baseline_Results.Confidence, 
       Temp_Baseline_Results.Success,
       Temp_Baseline_Results.Quantity, 
       Temp_Baseline_Results.End_Date,
       Temp_Baseline_Results.Score_Quantity,
       Temp_Baseline_Results.Score_End_Date
FROM Temp_Baseline_OP FULL OUTER JOIN Temp_Baseline_Results 
       ON (Temp_Baseline_OP.task_id = Temp_Baseline_Results.task_id AND
           Temp_Baseline_OP.run_id  = Temp_Baseline_Results.run_id)
WHERE Temp_Baseline_OP.verb    = 'Supply'; 

\!date

-- 24 (Insert_Temp_Phased) 
 
INSERT INTO Temp_Baseline_Phased(run_id, task_id,
                         Agent, Verb, NSN_Number, 
                         ClassName, SupplyClass, SupplyType, For_Organization, 
                         To_Location, Maintaining, Preferred_Start_Date,
            	      	   Preferred_End_Date, Preferred_Rate, 
	                   Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                         Scoring_Fn_Rate, Pref_Score_Start_Date,
                         Pref_Score_End_Date, Pref_Score_Rate,
	                   Phase_no, Confidence, Success, Start_Date,
	                   End_Date, Rate, Score_Start_Date,
	                   Score_End_Date, Score_Rate)
SELECT Temp_Baseline_OP.run_id, Temp_Baseline_OP.task_id,
       Temp_Baseline_OP.Agent, Temp_Baseline_OP.Verb,
       Temp_Baseline_OP.NSN_Number, 
       Temp_Baseline_OP.ClassName, 
       Temp_Baseline_OP.SupplyClass, 
       Temp_Baseline_OP.SupplyType,
       Temp_Baseline_OP.For_Organization,
       Temp_Baseline_OP.To_Location,
       Temp_Baseline_OP.Maintaining,
       Temp_Baseline_OP.Preferred_Start_Date,
       Temp_Baseline_OP.Preferred_End_Date,
       Temp_Baseline_OP.Preferred_Rate,
       Temp_Baseline_OP.Scoring_Fn_Start_Date,
       Temp_Baseline_OP.Scoring_Fn_End_Date,
       Temp_Baseline_OP.Scoring_Fn_Rate,
       Temp_Baseline_OP.Pref_Score_Start_Date,
       Temp_Baseline_OP.Pref_Score_End_Date,
       Temp_Baseline_OP.Pref_Score_Rate,
       Temp_Baseline_Results.Phase_no,
       Temp_Baseline_Results.Confidence, 
       Temp_Baseline_Results.Success,
       Temp_Baseline_Results.Start_Date,
       Temp_Baseline_Results.End_Date,
       Temp_Baseline_Results.Rate,
       Temp_Baseline_Results.Score_Start_Date,
       Temp_Baseline_Results.Score_End_Date,
       Temp_Baseline_Results.Score_Rate
FROM Temp_Baseline_OP FULL OUTER JOIN Temp_Baseline_Results
       ON (Temp_Baseline_OP.task_id = Temp_Baseline_Results.task_id AND
           Temp_Baseline_OP.run_id  = Temp_Baseline_Results.run_id)
WHERE Temp_Baseline_OP.verb    = 'ProjectSupply'; 

\!date

-- 25 (Insert_Temp_Baseline) 
 
INSERT INTO Temp_Baseline (run_id, task_id,
                           Agent, Verb, NSN_Number,
                           ClassName, SupplyClass,
                           SupplyType, From_Location,
                           For_Organization, To_Location, Maintaining,
                           Preferred_Quantity, Preferred_Start_Date,
                           Preferred_End_Date, Preferred_Rate,
                           Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Scoring_Fn_Rate,
                           Pref_Score_Quantity, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Pref_Score_Rate,
                           Phase_no, Confidence, Success, Quantity,
                           Start_Date, End_Date, Rate, Score_Quantity,
                           Score_Start_Date, Score_End_Date,
                           Score_Rate)
SELECT DISTINCT
       run_id, task_id, Agent, Verb, NSN_Number,
       ClassName, SupplyClass, SupplyType,
       From_Location, For_Organization, To_Location, Maintaining,
       Preferred_Quantity, Preferred_Start_Date, Preferred_End_Date,
       Preferred_Rate, Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
       Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
       Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
       Phase_no, Confidence, Success, Quantity, Start_Date, End_Date,
       Rate, Score_Quantity, Score_Start_Date, Score_End_Date,
       Score_Rate
FROM Temp_Baseline_Phased
WHERE task_id not in (SELECT DISTINCT  task_ID from Temp_Baseline_Phased
                      WHERE Phase_no > 0); 

\!date

-- 26 (Insert_Temp_Baseline) 
 
INSERT INTO Temp_Baseline (run_id, task_id,
                           Agent, Verb, NSN_Number,
                           ClassName, SupplyClass,
                           SupplyType, For_Organization, To_Location,
                           Maintaining, Preferred_Quantity,
            	      	   Preferred_End_Date, Scoring_Fn_Quantity,
                           Scoring_Fn_End_Date, Pref_Score_Quantity,
                           Pref_Score_End_Date, Phase_no, Confidence,
                           Success, Quantity, End_Date,
            	      	   Score_Quantity, Score_End_Date)
SELECT DISTINCT
       t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
       t1.ClassName, t1.SupplyClass, t1.SupplyType,
       t1.For_Organization, t1.To_Location, t1.Maintaining,
       t1.Preferred_Quantity,
       t1.Preferred_End_Date, t1.Scoring_Fn_Quantity, t1.Scoring_Fn_End_Date,
       t1.Pref_Score_Quantity, t1.Pref_Score_End_Date, count(t1.Phase_no),
       sum(t1.Confidence * t1.Quantity / t1.Preferred_Quantity),
       min(t1.Success), sum(t1.Quantity), max(t1.End_Date),
       Consolidated_Quantity.score,  Consolidated_End_Date.score
FROM Temp_Baseline_Phased t1, 
     consolidated_aspects Consolidated_Quantity,
     consolidated_aspects Consolidated_End_Date
WHERE t1.verb    = 'Supply'
  AND Consolidated_Quantity.run_id     = t1.run_id
  AND Consolidated_End_Date.run_id     = t1.run_id
  AND Consolidated_Quantity.task_id    = t1.task_id  
  AND Consolidated_End_Date.task_id    = t1.task_id  
  AND Consolidated_Quantity.aspecttype = 'QUANTITY'
  AND Consolidated_End_Date.aspecttype = 'END_TIME'
  AND t1.task_id in (SELECT DISTINCT  task_ID from Temp_Baseline_Phased
                     WHERE Phase_no > 0)
GROUP BY t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
       	 t1.ClassName, t1.SupplyClass, t1.SupplyType,
       	 t1.For_Organization, t1.To_Location, t1.Maintaining,
       	 t1.Preferred_Quantity, t1.Preferred_End_Date,
       	 t1.Scoring_Fn_Quantity, t1.Scoring_Fn_End_Date,
       	 t1.Pref_Score_Quantity, t1.Pref_Score_End_Date,
       	 Consolidated_Quantity.score, Consolidated_End_Date.score; 

\!date

-- 27 (Insert_Temp_Baseline) 
 
 INSERT INTO Temp_Baseline (run_id, task_id,
                           Agent, Verb, NSN_Number, 
                           ClassName, SupplyClass,
                           SupplyType, For_Organization, To_Location,
                           Maintaining, Preferred_Start_Date,
            	      	   Preferred_End_Date, Preferred_Rate, 
	                   Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                           Scoring_Fn_Rate, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Pref_Score_Rate,
	                   Phase_no, Confidence, Success, Start_Date,
	                   End_Date, Rate, Score_Start_Date,
	                   Score_End_Date, Score_Rate)
SELECT t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number, 
       t1.ClassName, t1.SupplyClass, t1.SupplyType,
       t1.For_Organization, t1.To_Location, t1.Maintaining,
       t1.Preferred_Start_Date, t1.Preferred_End_Date, t1.Preferred_Rate,
       t1.Scoring_Fn_Start_Date, t1.Scoring_Fn_End_Date, t1.Scoring_Fn_Rate,
       t1.Pref_Score_Start_Date, t1.Pref_Score_End_Date, t1.Pref_Score_Rate,
       count(t1.Phase_no),
       sum(t1.Confidence * t1.Rate * (t1.End_Date - t1.Start_Date)) /
          (t1.Preferred_Rate * (max(t1.End_Date) - min(t1.Start_Date))),
       min(t1.Success), min(t1.Start_Date), max(t1.End_Date),
       sum(t1.Rate * (t1.End_Date - t1.Start_Date))/(max(t1.End_Date) - min(t1.Start_Date)) ,
       Consolidated_Start_Date.score, 
       Consolidated_End_Date.score, 
       Consolidated_Rate.score
FROM Temp_Baseline_Phased t1, 
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
 AND  t1.task_id in (SELECT DISTINCT  task_ID from Temp_Baseline_Phased
                     WHERE Phase_no > 0)
GROUP BY t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number, 
         t1.ClassName, t1.SupplyClass, t1.SupplyType,
         t1.For_Organization, t1.To_Location, t1.Maintaining,
         t1.Preferred_Start_Date, t1.Preferred_End_Date,
         t1.Preferred_Rate,
	 t1.Scoring_Fn_Start_Date, t1.Scoring_Fn_End_Date,
         t1.Scoring_Fn_Rate, t1.Pref_Score_Start_Date,
         t1.Pref_Score_End_Date, t1.Pref_Score_Rate,
         Consolidated_Start_Date.score, Consolidated_End_Date.score,
         Consolidated_Rate.score; 

\!date

-- 28 (Update_Temp_Baseline) 
 UPDATE Temp_Baseline 
SET Deviation_Start_Date = 
     POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 4) * t2.E +
     POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 3) * t2.D +
     POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 2) * t2.C +
          ABS(Preferred_Start_Date - Start_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'Transport'
  AND t2.ID      = 'Default'; 

\!date

-- 29 (Update_Temp_Baseline) 
 UPDATE Temp_Baseline 
SET Deviation_End_Date =
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 2) * t2.C +
             ABS(Preferred_End_Date - End_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'Transport'
  AND t2.ID      = 'Default'; 

\!date

-- 30 (Update_Temp_Baseline) 
 UPDATE Temp_Baseline 
SET Deviation_End_Date = 
      (Preferred_Quantity / Quantity ) *
       (POW((ABS(Preferred_End_Date - End_Date) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 2) * t2.C +
             ABS(Preferred_End_Date - End_Date) / 86400000      * t2.B + t2.A)
FROM Scoring_Constants t2
WHERE verb       = 'Supply'
  AND Quantity   > 0
  AND t2.ID      = 'Default'; 

\!date

-- 31 (Update_Temp_Baseline) 
 UPDATE Temp_Baseline 
SET Deviation_Quantity = 
       (Preferred_Quantity / Quantity ) *
       (POW((ABS(Preferred_Quantity - Quantity) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_Quantity - Quantity) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_Quantity - Quantity) / 86400000), 2) * t2.C +
             ABS(Preferred_Quantity - Quantity) / 86400000      * t2.B +  t2.A)
FROM Scoring_Constants t2
WHERE verb    = 'Supply'
  AND Quantity   > 0
  AND t2.ID      = 'Default'; 

\!date

-- 32 (Update_Temp_Baseline) 
 UPDATE Temp_Baseline 
SET Deviation_Start_Date = 
      POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 4) * t2.E +
      POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 3) * t2.D +
      POW((ABS(Preferred_Start_Date - Start_Date) / 86400000), 2) * t2.C +
           ABS(Preferred_Start_Date - Start_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'ProjectSupply'
  AND t2.ID      = 'Default'; 

\!date

-- 33 (Update_Temp_Baseline) 
 UPDATE Temp_Baseline 
SET Deviation_End_Date = 
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 4) * t2.E +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 3) * t2.D +
        POW((ABS(Preferred_End_Date - End_Date) / 86400000), 2) * t2.C +
             ABS(Preferred_End_Date - End_Date) / 86400000      * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'ProjectSupply'
  AND t2.ID      = 'Default'; 

\!date

-- 34 (Update_Temp_Baseline) 
 UPDATE Temp_Baseline 
SET Deviation_Rate = 
        POW((ABS(Preferred_Rate - Rate) ), 4) * t2.E +
        POW((ABS(Preferred_Rate - Rate) ), 3) * t2.D +
        POW((ABS(Preferred_Rate - Rate) ), 2) * t2.C +
             ABS(Preferred_Rate - Rate)       * t2.B + t2.A
FROM Scoring_Constants t2
WHERE verb    = 'ProjectSupply'
  AND t2.ID      = 'Default'; 

\!date

-- 35 (Insert_Baseline) 
 INSERT INTO Baseline(
  Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
  From_Location, To_Location, Preferred_Start_Date,
  Preferred_End_Date, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Pref_Score_Start_Date, Pref_Score_End_Date, Phase_no, Confidence,
  Success, MIN_Start_Date, MIN_End_Date, MAX_Start_Date, MAX_End_Date,
  Score_Start_Date, Score_End_Date, Deviation_Start_Date,
  Deviation_End_Date)
Select Agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType, From_Location, 
       To_Location,
       Preferred_Start_Date, Preferred_End_Date,
       Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
       Pref_Score_Start_Date, Pref_Score_End_Date, 
       Phase_no, Confidence, Success,
       min(Start_Date) 	     as MIN_Start_Date,
       min(End_Date)   	     as MIN_End_Date, 
       max(Start_Date) 	     as MAX_Start_Date,
       max(End_Date)   	     as MAX_End_Date, 
       max(Score_Start_Date) as Score_Start_Date,
       max(Score_End_Date)   as Score_End_Date,   
       max(Deviation_Start_Date) as Deviation_Start_Date,
       max(Deviation_End_Date)   as Deviation_End_Date
FROM Temp_Baseline 
WHERE Verb = 'Transport'
GROUP BY agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType, From_Location,
         To_Location, Preferred_Start_Date, Preferred_End_Date,
         Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
         Pref_Score_Start_Date, Pref_Score_End_Date, 
         Phase_no, Confidence, Success; 

\!date

-- 36 (Insert_Baseline) 
 INSERT INTO Baseline(
  Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, For_Organization, To_Location, Maintaining, Preferred_Quantity,
  Preferred_End_Date, Scoring_Fn_Quantity, Scoring_Fn_End_Date,
  Pref_Score_Quantity, Pref_Score_End_Date, Phase_no, Confidence,
  Success, MIN_Quantity, MIN_End_Date, MAX_Quantity, MAX_End_Date,
  Score_Quantity, Score_End_Date, Deviation_Quantity,
  Deviation_End_Date)
Select DISTINCT
       Agent, Verb, NSN_Number, ClassName, SupplyClass,
       SupplyType, For_Organization, To_Location, Maintaining,
       Preferred_Quantity, Preferred_End_Date, Scoring_Fn_Quantity,
       Scoring_Fn_End_Date, Pref_Score_Quantity, Pref_Score_End_Date,
       Phase_no, Confidence, Success,
       min(Quantity) 	       as MIN_Quantity,
       min(End_Date)   	       as MIN_End_Date, 
       max(Quantity) 	       as MAX_Quantity, 
       max(End_Date)   	       as MAX_End_Date, 
       max(Score_Quantity)     as Score_Quantity,
       max(Score_End_Date)     as Score_End_Date, 
       max(Deviation_Quantity) as Deviation_Quantity,
       max(Deviation_End_Date) as Deviation_End_Date
FROM Temp_Baseline 
WHERE Verb = 'Supply'
GROUP BY agent, Verb, NSN_Number, ClassName, SupplyClass,
         SupplyType, For_Organization, To_Location, Maintaining,
         Preferred_Quantity, Preferred_End_Date, Scoring_Fn_Quantity,
         Scoring_Fn_End_Date, Pref_Score_Quantity,
         Pref_Score_End_Date, Phase_no, Confidence, Success; 

\!date

-- 37 (Insert_Baseline) 
 INSERT INTO Baseline(
  Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, For_Organization, To_Location, Maintaining,
  Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
  Scoring_Fn_Start_Date, Scoring_Fn_End_Date, Scoring_Fn_Rate,
  Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
  Phase_no, Confidence, Success, MIN_Start_Date, MIN_End_Date,
  MIN_Rate, MAX_Start_Date, MAX_End_Date, MAX_Rate, Score_Start_Date,
  Score_End_Date, Score_Rate, Deviation_Start_Date,
  Deviation_End_Date, Deviation_Rate)
Select Agent, Verb, NSN_Number, ClassName, SupplyClass, 
       SupplyType, For_Organization, To_Location, Maintaining,
       Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
       Scoring_Fn_Start_Date, Scoring_Fn_End_Date, Scoring_Fn_Rate,
       Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
       Phase_no, Confidence, Success,
       min(Start_Date) 	     	 as MIN_Start_Date,
       min(End_Date)   	     	 as MIN_End_Date, 
       min(Rate)   	     	 as MIN_Rate, 
       max(Start_Date) 	     	 as MAX_Start_Date,
       max(End_Date)   	     	 as MAX_End_Date,  
       max(Rate)   	     	 as MAX_Rate,  
       max(Score_Start_Date) as Score_Start_Date,
       max(Score_End_Date)   as Score_End_Date, 
       max(Score_Rate)       as Score_Rate, 
       max(Deviation_Start_Date) as Deviation_Start_Date,
       max(Deviation_End_Date)   as Deviation_End_Date,
       max(Deviation_Rate)   as Deviation_Rate
FROM Temp_Baseline 
WHERE Verb = 'ProjectSupply'
GROUP BY agent, Verb, NSN_Number, ClassName, SupplyClass, SupplyType,
         For_Organization,To_Location, Maintaining, Preferred_Start_Date,
         Preferred_End_Date, Preferred_Rate, Scoring_Fn_Start_Date,
         Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Start_Date,
         Pref_Score_End_Date, Pref_Score_Rate, Phase_no, Confidence,
         Success; 


