\!date
-- 00 (drop_Stressed) 
 DROP TABLE  Stressed; 

-- 01 (Create_Stressed) 
 CREATE TABLE Stressed (
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
  Pref_Score_Rate       double precision                default NULL,
  Quantity          double precision                default NULL,
  Start_Date        double precision              default NULL,
  End_Date          double precision              default NULL,
  Rate              double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL,
  Deviation_Quantity        double precision                default NULL,
  Deviation_Start_Date      double precision                default NULL,
  Deviation_End_Date        double precision                default NULL,
  Deviation_Rate            double precision                default NULL
); 

-- 02 (drop_Temp_Stressed_OP) 
 DROP TABLE Temp_Stressed_OP ; 

-- 03 (Temp_Stressed_OP) 
 CREATE  TABLE Temp_Stressed_OP (
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

-- 04 (drop_Temp_Stressed_Results) 
 DROP TABLE Temp_Stressed_Results; 

-- 05 (Temp_Stressed_Results) 
 
 CREATE  TABLE Temp_Stressed_Results (
  run_id                integer  NOT NULL,
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
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL
); 

-- 06 (drop_Temp_Stressed_Phased) 
 DROP TABLE Temp_Stressed_Phased; 

-- 07 (Temp_Stressed_Phased) 
 
 CREATE  TABLE Temp_Stressed_Phased (
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
  Pref_Score_Rate       double precision                default NULL,
  Quantity          double precision                default NULL,
  Start_Date        double precision              default NULL,
  End_Date          double precision              default NULL,
  Rate              double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL
); 

-- 08 (drop_Temp_Stressed) 
 DROP TABLE Temp_Stressed; 

-- 09 (Temp_Stressed) 
 CREATE  TABLE Temp_Stressed (
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
  Pref_Score_Rate       double precision                default NULL,
  Quantity          double precision                default NULL,
  Start_Date        double precision              default NULL,
  End_Date          double precision              default NULL,
  Rate              double precision                default NULL,
  Score_Quantity   double precision               default NULL,
  Score_Start_Date double precision               default NULL,
  Score_End_Date   double precision               default NULL,
  Score_Rate       double precision               default NULL,
  Phase_no              integer                       default NULL,
  Confidence            double precision              default NULL,
  Success               char(1)                       default NULL
); 

\!date
-- 10 (insert_Temp_Stressed_OP) 
 
INSERT INTO Temp_Stressed_OP (run_id, task_id, Agent, Verb, NSN_Number,
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
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'stress' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb       	       = 'Transport'
  AND pref1.aspecttype 	       = 'END_TIME'
  AND pref1.run_id    	       = tasks.run_id
  AND pref1.task_id    	       = tasks.id
  AND pref2.aspecttype 	       = 'START_TIME' 
  AND pref2.run_id    	       = tasks.run_id
  AND pref2.task_id    	       = tasks.id
  AND prep1.prep       	       = 'To'
  AND prep1.run_id    	       = tasks.run_id
  AND prep1.task_id    	       = tasks.id
  AND prep2.prep       	       = 'From'
  AND prep2.run_id    	       = tasks.run_id
  AND prep2.task_id    	       = tasks.id
  AND assets.run_id            = tasks.run_id
  AND assets.task_id           = tasks.id; 

\!date
-- 11 (insert_Temp_Stressed_OP) 
 
INSERT INTO Temp_Stressed_OP (run_id, task_id, Agent, Verb, NSN_Number, 
                              ClassName, SupplyClass,
                              SupplyType, For_Organization,
                              To_Location, Maintaining,
                              Preferred_Quantity, Preferred_End_Date,
                              Scoring_Fn_Quantity,
                              Scoring_Fn_End_Date,
                              Pref_Score_Quantity,
                              Pref_Score_End_Date)
SELECT DISTINCT
       tasks.run_id, tasks.id, tasks.agent, tasks.Verb, 
       assets.typepg_id as NSN_Number, assets.classname,
       assets.SupplyClass, assets.SupplyType,
       prep2.val as For_Organization, prep1.val as To_Location,
       prep3.val as Maintaining, pref2.bestvalue as Preferred_Quantity,
       pref1.bestvalue as Preferred_End_Date,
       pref2.scoringfunction as Scoring_Fn_Quantity, 
       pref1.scoringfunction as Scoring_Fn_End_Date,
       pref2.score as Pref_Score_Quantity,
       pref1.score as Pref_Score_End_Date
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, prepositions prep3, assets
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'stress' 
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
-- 12 (insert_Temp_Stressed_O) 
 
INSERT INTO Temp_Stressed_OP (run_id, task_id, Agent, Verb, NSN_Number, 
                           ClassName, SupplyClass,
                           SupplyType, For_Organization, To_Location,
                           Maintaining, Preferred_Start_Date,
            	      	   Preferred_End_Date, Preferred_Rate,
                           Scoring_Fn_Start_Date, Scoring_Fn_End_Date, 
                           Scoring_Fn_Rate, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Pref_Score_Rate)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb, 
       assets.typepg_id as NSN_Number, 
       assets.classname, assets.SupplyClass, assets.SupplyType, 
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
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'stress' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb       = 'ProjectSupply'
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
  AND pref2.aspecttype = 'START_TIME'
  AND pref2.run_id     = tasks.run_id
  AND pref2.task_id    = tasks.id
  AND pref3.aspecttype = '15'
  AND pref3.run_id     = tasks.run_id
  AND pref3.task_id    = tasks.id
  AND assets.run_id    = tasks.run_id
  AND assets.task_id   = tasks.id; 

\!date
-- 13 (Insert_Temp_Stressed_Results) 
 
INSERT INTO Temp_Stressed_Results (run_id, task_id, Agent, Verb, 
                                   Start_Date, End_Date,
                                   Score_Start_Date, Score_End_Date,
                                   Phase_no, Confidence, Success)
SELECT tasks.run_id, tasks.id, tasks.agent, tasks.Verb,  
       phval1.value as Start_Date, phval2.value as End_Date,
       phval1.score as Score_Start_Date,
       phval2.score as Score_End_Date,
       phval1.phase_no,
       allocation_results.confidence,  allocation_results.Success
FROM tasks, allocation_results,
     phased_aspects phval1, phased_aspects phval2
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'stress' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb       	       = 'Transport'
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
-- 14 (Insert_Temp_Stressed_Results) 
 
INSERT INTO Temp_Stressed_Results (run_id, task_id, Agent, Verb, 
                                   Quantity, End_Date, Score_Quantity,
                                   Score_End_Date, Phase_no,
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
       phval1.phase_no,
       allocation_results.confidence, 
       allocation_results.Success
FROM tasks, allocation_results, 
     phased_aspects phval1, phased_aspects phval2
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'stress' 
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
-- 15 (Insert_Temp_Stressed_Results) 
 
INSERT INTO Temp_Stressed_Results (run_id, task_id, Agent, Verb, 
                                   Start_Date, End_Date, Rate,
                                   Score_Start_Date, Score_End_Date,
                                   Score_Rate, Phase_no, Confidence,
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
       phval1.phase_no,
       allocation_results.confidence, 
       allocation_results.Success
FROM tasks, allocation_results,
     phased_aspects phval1, phased_aspects phval2,
     phased_aspects phval3
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'stress' 
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
-- 16 (Insert_Temp_Temp_Stressed_Phased) 
 
INSERT INTO Temp_Stressed_Phased (run_id, task_id, Agent, Verb, NSN_Number,
                           ClassName, SupplyClass,
                           SupplyType, From_Location, To_Location,
            	           Preferred_Start_Date, Preferred_End_Date,
                           Scoring_Fn_Start_Date,
                           Scoring_Fn_End_Date, Pref_Score_Start_Date,
                           Pref_Score_End_Date, Start_Date, End_Date,
            	           Phase_no, Confidence, Success,
			   Score_Start_Date, Score_End_Date)
SELECT Temp_Stressed_OP.run_id, Temp_Stressed_OP.task_id,
       Temp_Stressed_OP.agent, Temp_Stressed_OP.Verb,
       Temp_Stressed_OP.NSN_Number, 
       Temp_Stressed_OP.ClassName, 
       Temp_Stressed_OP.SupplyClass,
       Temp_Stressed_OP.SupplyType,
       Temp_Stressed_OP.From_Location,
       Temp_Stressed_OP.To_Location,
       Temp_Stressed_OP.Preferred_Start_Date,
       Temp_Stressed_OP.Preferred_End_Date,
       Temp_Stressed_OP.Scoring_Fn_Start_Date,
       Temp_Stressed_OP.Scoring_Fn_End_Date,
       Temp_Stressed_OP.Pref_Score_Start_Date,
       Temp_Stressed_OP.Pref_Score_End_Date,
       Temp_Stressed_Results.Start_Date,
       Temp_Stressed_Results.End_Date, 
       Temp_Stressed_Results.phase_no,
       Temp_Stressed_Results.Confidence, 
       Temp_Stressed_Results.Success,
       Temp_Stressed_Results.Score_Start_Date,
       Temp_Stressed_Results.Score_End_Date
FROM Temp_Stressed_OP FULL OUTER JOIN Temp_Stressed_Results 
       ON (Temp_Stressed_OP.task_id = Temp_Stressed_Results.task_id AND
           Temp_Stressed_OP.run_id  = Temp_Stressed_Results.run_id)
WHERE Temp_Stressed_OP.verb       	       = 'Transport'; 

\!date
-- 17 (Insert_Temp_Stressed_XXX_Phased) 
 
INSERT INTO Temp_Stressed_Phased (run_id, task_id, Agent, Verb, NSN_Number, 
                           ClassName, SupplyClass,
                           SupplyType, For_Organization, To_Location,
                           Maintaining, Preferred_Quantity, Preferred_End_Date,
            	      	   Scoring_Fn_Quantity, Scoring_Fn_End_Date,
            	      	   Pref_Score_Quantity, Pref_Score_End_Date,
            	      	   Quantity, End_Date, Phase_no, Confidence,
            	      	   Success, Score_Quantity, Score_End_Date)
SELECT DISTINCT
       Temp_Stressed_OP.run_id, Temp_Stressed_OP.task_id,
       Temp_Stressed_OP.Agent, Temp_Stressed_OP.Verb,
       Temp_Stressed_OP.NSN_Number,
       Temp_Stressed_OP.ClassName, 
       Temp_Stressed_OP.SupplyClass,
       Temp_Stressed_OP.SupplyType,
       Temp_Stressed_OP.For_Organization,
       Temp_Stressed_OP.To_Location,
       Temp_Stressed_OP.Maintaining,
       Temp_Stressed_OP.Preferred_Quantity,
       Temp_Stressed_OP.Preferred_End_Date,
       Temp_Stressed_OP.Scoring_Fn_Quantity,
       Temp_Stressed_OP.Scoring_Fn_End_Date,
       Temp_Stressed_OP.Pref_Score_Quantity,
       Temp_Stressed_OP.Pref_Score_End_Date,
       Temp_Stressed_Results.Quantity,
       Temp_Stressed_Results.End_Date, 
       Temp_Stressed_Results.Phase_no,
       Temp_Stressed_Results.Confidence, 
       Temp_Stressed_Results.Success,
       Temp_Stressed_Results.Score_Quantity,
       Temp_Stressed_Results.Score_End_Date
FROM Temp_Stressed_OP FULL OUTER JOIN Temp_Stressed_Results 
       ON (Temp_Stressed_OP.task_id = Temp_Stressed_Results.task_id AND
           Temp_Stressed_OP.run_id  = Temp_Stressed_Results.run_id)
WHERE Temp_Stressed_OP.verb       = 'Supply'; 

\!date
-- 18 (Insert_Temp_Stressed_Phased) 
 
INSERT INTO Temp_Stressed_Phased (run_id, task_id, Agent, Verb, NSN_Number, 
                          ClassName, SupplyClass, SupplyType, For_Organization,
                          To_Location, Maintaining,
                          Preferred_Start_Date,
            	      	  Preferred_End_Date, Preferred_Rate,
                          Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                          Scoring_Fn_Rate, Pref_Score_Start_Date,
                          Pref_Score_End_Date, Pref_Score_Rate,
                          Start_Date, End_Date, Rate, Phase_no,
                          Confidence, Success, Score_Start_Date,
                          Score_End_Date, Score_Rate)
SELECT Temp_Stressed_OP.run_id, Temp_Stressed_OP.task_id,
       Temp_Stressed_OP.Agent, Temp_Stressed_OP.Verb,
       Temp_Stressed_OP.NSN_Number,
       Temp_Stressed_OP.ClassName, 
       Temp_Stressed_OP.SupplyClass,
       Temp_Stressed_OP.SupplyType,
       Temp_Stressed_OP.For_Organization,
       Temp_Stressed_OP.To_Location,
       Temp_Stressed_OP.Maintaining,
       Temp_Stressed_OP.Preferred_Start_Date,
       Temp_Stressed_OP.Preferred_End_Date,
       Temp_Stressed_OP.Preferred_Rate,
       Temp_Stressed_OP.Scoring_Fn_Start_Date,
       Temp_Stressed_OP.Scoring_Fn_End_Date,
       Temp_Stressed_OP.Scoring_Fn_Rate,
       Temp_Stressed_OP.Pref_Score_Start_Date,
       Temp_Stressed_OP.Pref_Score_End_Date,
       Temp_Stressed_OP.Pref_Score_Rate,
       Temp_Stressed_Results.Start_Date,
       Temp_Stressed_Results.End_Date, 
       Temp_Stressed_Results.Rate, 
       Temp_Stressed_Results.Phase_no,
       Temp_Stressed_Results.Confidence, 
       Temp_Stressed_Results.Success,
       Temp_Stressed_Results.Score_Start_Date,
       Temp_Stressed_Results.Score_End_Date,
       Temp_Stressed_Results.Score_Rate
FROM Temp_Stressed_OP  FULL OUTER JOIN Temp_Stressed_Results 
       ON (Temp_Stressed_OP.task_id = Temp_Stressed_Results.task_id AND
           Temp_Stressed_OP.run_id  = Temp_Stressed_Results.run_id)
WHERE Temp_Stressed_OP.verb       = 'ProjectSupply'; 

\!date
-- 19 (Insert_Temp_Stressed) 
 
INSERT INTO Temp_Stressed (run_id, task_id, Agent, Verb, NSN_Number,
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
SELECT run_id, task_id, Agent, Verb, NSN_Number,
       ClassName, SupplyClass, SupplyType,
       From_Location, For_Organization, To_Location, Maintaining,
       Preferred_Quantity, Preferred_Start_Date, Preferred_End_Date,
       Preferred_Rate, Scoring_Fn_Quantity, Scoring_Fn_Start_Date,
       Scoring_Fn_End_Date, Scoring_Fn_Rate, Pref_Score_Quantity,
       Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
       Phase_no, Confidence, Success, Quantity, Start_Date, End_Date,
       Rate, Score_Quantity, Score_Start_Date, Score_End_Date,
       Score_Rate
From Temp_Stressed_Phased
WHERE task_id not in (SELECT DISTINCT  task_ID from Temp_Stressed_Phased
                      WHERE Phase_no > 0); 

\!date
-- 20 (Insert_Temp_Stressed) 
 
INSERT INTO Temp_Stressed (run_id, task_id, Agent, Verb, NSN_Number, 
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
      t1.For_Organization, t1.To_Location, t1.Maintaining, t1.Preferred_Quantity,
      t1.Preferred_End_Date, t1.Scoring_Fn_Quantity, t1.Scoring_Fn_End_Date,
      t1.Pref_Score_Quantity, t1.Pref_Score_End_Date, count(t1.Phase_no),
      sum(t1.Confidence * t1.Quantity / t1.Preferred_Quantity),
      min(t1.Success), sum(t1.Quantity), max(t1.End_Date),
      Consolidated_Quantity.score,  Consolidated_End_Date.score
FROM Temp_Stressed_Phased t1, 
     consolidated_aspects Consolidated_Quantity,
     consolidated_aspects Consolidated_End_Date
WHERE t1.verb       = 'Supply'
  AND Consolidated_Quantity.task_id    = t1.task_id
  AND Consolidated_Quantity.run_id     = t1.run_id
  AND Consolidated_End_Date.task_id    = t1.task_id
  AND Consolidated_End_Date.run_id     = t1.run_id
  AND Consolidated_Quantity.aspecttype = 'QUANTITY'
  AND Consolidated_End_Date.aspecttype = 'END_TIME'
  AND  t1.task_id in (SELECT DISTINCT  task_ID from Temp_Stressed_Phased
                     WHERE Phase_no > 0)
GROUP BY t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number,
       	 t1.ClassName, t1.SupplyClass, t1.SupplyType,
       	 t1.For_Organization, t1.To_Location, t1.Maintaining,
       	 t1.Preferred_Quantity, t1.Preferred_End_Date,
       	 t1.Scoring_Fn_Quantity, t1.Scoring_Fn_End_Date,
       	 t1.Pref_Score_Quantity, t1.Pref_Score_End_Date,
       	 Consolidated_Quantity.score, Consolidated_End_Date.score; 

\!date
-- 21 (Insert_Temp_Stressed) 
 
INSERT INTO Temp_Stressed (run_id, task_id, Agent, Verb, NSN_Number, 
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
FROM Temp_Stressed_Phased t1,
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
  AND t1.task_id in (SELECT DISTINCT  task_ID from Temp_Stressed_Phased
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
-- 22 (Insert_Stressed) 
 
INSERT INTO Stressed (run_id, task_id, Agent, Verb, NSN_Number,
                      ClassName, SupplyClass,
                      SupplyType, From_Location, For_Organization,
                      To_Location, Maintaining, Preferred_Quantity,
                      Preferred_Start_Date, Preferred_End_Date,
                      Preferred_Rate, Scoring_Fn_Quantity,
                      Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
                      Scoring_Fn_Rate, Pref_Score_Quantity,
                      Pref_Score_Start_Date, Pref_Score_End_Date,
                      Pref_Score_Rate, Quantity, Start_Date, End_Date,
                      Rate, Score_Quantity, Score_Start_Date,
                      Score_End_Date, Score_Rate, Phase_no,
                      Confidence, Success, Deviation_Quantity,
                      Deviation_Start_Date, Deviation_End_Date,
                      Deviation_Rate)
SELECT DISTINCT t1.run_id, t1.task_id, t1.Agent, t1.Verb, t1.NSN_Number, 
                t1.ClassName, t1.SupplyClass, t1.SupplyType,
       		t1.From_Location, t1.For_Organization, t1.To_Location,
       		t1.Maintaining, t1.Preferred_Quantity,
       		t1.Preferred_Start_Date, t1.Preferred_End_Date,
                t1.Preferred_Rate, t1.Scoring_Fn_Quantity, 
       		t1.Scoring_Fn_Start_Date, t1.Scoring_Fn_End_Date,
       		t1.Scoring_Fn_Rate, t1.Pref_Score_Quantity, 
                t1.Pref_Score_Start_Date, t1.Pref_Score_End_Date,
       		t1.Pref_Score_Rate,
       		t1.Quantity, t1.Start_Date, t1.End_Date, t1.Rate,
       		t1.Score_Quantity, t1.Score_Start_Date, t1.Score_End_Date,
                t1.Score_Rate, t1.Phase_no,
                t1.Confidence, t1.Success,
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
FROM Temp_Stressed t1, Scoring_Constants t2
WHERE t2.ID = 'Default'; 


