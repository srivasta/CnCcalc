-- 00 (drop_Stressed_LVL_2) 
 DROP TABLE Stressed_LVL_2; 

-- 01 (Stressed_LVL_2) 
 CREATE TABLE Stressed_LVL_2 AS
SELECT * FROM Stressed
WHERE NSN_Number LIKE '%Aggregate'; 

-- 02 (drop_Stressed_LVL_6) 
 DROP TABLE Stressed_LVL_6; 

-- 03 (Stressed_LVL_6) 
 CREATE TABLE Stressed_LVL_6 AS
SELECT * FROM Stressed
WHERE NSN_Number NOT LIKE '%Aggregate'; 

-- 04 (drop_Completion) 
 DROP TABLE Completion; 

-- 05 (Completion) 
 CREATE TABLE Completion (
  Run_ID                    integer               default '-1',
  Task_ID                   varchar(127)          default 'NONE SET',
  Agent                     varchar(127) NOT NULL default 'NONE SET',
  Verb                      varchar(127) NOT NULL default 'NONE SET',
  NSN_Number                varchar(127)     	  default NULL,
  ClassName                 varchar(255)     	  default NULL,
  SupplyClass               varchar(63)      	  default NULL,
  SupplyType                varchar(63)      	  default NULL,
  From_Location             varchar(63)      	  default NULL,
  For_Organization          varchar(63)      	  default NULL,
  To_Location               varchar(63)      	  default NULL,
  Maintaining               varchar(63)      	  default NULL,
  Preferred_Quantity        double precision 	  default NULL,
  Preferred_Start_Date      double precision 	  default NULL,
  Preferred_End_Date        double precision 	  default NULL,
  Preferred_Rate            double precision 	  default NULL,
  Scoring_Fn_Quantity       varchar(255)     	  default NULL,
  Scoring_Fn_Start_Date     varchar(255)     	  default NULL,
  Scoring_Fn_End_Date       varchar(255)     	  default NULL,
  Scoring_Fn_Rate           varchar(255)     	  default NULL,
  Pref_Score_Quantity       double precision 	  default NULL,
  Pref_Score_Start_Date     double precision 	  default NULL,
  Pref_Score_End_Date       double precision 	  default NULL,
  Pref_Score_Rate           double precision 	  default NULL,
  Quantity          	    double precision 	  default NULL,
  Start_Date        	    double precision 	  default NULL,
  End_Date          	    double precision 	  default NULL,
  Rate              	    double precision 	  default NULL,
  Score_Start_Date 	    double precision 	  default NULL,
  Score_End_Date   	    double precision 	  default NULL,
  Score_Quantity   	    double precision 	  default NULL,
  Score_Rate       	    double precision 	  default NULL,
  Phase_no                  integer          	  default NULL,
  Confidence                double precision 	  default NULL,
  Success                   char(1)          	  default NULL,
  Deviation_Quantity        double precision 	  default NULL,
  Deviation_Start_Date      double precision 	  default NULL,
  Deviation_End_Date        double precision 	  default NULL,
  Deviation_Rate            double precision 	  default NULL,
  Base_Deviation_Quantity   double precision 	  default NULL,
  Base_Deviation_Start_Date double precision 	  default NULL,
  Base_Deviation_End_Date   double precision 	  default NULL,
  Base_Deviation_Rate       double precision 	  default NULL,
  Dev_Is_CC_Quantity        smallint         	  default NULL,
  Dev_Is_CC_Start_Date      smallint         	  default NULL,
  Dev_Is_CC_End_Date        smallint         	  default NULL,
  Dev_Is_CC_Rate            smallint         	  default NULL,
  Is_CC_Quantity            smallint         	  default NULL,
  Is_CC_Start_Date          smallint         	  default NULL,
  Is_CC_End_Date            smallint         	  default NULL,
  Is_CC_Rate                smallint         	  default NULL
); 

-- 06 (drop_Completion_L2) 
 DROP TABLE Completion_L2; 

-- 07 (Completion_L2) 
 CREATE TABLE Completion_L2 (
  Run_ID                    integer               default '-1',
  Task_ID                   varchar(127)          default 'NONE SET',
  Agent                     varchar(127) NOT NULL default 'NONE SET',
  Verb                      varchar(127) NOT NULL default 'NONE SET',
  NSN_Number                varchar(127)     	  default NULL,
  ClassName                 varchar(255)     	  default NULL,
  SupplyClass               varchar(63)      	  default NULL,
  SupplyType                varchar(63)      	  default NULL,
  From_Location             varchar(63)      	  default NULL,
  For_Organization          varchar(63)      	  default NULL,
  To_Location               varchar(63)      	  default NULL,
  Maintaining               varchar(63)      	  default NULL,
  Preferred_Quantity        double precision 	  default NULL,
  Preferred_Start_Date      double precision 	  default NULL,
  Preferred_End_Date        double precision 	  default NULL,
  Preferred_Rate            double precision 	  default NULL,
  Scoring_Fn_Quantity       varchar(255)     	  default NULL,
  Scoring_Fn_Start_Date     varchar(255)     	  default NULL,
  Scoring_Fn_End_Date       varchar(255)     	  default NULL,
  Scoring_Fn_Rate           varchar(255)     	  default NULL,
  Pref_Score_Quantity       double precision 	  default NULL,
  Pref_Score_Start_Date     double precision 	  default NULL,
  Pref_Score_End_Date       double precision 	  default NULL,
  Pref_Score_Rate           double precision 	  default NULL,
  Quantity          	    double precision 	  default NULL,
  Start_Date        	    double precision 	  default NULL,
  End_Date          	    double precision 	  default NULL,
  Rate              	    double precision 	  default NULL,
  Score_Start_Date 	    double precision 	  default NULL,
  Score_End_Date   	    double precision 	  default NULL,
  Score_Quantity   	    double precision 	  default NULL,
  Score_Rate       	    double precision 	  default NULL,
  Phase_no                  integer          	  default NULL,
  Confidence                double precision 	  default NULL,
  Success                   char(1)          	  default NULL,
  Deviation_Quantity        double precision 	  default NULL,
  Deviation_Start_Date      double precision 	  default NULL,
  Deviation_End_Date        double precision 	  default NULL,
  Deviation_Rate            double precision 	  default NULL,
  Base_Deviation_Quantity   double precision 	  default NULL,
  Base_Deviation_Start_Date double precision 	  default NULL,
  Base_Deviation_End_Date   double precision 	  default NULL,
  Base_Deviation_Rate       double precision 	  default NULL,
  Level_Two_Task            varchar(127)          default NULL,
  Level_Two_NSN             varchar(127)     	  default NULL,
  Level_Two_Rate            double precision 	  default NULL,
  Summed_MIN_Rate           double precision 	  default NULL,
  Summed_MAX_Rate           double precision 	  default NULL,
  Summed_LVL_6_Rate         double precision 	  default NULL,
  Summed_Baseline_MIN_Rate  double precision 	  default NULL,
  Summed_Baseline_MAX_Rate  double precision 	  default NULL,
  Dev_Is_CC_Quantity        smallint         	  default NULL,
  Dev_Is_CC_Start_Date      smallint         	  default NULL,
  Dev_Is_CC_End_Date        smallint         	  default NULL,
  Dev_Is_CC_Rate            smallint         	  default NULL,
  Is_CC_Quantity            smallint         	  default NULL,
  Is_CC_Start_Date          smallint         	  default NULL,
  Is_CC_End_Date            smallint         	  default NULL,
  Is_CC_Rate                smallint         	  default NULL
); 
\!date
-- 08 (Insert_Completion) 
 INSERT INTO Completion (
  Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName,
  From_Location, To_Location, Preferred_Start_Date,
  Preferred_End_Date, Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  Pref_Score_Start_Date, Pref_Score_End_Date, Start_Date, End_Date,
  Score_Start_Date, Score_End_Date, Phase_no, Confidence, Success,
  Deviation_Start_Date, Deviation_End_Date, Base_Deviation_Start_Date,
  Base_Deviation_End_Date, Dev_Is_CC_Start_Date, Dev_Is_CC_End_Date,
  Is_CC_Start_Date, Is_CC_End_Date)
SELECT DISTINCT Stressed_LVL_6.Run_ID,
                Stressed_LVL_6.Task_ID,
                case
                when Stressed_LVL_6.Agent IS NULL
                     then Baseline.Agent
                else Stressed_LVL_6.Agent
                end,
              	case
                when Stressed_LVL_6.Verb IS NULL
                     then Baseline.Verb
                else Stressed_LVL_6.Verb
                end,
	      	case
                when Stressed_LVL_6.NSN_Number IS NULL
                     then Baseline.NSN_Number
                else Stressed_LVL_6.NSN_Number
                end,
	      	case
                when Stressed_LVL_6.ClassName IS NULL
                     then Baseline.ClassName
                else Stressed_LVL_6.ClassName
                end,
              	case
                when Stressed_LVL_6.From_Location IS NULL
                     then Baseline.From_Location
                else Stressed_LVL_6.From_Location
                end,
              	case
                when Stressed_LVL_6.To_Location IS NULL
                     then Baseline.To_Location
                else Stressed_LVL_6.To_Location
                end,
              	case
                when Stressed_LVL_6.Preferred_Start_Date IS NULL
                     then Baseline.Preferred_Start_Date
                else Stressed_LVL_6.Preferred_Start_Date
                end,
              	case
                when Stressed_LVL_6.Preferred_End_Date IS NULL
                     then Baseline.Preferred_End_Date
                else Stressed_LVL_6.Preferred_End_Date
                end,
                case
                when Stressed_LVL_6.Scoring_Fn_Start_Date IS NULL
                     then Baseline.Scoring_Fn_Start_Date
                else Stressed_LVL_6.Scoring_Fn_Start_Date
                end,
                case
                when Stressed_LVL_6.Scoring_Fn_End_Date IS NULL
                     then Baseline.Scoring_Fn_End_Date
                else Stressed_LVL_6.Scoring_Fn_End_Date
                end,
                case
                when Stressed_LVL_6.Pref_Score_Start_Date IS NULL
                     then Baseline.Pref_Score_Start_Date
                else Stressed_LVL_6.Pref_Score_Start_Date
                end,
                case
                when Stressed_LVL_6.Pref_Score_End_Date IS NULL
                     then Baseline.Pref_Score_End_Date
                else Stressed_LVL_6.Pref_Score_End_Date
                end,
              	Stressed_LVL_6.Start_Date,
              	Stressed_LVL_6.End_Date,
              	Stressed_LVL_6.Score_Start_Date,
              	Stressed_LVL_6.Score_End_Date,
              	Stressed_LVL_6.Phase_no,
                Stressed_LVL_6.Confidence,
                Stressed_LVL_6.Success,
              	Stressed_LVL_6.Score_Start_Date,
              	Stressed_LVL_6.Score_End_Date,
              	Baseline.Score_Start_Date,
              	Baseline.Score_End_Date,
              	case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Success    = '0'             then 0
                when Stressed_LVL_6.Deviation_Start_Date IS NULL then NULL
                when Baseline.Deviation_Start_Date IS NULL then 1
              	when Stressed_LVL_6.Deviation_Start_Date >
       	                      0.05 + Baseline.Deviation_Start_Date then 0
              	else 1
              	end,
              	case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Success    = '0'             then 0
                when Stressed_LVL_6.Deviation_End_Date IS NULL then NULL
                when Baseline.Deviation_End_Date IS NULL then 1
              	when Stressed_LVL_6.Deviation_End_Date >
              	              0.05 + Baseline.Deviation_End_Date then 0
              	     else 1
              	end,
              	case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Score_Start_Date IS NULL then NULL
                when Baseline.Score_Start_Date IS NULL then 1
              	when Stressed_LVL_6.Score_Start_Date >
              	     Baseline.Score_Start_Date         then 0
              	else 1
              	end,
              	case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Score_End_Date IS NULL then NULL
                when Baseline.Score_End_Date IS NULL then 1
              	when Stressed_LVL_6.Score_End_Date >
              	     Baseline.Score_End_Date          then 0
              	     else 1
              	end
FROM Stressed_LVL_6  RIGHT OUTER JOIN Baseline
     ON ( Stressed_LVL_6.Agent                = Baseline.Agent
      AND Stressed_LVL_6.Verb                 = Baseline.Verb
      AND Stressed_LVL_6.NSN_Number           = Baseline.NSN_Number
      AND Stressed_LVL_6.ClassName            = Baseline.ClassName
      AND Stressed_LVL_6.To_Location          = Baseline.To_Location
      AND Stressed_LVL_6.From_Location        = Baseline.From_Location
      AND Stressed_LVL_6.Preferred_End_Date   = Baseline.Preferred_End_Date
      AND Stressed_LVL_6.Preferred_Start_Date = Baseline.Preferred_Start_Date
      AND Stressed_LVL_6.Phase_no             = Baseline.Phase_no )
WHERE     Stressed_LVL_6.Verb                 = 'Transport'
       OR Baseline.Verb                 = 'Transport'; 
\!date
-- 09 (Insert_Completion) 
 INSERT INTO Completion(
  Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, For_Organization, To_Location, Maintaining,
  Preferred_Quantity, Preferred_End_Date, Scoring_Fn_Quantity,
  Scoring_Fn_End_Date, Pref_Score_Quantity, Pref_Score_End_Date,
  Quantity, End_Date, Score_Quantity, Score_End_Date, Phase_no,
  Confidence, Success, Deviation_Quantity, Deviation_End_Date,
  Base_Deviation_Quantity, Base_Deviation_End_Date,
  Dev_Is_CC_Quantity, Dev_Is_CC_End_Date, Is_CC_Quantity,
  Is_CC_End_Date)
SELECT DISTINCT Stressed_LVL_6.Run_ID,
                Stressed_LVL_6.Task_ID,
                case
                when Stressed_LVL_6.Agent IS NULL then Baseline.Agent
                else Stressed_LVL_6.Agent
                end,
                case
                when Stressed_LVL_6.Verb IS NULL
                     then Baseline.Verb
                else Stressed_LVL_6.Verb
                end,
                case
                when Stressed_LVL_6.NSN_Number IS NULL
                     then Baseline.NSN_Number
                else Stressed_LVL_6.NSN_Number
                end,
	      	case
                when Stressed_LVL_6.ClassName IS NULL
                     then Baseline.ClassName
                else Stressed_LVL_6.ClassName
                end,
                case
                when Stressed_LVL_6.SupplyClass IS NULL
                     then Baseline.SupplyClass
                else Stressed_LVL_6.SupplyClass
                end,
                case
                when Stressed_LVL_6.SupplyType IS NULL
                     then Baseline.SupplyType
                else Stressed_LVL_6.SupplyType
                end,
                case
                when Stressed_LVL_6.For_Organization IS NULL
                     then Baseline.For_Organization
                else Stressed_LVL_6.For_Organization
                end,
                case
                when Stressed_LVL_6.To_Location IS NULL
                     then Baseline.To_Location
                else Stressed_LVL_6.To_Location
                end,
                case
                when Stressed_LVL_6.Maintaining IS NULL
                     then Baseline.Maintaining
                else Stressed_LVL_6.Maintaining
                end,
                case
                when Stressed_LVL_6.Preferred_Quantity IS NULL
                     then Baseline.Preferred_Quantity
                else Stressed_LVL_6.Preferred_Quantity
                end,
                case
                when Stressed_LVL_6.Preferred_End_Date IS NULL
                then Baseline.Preferred_End_Date
                else Stressed_LVL_6.Preferred_End_Date
                end,
                case
                when Stressed_LVL_6.Scoring_Fn_Quantity IS NULL
                then Baseline.Scoring_Fn_Quantity
                else Stressed_LVL_6.Scoring_Fn_Quantity
                end,
                case
                when Stressed_LVL_6.Scoring_Fn_End_Date IS NULL
                then Baseline.Scoring_Fn_End_Date
                else Stressed_LVL_6.Scoring_Fn_End_Date
                end,
                case
                when Stressed_LVL_6.Pref_Score_Quantity IS NULL
                then Baseline.Pref_Score_Quantity
                else Stressed_LVL_6.Pref_Score_Quantity
                end,
                case
                when Stressed_LVL_6.Pref_Score_End_Date IS NULL
                then Baseline.Pref_Score_End_Date
                else Stressed_LVL_6.Pref_Score_End_Date
                end,
                Stressed_LVL_6.Quantity,
                Stressed_LVL_6.End_Date,
                Stressed_LVL_6.Score_Quantity,
                Stressed_LVL_6.Score_End_Date,
                Stressed_LVL_6.Phase_no,
                Stressed_LVL_6.Confidence,
                Stressed_LVL_6.Success,
                Stressed_LVL_6.Score_Quantity,
                Stressed_LVL_6.Score_End_Date ,
                Baseline.Score_Quantity,
                Baseline.Score_End_Date ,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Success    = '0'             then 0
                when Stressed_LVL_6.Deviation_Quantity IS NULL then NULL
                when Baseline.Deviation_Quantity IS NULL then 1
                when Stressed_LVL_6.Deviation_Quantity >
                                    0.05 + Baseline.Deviation_Quantity then 0
                else 1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Success    = '0'             then 0
                when Stressed_LVL_6.Deviation_End_Date IS NULL then NULL
                when Baseline.Deviation_End_Date IS NULL then 1
                when Stressed_LVL_6.Deviation_End_Date  >
                                    0.05 + Baseline.Deviation_End_Date then 0
                else 1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Score_Quantity IS NULL then NULL
                when Baseline.Score_Quantity IS NULL then 1
                when Stressed_LVL_6.Score_Quantity >
                     Baseline.Score_Quantity then 0
                else 1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Score_End_Date IS NULL then NULL
                when Baseline.Score_End_Date IS NULL then 1
                when Stressed_LVL_6.Score_End_Date  >
                     Baseline.Score_End_Date then 0
                else 1
                end
FROM Stressed_LVL_6  Right OUTER JOIN Baseline
     ON ( Stressed_LVL_6.Agent              = Baseline.Agent
      AND Stressed_LVL_6.Verb               = Baseline.Verb
      AND Stressed_LVL_6.NSN_Number         = Baseline.NSN_Number
      AND Stressed_LVL_6.ClassName            = Baseline.ClassName
      AND Stressed_LVL_6.SupplyClass         = Baseline.SupplyClass
      AND Stressed_LVL_6.SupplyType          = Baseline.SupplyType
      AND Stressed_LVL_6.For_Organization   = Baseline.For_Organization
      AND Stressed_LVL_6.To_Location        = Baseline.To_Location
      AND Stressed_LVL_6.Maintaining        = Baseline.Maintaining
      AND Stressed_LVL_6.Preferred_Quantity = Baseline.Preferred_Quantity
      AND Stressed_LVL_6.Preferred_End_Date = Baseline.Preferred_End_Date
      AND Stressed_LVL_6.Phase_no           = Baseline.Phase_no )
WHERE     Stressed_LVL_6.Verb               = 'Supply'
       OR Baseline.Verb               = 'Supply'; 
\!date
-- 10 (Insert_Completion) 
 INSERT INTO Completion(
  Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName, SupplyClass,
  SupplyType, For_Organization, To_Location, Maintaining,
  Preferred_Start_Date, Preferred_End_Date, Preferred_Rate,
  Scoring_Fn_Start_Date, Scoring_Fn_End_Date, Scoring_Fn_Rate,
  Pref_Score_Start_Date, Pref_Score_End_Date, Pref_Score_Rate,
  Start_Date, End_Date, Rate, Score_Start_Date, Score_End_Date,
  Score_Rate, Phase_no, Confidence, Success, Deviation_Start_Date,
  Deviation_End_Date, Deviation_Rate, Base_Deviation_Start_Date,
  Base_Deviation_End_Date, Base_Deviation_Rate, Dev_Is_CC_Start_Date,
  Dev_Is_CC_End_Date, Dev_Is_CC_Rate, Is_CC_Start_Date,
  Is_CC_End_Date, Is_CC_Rate)
SELECT DISTINCT Stressed_LVL_6.Run_ID,
                Stressed_LVL_6.Task_ID,
                case
                when Stressed_LVL_6.Agent IS NULL
                then Baseline.Agent
                else Stressed_LVL_6.Agent
                end,
                case
                when Stressed_LVL_6.Verb IS NULL
                then Baseline.Verb
                else Stressed_LVL_6.Verb
                end,
                case
                when Stressed_LVL_6.NSN_Number IS NULL
                then Baseline.NSN_Number
                else Stressed_LVL_6.NSN_Number
                end,
	      	case
                when Stressed_LVL_6.ClassName IS NULL
                     then Baseline.ClassName
                else Stressed_LVL_6.ClassName
                end,
                case
                when Stressed_LVL_6.SupplyClass IS NULL
                then Baseline.SupplyClass
                else Stressed_LVL_6.SupplyClass
                end,
                case
                when Stressed_LVL_6.SupplyType IS NULL
                then Baseline.SupplyType
                else Stressed_LVL_6.SupplyType
                end,
                case
                when Stressed_LVL_6.For_Organization IS NULL
                then Baseline.For_Organization
                else Stressed_LVL_6.For_Organization
                end,
                case
                when Stressed_LVL_6.To_Location IS NULL
                then Baseline.To_Location
                else Stressed_LVL_6.To_Location
                end,
                case
                when Stressed_LVL_6.Maintaining IS NULL
                then Baseline.Maintaining
                else Stressed_LVL_6.Maintaining
                end,
                case
                when Stressed_LVL_6.Preferred_Start_Date IS NULL
                then Baseline.Preferred_Start_Date
                else Stressed_LVL_6.Preferred_Start_Date
                end,
                case
                when Stressed_LVL_6.Preferred_End_Date IS NULL
                then Baseline.Preferred_End_Date
                else Stressed_LVL_6.Preferred_End_Date
                end,
                case
                when Stressed_LVL_6.Preferred_Rate IS NULL
                then Baseline.Preferred_Rate
                else Stressed_LVL_6.Preferred_Rate
                end,
                case
                when Stressed_LVL_6.Scoring_Fn_Start_Date IS NULL
                then Baseline.Scoring_Fn_Start_Date
                else Stressed_LVL_6.Scoring_Fn_Start_Date
                end,
                case
                when Stressed_LVL_6.Scoring_Fn_End_Date IS NULL
                then Baseline.Scoring_Fn_End_Date
                else Stressed_LVL_6.Scoring_Fn_End_Date
                end,
                case
                when Stressed_LVL_6.Scoring_Fn_Rate IS NULL
                then Baseline.Scoring_Fn_Rate
                else Stressed_LVL_6.Scoring_Fn_Rate
                end,
                case
                when Stressed_LVL_6.Pref_Score_Start_Date IS NULL
                then Baseline.Pref_Score_Start_Date
                else Stressed_LVL_6.Pref_Score_Start_Date
                end,
                case
                when Stressed_LVL_6.Pref_Score_End_Date IS NULL
                then Baseline.Pref_Score_End_Date
                else Stressed_LVL_6.Pref_Score_End_Date
                end,
                case
                when Stressed_LVL_6.Pref_Score_Rate IS NULL
                then Baseline.Pref_Score_Rate
                else Stressed_LVL_6.Pref_Score_Rate
                end,
                Stressed_LVL_6.Start_Date,
                Stressed_LVL_6.End_Date,
                Stressed_LVL_6.Rate,
                Stressed_LVL_6.Score_Start_Date,
                Stressed_LVL_6.Score_End_Date,
                Stressed_LVL_6.Score_Rate,
                Stressed_LVL_6.Phase_no,
                Stressed_LVL_6.Confidence,
                Stressed_LVL_6.Success,
                Stressed_LVL_6.Score_Start_Date,
                Stressed_LVL_6.Score_End_Date ,
	        Stressed_LVL_6.Score_Rate,
                Baseline.Score_Start_Date,
                Baseline.Score_End_Date ,
                Baseline.Score_Rate ,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Success    = '0'             then 0
                when Stressed_LVL_6.Deviation_Start_Date IS NULL then NULL
                when Baseline.Deviation_Start_Date IS NULL then 1
                when Stressed_LVL_6.Deviation_Start_Date >
                                    0.05 + Baseline.Deviation_Start_Date then 0
                else 1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Success    = '0'             then 0
                when Stressed_LVL_6.Deviation_End_Date IS NULL then NULL
                when Baseline.Deviation_End_Date IS NULL then 1
                when Stressed_LVL_6.Deviation_End_Date  >
                                    0.05 + Baseline.Deviation_End_Date then 0
                else  1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Success    = '0'             then 0
                when Stressed_LVL_6.Deviation_Rate IS NULL then NULL
                when Baseline.Deviation_Rate IS NULL then 1
                when Stressed_LVL_6.Deviation_Rate  >
                                    0.05 + Baseline.Deviation_Rate then 0
                else  1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Score_Start_Date IS NULL then NULL
                when Baseline.Score_Start_Date IS NULL then 1
                when Stressed_LVL_6.Score_Start_Date >
                     Baseline.Score_Start_Date         then 0
                else 1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Score_End_Date IS NULL then NULL
                when Baseline.Score_End_Date IS NULL then 1
                when Stressed_LVL_6.Score_End_Date >
                     Baseline.Score_End_Date          then 0
                     else 1
                end,
                case
                when Stressed_LVL_6.Confidence < 0.89            then NULL
                when Stressed_LVL_6.Score_Rate IS NULL then NULL
                when Baseline.Score_Rate IS NULL then 1
                when Stressed_LVL_6.Score_Rate >
                     Baseline.Score_Rate          then 0
                     else 1
                end
FROM Stressed_LVL_6, Baseline
WHERE     Stressed_LVL_6.Agent                = Baseline.Agent
      AND Stressed_LVL_6.Verb                 = Baseline.Verb
      AND Stressed_LVL_6.NSN_Number           = Baseline.NSN_Number
      AND Stressed_LVL_6.ClassName            = Baseline.ClassName
      AND Stressed_LVL_6.SupplyClass          = Baseline.SupplyClass
      AND Stressed_LVL_6.SupplyType           = Baseline.SupplyType
      AND Stressed_LVL_6.For_Organization     = Baseline.For_Organization
      AND Stressed_LVL_6.To_Location          = Baseline.To_Location
      AND Stressed_LVL_6.Maintaining          = Baseline.Maintaining
      AND Stressed_LVL_6.Preferred_Start_Date = Baseline.Preferred_Start_Date
      AND Stressed_LVL_6.Preferred_End_Date   = Baseline.Preferred_End_Date
      AND Stressed_LVL_6.Phase_no             = Baseline.Phase_no
      AND Stressed_LVL_6.Verb                = 'ProjectSupply'; 
\!date
-- 11 (drop_Matched_Directly) 
 drop table Matched_Directly; 

-- 12 (Matched_Directly) 
 
create table Matched_Directly as
select Stressed_LVL_2.run_id,
       Stressed_LVL_2.task_id,
       Stressed_LVL_2.agent,
       Stressed_LVL_2.verb,
       Baseline.nsn_number,
       Stressed_LVL_2.classname,
       Stressed_LVL_2.supplyclass,
       Stressed_LVL_2.supplytype,
       Stressed_LVL_2.from_location,
       Stressed_LVL_2.for_organization,
       Stressed_LVL_2.to_location ,
       Stressed_LVL_2.maintaining,
       Stressed_LVL_2.preferred_quantity,
       Stressed_LVL_2.preferred_start_date ,
       Stressed_LVL_2.preferred_end_date,
       Baseline.preferred_rate,
       Stressed_LVL_2.scoring_fn_quantity ,
       Stressed_LVL_2.scoring_fn_start_date,
       Stressed_LVL_2.scoring_fn_end_date,
       Stressed_LVL_2.scoring_fn_rate ,
       Stressed_LVL_2.pref_score_quantity,
       Stressed_LVL_2.pref_score_start_date,
       Stressed_LVL_2.pref_score_end_date ,
       Stressed_LVL_2.pref_score_rate,
       Stressed_LVL_2.quantity,
       Stressed_LVL_2.start_date,
       Stressed_LVL_2.end_date,
       Stressed_LVL_2.rate,
       Stressed_LVL_2.score_quantity,
       Stressed_LVL_2.score_start_date ,
       Stressed_LVL_2.score_end_date,
       Stressed_LVL_2.score_rate,
       Stressed_LVL_2.phase_no,
       Stressed_LVL_2.confidence,
       Stressed_LVL_2.success ,
       Stressed_LVL_2.deviation_quantity ,
       Stressed_LVL_2.deviation_start_date,
       Stressed_LVL_2.deviation_end_date,
       Stressed_LVL_2.deviation_rate,
       Stressed_LVL_2.Task_Id as  Level_Two_Task,
       Stressed_LVL_2.nsn_number as Level_Two_NSN,
       Stressed_LVL_2.preferred_rate as Level_Two_Pref_rate,
       Stressed_LVL_2.rate as Level_Two_rate,
       Baseline.classname as baseline_classname,
       Baseline.min_start_date as baseline_min_start_date,
       Baseline.min_end_date as baseline_min_end_date,
       Baseline.min_quantity as baseline_min_quantity,
       Baseline.min_rate as baseline_min_rate,
       Baseline.max_start_date as baseline_max_start_date,
       Baseline.max_end_date as baseline_max_end_date,
       Baseline.max_quantity as baseline_max_quantity,
       Baseline.max_rate as baseline_max_rate,
       Baseline.score_start_date as baseline_score_start_date,
       Baseline.score_end_date as baseline_score_end_date,
       Baseline.score_quantity as baseline_score_quantity,
       Baseline.score_rate as baseline_score_rate,
       Baseline.deviation_start_date as baseline_deviation_start_date,
       Baseline.deviation_end_date as baseline_deviation_end_date,
       Baseline.deviation_quantity as baseline_deviation_quantity,
       Baseline.deviation_rate as baseline_deviation_rate,
       Baseline.scoring_fn_quantity as baseline_scoring_fn_quantity,
       Baseline.scoring_fn_start_date as baseline_scoring_fn_start_date,
       Baseline.scoring_fn_end_date as baseline_scoring_fn_end_date,
       Baseline.scoring_fn_rate as baseline_scoring_fn_rate,
       Baseline.pref_score_quantity as baseline_pref_score_quantity,
       Baseline.pref_score_start_date as baseline_pref_score_start_date,
       Baseline.pref_score_end_date as baseline_pref_score_end_date,
       Baseline.pref_score_rate as baseline_pref_score_rate
from  Stressed_LVL_2, Baseline
where Stressed_LVL_2.agent                = Baseline.agent
  and Stressed_LVL_2.verb                 = Baseline.verb
  and Stressed_LVL_2.preferred_end_date   = Baseline.preferred_end_date
  and Stressed_LVL_2.preferred_start_date = Baseline.preferred_start_date
  and Stressed_LVL_2.SupplyClass     	  = Baseline.SupplyClass
  and Stressed_LVL_2.SupplyType      	  = Baseline.SupplyType
  and Stressed_LVL_2.for_organization     = Baseline.for_organization
  and Stressed_LVL_2.maintaining          = Baseline.maintaining ; 
\!date
-- 13 (drop_Compare_One) 
 drop table Compare_One; 

-- 14 (Compare_One) 
 create TABLE Compare_One as
select run_id, task_id, agent, verb, classname,
       supplyclass, supplytype, 
       for_organization, to_location , maintaining,
       preferred_start_date , preferred_end_date,
       scoring_fn_start_date,
       scoring_fn_end_date, scoring_fn_rate , 
       pref_score_start_date, pref_score_end_date , pref_score_rate,
       start_date, end_date, 
       score_start_date , score_end_date, score_rate, phase_no,
       confidence, success , 
       deviation_start_date, deviation_end_date, deviation_rate,
       Level_Two_Task, Level_Two_NSN, Level_Two_Pref_rate,
       Level_Two_Rate,
       sum(preferred_rate) as sum_pref_rate,
       sum(baseline_min_rate) as sum_min_rate,
       sum(baseline_max_rate) as sum_max_rate
FROM Matched_Directly
GROUP BY run_id, task_id, agent, verb, classname,
	 supplyclass, supplytype, for_organization, to_location ,
	 maintaining, preferred_start_date, preferred_end_date,
	 scoring_fn_start_date, scoring_fn_end_date,
	 scoring_fn_rate, pref_score_start_date, pref_score_end_date ,
	 pref_score_rate, start_date, end_date, 
	 score_start_date, score_end_date, score_rate, phase_no,
	 confidence, success, deviation_start_date,
	 deviation_end_date, deviation_rate,
         Level_Two_Task, Level_Two_NSN, Level_Two_Pref_rate,
         Level_Two_Rate; 
\!date
-- 15 (drop_Compare_Two) 
 drop table Compare_Two; 

-- 16 (Compare_Two) 
 create table Compare_Two as
select Matched_Directly.run_id,
       Matched_Directly.task_id,
       Matched_Directly.agent,
       Matched_Directly.verb,
       Matched_Directly.nsn_number,
       Matched_Directly.classname,
       Matched_Directly.supplyclass,
       Matched_Directly.supplytype,
       Matched_Directly.from_location,
       Matched_Directly.for_organization,
       Matched_Directly.to_location ,
       Matched_Directly.maintaining,
       Matched_Directly.preferred_quantity,
       Matched_Directly.preferred_start_date ,
       Matched_Directly.preferred_end_date,
       Matched_Directly.preferred_rate,
       Matched_Directly.scoring_fn_quantity ,
       Matched_Directly.scoring_fn_start_date,
       Matched_Directly.scoring_fn_end_date,
       Matched_Directly.scoring_fn_rate ,
       Matched_Directly.pref_score_quantity,
       Matched_Directly.pref_score_start_date,
       Matched_Directly.pref_score_end_date,
       Matched_Directly.pref_score_rate,
       Matched_Directly.quantity,
       Matched_Directly.start_date,
       Matched_Directly.end_date,
       Matched_Directly.rate,
       Matched_Directly.score_quantity,
       Matched_Directly.score_start_date ,
       Matched_Directly.score_end_date,
       Matched_Directly.score_rate,
       Matched_Directly.phase_no,
       Matched_Directly.confidence,
       Matched_Directly.success ,
       Matched_Directly.deviation_quantity ,
       Matched_Directly.deviation_start_date,
       Matched_Directly.deviation_end_date,
       Matched_Directly.deviation_rate,
       Matched_Directly.baseline_classname,
       Matched_Directly.baseline_min_start_date,
       Matched_Directly.baseline_min_end_date,
       Matched_Directly.baseline_min_quantity,
       Matched_Directly.baseline_min_rate,
       Matched_Directly.baseline_max_start_date,
       Matched_Directly.baseline_max_end_date,
       Matched_Directly.baseline_max_quantity,
       Matched_Directly.baseline_max_rate,
       Matched_Directly.baseline_score_start_date,
       Matched_Directly.baseline_score_end_date,
       Matched_Directly.baseline_score_quantity,
       Matched_Directly.baseline_score_rate,
       Matched_Directly.baseline_deviation_start_date,
       Matched_Directly.baseline_deviation_end_date,
       Matched_Directly.baseline_deviation_quantity,
       Matched_Directly.baseline_deviation_rate,
       Matched_Directly.baseline_scoring_fn_quantity,
       Matched_Directly.baseline_scoring_fn_start_date,
       Matched_Directly.baseline_scoring_fn_end_date,
       Matched_Directly.baseline_scoring_fn_rate,
       Matched_Directly.baseline_pref_score_quantity,
       Matched_Directly.baseline_pref_score_start_date,
       Matched_Directly.baseline_pref_score_end_date,
       Matched_Directly.baseline_pref_score_rate,
       Matched_Directly.Level_Two_Task,
       Matched_Directly.Level_Two_NSN,
       Matched_Directly.Level_Two_Pref_Rate,
       Matched_Directly.Level_Two_Rate,
       Compare_One.sum_pref_rate,
       Compare_One.sum_min_rate,
       Compare_One.sum_max_rate
from Matched_Directly, Compare_One
where Matched_Directly.run_id  		     = Compare_One.run_id
  AND Matched_Directly.task_id 		     = Compare_One.task_id
  AND Matched_Directly.agent   		     = Compare_One.agent
  AND Matched_Directly.verb    		     = Compare_One.verb
  AND Matched_Directly.classname      	     = Compare_One.classname
  AND Matched_Directly.supplyclass    	     = Compare_One.supplyclass
  AND Matched_Directly.supplytype     	     = Compare_One.supplytype
  AND Matched_Directly.for_organization      = Compare_One.for_organization
  AND Matched_Directly.to_location           = Compare_One.to_location
  AND Matched_Directly.maintaining           = Compare_One.maintaining
  AND Matched_Directly.preferred_start_date  = Compare_One.preferred_start_date
  AND Matched_Directly.preferred_end_date    = Compare_One.preferred_end_date
  AND Matched_Directly.scoring_fn_start_date = Compare_One.scoring_fn_start_date
  AND Matched_Directly.scoring_fn_end_date   = Compare_One.scoring_fn_end_date
  AND Matched_Directly.scoring_fn_rate       = Compare_One.scoring_fn_rate
  AND Matched_Directly.pref_score_start_date = Compare_One.pref_score_start_date
  AND Matched_Directly.pref_score_end_date   = Compare_One.pref_score_end_date
  AND Matched_Directly.pref_score_rate       = Compare_One.pref_score_rate
  AND Matched_Directly.start_date            = Compare_One.start_date
  AND Matched_Directly.end_date 	     = Compare_One.end_date
  AND Matched_Directly.score_start_date      = Compare_One.score_start_date
  AND Matched_Directly.score_end_date        = Compare_One.score_end_date
  AND Matched_Directly.score_rate            = Compare_One.score_rate
  AND Matched_Directly.phase_no   	     = Compare_One.phase_no
  AND Matched_Directly.confidence 	     = Compare_One.confidence
  AND Matched_Directly.success    	     = Compare_One.success
  AND Matched_Directly.deviation_start_date  = Compare_One.deviation_start_date
  AND Matched_Directly.deviation_end_date    = Compare_One.deviation_end_date
  AND Matched_Directly.deviation_rate        = Compare_One.deviation_rate; 
\!date
-- 17 (Insert_Completion) 
 
INSERT INTO Completion_L2(Run_ID, Task_ID, 
                       Agent, Verb, NSN_Number, ClassName,
  		       SupplyClass, SupplyType, For_Organization,
  		       To_Location, Maintaining, Preferred_Start_Date,
  		       Preferred_End_Date, Preferred_Rate,
  		       Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  		       Scoring_Fn_Rate, Pref_Score_Start_Date,
  		       Pref_Score_End_Date, Pref_Score_Rate,
  		       Start_Date, End_Date, Rate, Score_Start_Date,
  		       Score_End_Date, Score_Rate, Phase_no,
  		       Confidence, Success, Deviation_Start_Date,
  		       Deviation_End_Date, Deviation_Rate,
  		       Level_Two_Task, Level_Two_NSN,
                       Level_Two_Rate, Summed_Lvl_6_Rate,
                       Summed_MIN_Rate, Summed_MAX_Rate,
                       Dev_Is_CC_Start_Date,
  		       Dev_Is_CC_End_Date, Dev_Is_CC_Rate,
  		       Is_CC_Start_Date, Is_CC_End_Date, Is_CC_Rate)
SELECT DISTINCT Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName,
  		SupplyClass, SupplyType, For_Organization,
  		To_Location, Maintaining, Preferred_Start_Date,
  		Preferred_End_Date, Preferred_Rate,
  		Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  		Scoring_Fn_Rate, Pref_Score_Start_Date,
  		Pref_Score_End_Date, Pref_Score_Rate, Start_Date,
  		End_Date, Rate, Score_Start_Date, Score_End_Date,
  		Score_Rate, Phase_no, Confidence, Success,
  		Deviation_Start_Date, Deviation_End_Date,
  		Deviation_Rate, Level_Two_Task,
                Level_Two_NSN, Level_Two_Rate, sum_pref_rate,
                sum_min_rate, sum_max_rate,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Start_Date IS NULL then NULL
                else 1
                end,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_End_Date IS NULL then NULL
                else  1
                end,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Rate IS NULL then NULL
                else  1
                end,
                case
                when Confidence < 0.89            then NULL
                when Score_Start_Date IS NULL then NULL
                else 1
                end,
                case
                when Confidence < 0.89            then NULL
                when Score_End_Date IS NULL then NULL
                     else 1
                end,
                case
                when Confidence < 0.89            then NULL
                when Level_Two_Rate = 0 AND sum_min_rate = 0 then 1
                when Level_Two_Rate = 0 then 0
                when (sum_min_rate - Level_Two_Rate) / Level_Two_Rate > 0.01
                  OR (Level_Two_Rate - sum_max_rate) / Level_Two_Rate > 0.01
                     then 0
                     else 1
                end
FROM Compare_Two; 
\!date
-- 18 (drop_Remaining_LVL_2) 
 drop table Remaining_LVL_2; 

-- 19 (Remaining_LVL_2) 
 create table Remaining_LVL_2 as
select * from Stressed_LVL_2
where task_id in  (select task_id from Stressed_LVL_2
                   except
                   select task_id from Matched_Directly); 
\!date
-- 20 (drop_LVL_6_Rolledup) 
 drop table LVL_6_Rolledup; 

-- 21 (LVL_6_Rolledup) 
 create table LVL_6_Rolledup as
select Stressed_LVL_6.run_id,
       Stressed_LVL_6.task_id,
       Remaining_LVL_2.agent,
       Remaining_LVL_2.verb,
       Stressed_LVL_6.nsn_number,
       Remaining_LVL_2.classname,
       Remaining_LVL_2.supplyclass,
       Remaining_LVL_2.supplytype,
       Remaining_LVL_2.from_location,
       Remaining_LVL_2.for_organization,
       Remaining_LVL_2.to_location ,
       Remaining_LVL_2.maintaining,
       Remaining_LVL_2.preferred_quantity,
       Remaining_LVL_2.preferred_start_date ,
       Remaining_LVL_2.preferred_end_date,
       Stressed_LVL_6.preferred_rate,
       Remaining_LVL_2.scoring_fn_quantity ,
       Remaining_LVL_2.scoring_fn_start_date,
       Remaining_LVL_2.scoring_fn_end_date,
       Remaining_LVL_2.scoring_fn_rate ,
       Remaining_LVL_2.pref_score_quantity,
       Remaining_LVL_2.pref_score_start_date,
       Remaining_LVL_2.pref_score_end_date ,
       Stressed_LVL_6.pref_score_rate,
       Remaining_LVL_2.quantity,
       Remaining_LVL_2.start_date,
       Remaining_LVL_2.end_date,
       Stressed_LVL_6.rate,
       Remaining_LVL_2.score_quantity,
       Remaining_LVL_2.score_start_date ,
       Remaining_LVL_2.score_end_date,
       Remaining_LVL_2.score_rate,
       Remaining_LVL_2.phase_no,
       Remaining_LVL_2.confidence,
       Remaining_LVL_2.success ,
       Remaining_LVL_2.deviation_quantity ,
       Remaining_LVL_2.deviation_start_date,
       Remaining_LVL_2.deviation_end_date,
       Remaining_LVL_2.deviation_rate,
       Remaining_LVL_2.Task_Id as  Level_Two_Task,
       Remaining_LVL_2.nsn_number as Level_Two_NSN,
       Remaining_LVL_2.pref_score_rate as Level_Two_pref_score_rate,
       Remaining_LVL_2.preferred_rate as Level_Two_Pref_Rate,
       Remaining_LVL_2.Rate as Level_Two_Rate,
       Stressed_LVL_6.classname as LVL_6_classname,
       Stressed_LVL_6.start_date as LVL_6_start_date,
       Stressed_LVL_6.preferred_start_date as LVL_6_pref_start_date,
       Stressed_LVL_6.end_date as LVL_6_end_date,
       Stressed_LVL_6.quantity as LVL_6_quantity,
       Stressed_LVL_6.rate as LVL_6_rate,
       Stressed_LVL_6.score_start_date as LVL_6_score_start_date,
       Stressed_LVL_6.score_end_date as LVL_6_score_end_date,
       Stressed_LVL_6.score_quantity as LVL_6_score_quantity,
       Stressed_LVL_6.score_rate as LVL_6_score_rate,
       Stressed_LVL_6.deviation_start_date as LVL_6_deviation_start_date,
       Stressed_LVL_6.deviation_end_date as LVL_6_deviation_end_date,
       Stressed_LVL_6.deviation_quantity as LVL_6_deviation_quantity,
       Stressed_LVL_6.deviation_rate as LVL_6_deviation_rate,
       Stressed_LVL_6.scoring_fn_quantity as LVL_6_scoring_fn_quantity,
       Stressed_LVL_6.scoring_fn_start_date as LVL_6_scoring_fn_start_date,
       Stressed_LVL_6.scoring_fn_end_date as LVL_6_scoring_fn_end_date,
       Stressed_LVL_6.scoring_fn_rate as LVL_6_scoring_fn_rate,
       Stressed_LVL_6.pref_score_quantity as LVL_6_pref_score_quantity,
       Stressed_LVL_6.pref_score_start_date as LVL_6_pref_score_start_date,
       Stressed_LVL_6.pref_score_end_date as LVL_6_pref_score_end_date,
       Stressed_LVL_6.pref_score_rate as LVL_6_pref_score_rate
from Stressed_LVL_6, Remaining_LVL_2
where Stressed_LVL_6.verb             = Remaining_LVL_2.verb
  and Stressed_LVL_6.agent            = Remaining_LVL_2.agent
  and Stressed_LVL_6.supplyclass      = Remaining_LVL_2.supplyclass
  and Stressed_LVL_6.supplytype       = Remaining_LVL_2.supplytype
  and Stressed_LVL_6.for_organization =
                                    Remaining_LVL_2.for_organization
  and Stressed_LVL_6.to_location      = Remaining_LVL_2.to_location 
  and Stressed_LVL_6.maintaining      = Remaining_LVL_2.maintaining 
  and Stressed_LVL_6.end_date         = Remaining_LVL_2.start_date; 
\!date
-- 22 (drop_Matched) 
 drop table Baseline_Matched; 

-- 23 (Matched) 
 create table Baseline_Matched as
select LVL_6_Rolledup.*, Baseline.MIN_Rate as baseline_min_rate, 
       Baseline.MAX_Rate as baseline_max_rate, 
       Baseline.preferred_start_date as baseline_pref_start_date
from   Baseline, LVL_6_Rolledup
where LVL_6_Rolledup.agent                = Baseline.agent
  and LVL_6_Rolledup.lvl_6_classname      = Baseline.classname
  and LVL_6_Rolledup.NSN_Number           = Baseline.NSN_Number
  and LVL_6_Rolledup.maintaining          = Baseline.maintaining
  and LVL_6_Rolledup.verb                 = Baseline.verb
  and LVL_6_Rolledup.SupplyClass          = Baseline.SupplyClass
  and LVL_6_Rolledup.SupplyType           = Baseline.SupplyType
  and LVL_6_Rolledup.to_location          = Baseline.to_location
  and LVL_6_Rolledup.for_organization     = Baseline.for_organization
  and LVL_6_pref_start_date      = Baseline.preferred_start_date
  and LVL_6_Rolledup.preferred_rate       = Baseline.preferred_rate
 ; 
\!date
-- 24 (drop_Artificial_LVL_2) 
 drop table Artificial_LVL_2; 

-- 25 (Artificial_LVL_2) 
 create table Artificial_LVL_2 as
select run_id, agent, verb, classname, supplyclass, supplytype,
       for_organization, to_location , maintaining,
       preferred_start_date , preferred_end_date,
       scoring_fn_start_date,
       scoring_fn_end_date, scoring_fn_rate ,
       pref_score_start_date, pref_score_end_date , pref_score_rate,
       start_date, end_date, 
       score_start_date , score_end_date, phase_no,
       confidence, success , 
       deviation_start_date, deviation_end_date, deviation_rate,
       Level_Two_Task, Level_Two_NSN, Level_Two_pref_score_rate,
       Level_Two_Pref_Rate, Level_Two_Rate,
       sum(preferred_rate) as Summed_LVL_6_Pref_Rate,
       sum(rate) as Summed_LVL_6_Rate,
       sum(baseline_min_rate) as Summed_MIN_Rate,
       sum(baseline_max_rate) as Summed_MAX_Rate
from Baseline_Matched
group by run_id, agent, verb, classname, supplyclass, supplytype,
       for_organization, to_location , maintaining,
       preferred_start_date , preferred_end_date,
       scoring_fn_start_date,
       scoring_fn_end_date, scoring_fn_rate , 
       pref_score_start_date, pref_score_end_date , pref_score_rate,
       start_date, end_date, 
       score_start_date , score_end_date, phase_no,
       confidence, success ,
       deviation_start_date, deviation_end_date, deviation_rate,
       Level_Two_Task, Level_Two_NSN, Level_Two_pref_score_rate,
       Level_Two_Pref_Rate, Level_Two_Rate; 
\!date
-- 26 (drop_Matched_With_Sum) 
 drop table Matched_With_Sum; 

-- 27 (Matched_With_Sum) 
 create table Matched_With_Sum as
SELECT Baseline_Matched.*,
       Artificial_LVL_2.Summed_LVL_6_Pref_Rate,
       Artificial_LVL_2.Summed_LVL_6_Rate,
       Artificial_LVL_2.Summed_MIN_Rate, 
       Artificial_LVL_2.Summed_MAX_Rate
from Baseline_Matched, Artificial_LVL_2
where Baseline_Matched.run_id           = Artificial_LVL_2.run_id
  and Baseline_Matched.agent            = Artificial_LVL_2.agent
  and Baseline_Matched.verb             = Artificial_LVL_2.verb
  and Baseline_Matched.SupplyClass      = Artificial_LVL_2.SupplyClass
  and Baseline_Matched.SupplyType       = Artificial_LVL_2.SupplyType
  and Baseline_Matched.to_location      = Artificial_LVL_2.to_location
  and Baseline_Matched.for_organization = Artificial_LVL_2.for_organization
  and Baseline_Matched.preferred_end_date = Artificial_LVL_2.preferred_end_date
  and Baseline_Matched.Level_Two_Rate   = Artificial_LVL_2.Level_Two_Rate
  and Baseline_Matched.Level_Two_Task   = Artificial_LVL_2.Level_Two_Task
  and Baseline_Matched.Level_Two_NSN    = Artificial_LVL_2.Level_Two_NSN
  and Baseline_Matched.Level_Two_pref_score_rate =
                                     Artificial_LVL_2.Level_Two_pref_score_rate
  and Baseline_Matched.Level_Two_Pref_Rate = 
                                          Artificial_LVL_2.Level_Two_Pref_Rate
  and Baseline_Matched.maintaining      = Artificial_LVL_2.maintaining; 
\!date
-- 28 (Insert_Completion) 
 
 INSERT INTO Completion_L2(Run_ID, Task_ID,
                       Agent, Verb, NSN_Number, ClassName,
  		       SupplyClass, SupplyType, For_Organization,
  		       To_Location, Maintaining, Preferred_Start_Date,
  		       Preferred_End_Date, Preferred_Rate,
  		       Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  		       Scoring_Fn_Rate, Pref_Score_Start_Date,
  		       Pref_Score_End_Date, Pref_Score_Rate,
  		       Start_Date, End_Date, Rate, Score_Start_Date,
  		       Score_End_Date, Score_Rate, Phase_no,
  		       Confidence, Success, Deviation_Start_Date,
  		       Deviation_End_Date, Deviation_Rate,
  		       Level_Two_Task, Level_Two_NSN,
                       Level_Two_Rate,
                       Summed_LVL_6_Rate, Summed_MIN_Rate,
                       Summed_MAX_Rate,
                       Dev_Is_CC_Start_Date,
  		       Dev_Is_CC_End_Date, Dev_Is_CC_Rate,
  		       Is_CC_Start_Date, Is_CC_End_Date, Is_CC_Rate)
SELECT DISTINCT Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName,
  		SupplyClass, SupplyType, For_Organization,
  		To_Location, Maintaining, Preferred_Start_Date,
  		Preferred_End_Date, Preferred_Rate,
  		Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  		Scoring_Fn_Rate, Pref_Score_Start_Date,
  		Pref_Score_End_Date, Pref_Score_Rate, Start_Date,
  		End_Date, Rate, Score_Start_Date, Score_End_Date,
  		Score_Rate, Phase_no, Confidence, Success,
  		Deviation_Start_Date, Deviation_End_Date,
  		Deviation_Rate, Level_Two_Task,
                Level_Two_NSN, Level_Two_Rate, Summed_LVL_6_Rate,
                Summed_MIN_Rate, Summed_MAX_Rate,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Start_Date IS NULL then NULL
                else 1
                end,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_End_Date IS NULL then NULL
                else  1
                end,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Rate IS NULL then NULL
                else  1
                end,
                case
                when Confidence < 0.89            then NULL
                when Score_Start_Date IS NULL then NULL
                else 1
                end,
                case
                when Confidence < 0.89            then NULL
                when Score_End_Date IS NULL then NULL
                     else 1
                end,
                case
                when Confidence < 0.89            then NULL
                when Level_Two_Rate = 0 AND Summed_MIN_Rate = 0 then 1
                when Level_Two_Rate = 0 then 0
                when (Summed_MIN_Rate - Level_Two_Rate) /
                      Level_Two_Rate > 0.01
                  OR (Level_Two_Rate - Summed_MAX_Rate ) / 
                      Level_Two_Rate > 0.01
                     then 0
                     else 1
                end
FROM Matched_With_Sum; 
\!date
-- 29 (drop_Unmatched) 
 DROP TABLE Unmatched; 

-- 30 (Unmatched) 
 CREATE TABLE Unmatched as
select * from LVL_6_Rolledup 
where level_two_task in (select level_two_task 
                         from LVL_6_Rolledup 
                         except 
                         select level_two_task 
                         from Baseline_Matched); 
\!date
-- 31 (drop_Unmatched_LVL_2) 
 drop table Unmatched_LVL_2; 

-- 32 (Unmatched_LVL_2) 
 create table Unmatched_LVL_2 as
select run_id, agent, verb, classname, supplyclass, supplytype,
       for_organization, to_location , maintaining,
       preferred_start_date , preferred_end_date,
       preferred_rate, scoring_fn_start_date,
       scoring_fn_end_date, scoring_fn_rate ,
       pref_score_start_date, pref_score_end_date , pref_score_rate,
       start_date, end_date, 
       score_start_date , score_end_date, score_rate, phase_no,
       confidence, success , 
       deviation_start_date, deviation_end_date, deviation_rate,
       Level_Two_Task, Level_Two_NSN, Level_Two_Rate,
       sum(rate) as Summed_LVL_6_Rate
from Unmatched
group by run_id, agent,verb, classname, supplyclass, supplytype,
       for_organization, to_location , maintaining,
       preferred_start_date , preferred_end_date,
       preferred_rate, scoring_fn_start_date,
       scoring_fn_end_date, scoring_fn_rate , 
       pref_score_start_date, pref_score_end_date , pref_score_rate,
       start_date, end_date, 
       score_start_date , score_end_date, score_rate, phase_no,
       confidence, success ,
       deviation_start_date, deviation_end_date, deviation_rate,
       Level_Two_Task, Level_Two_NSN, Level_Two_Rate; 
\!date
-- 33 (drop_UnMatched_With_Sum) 
 drop table UnMatched_With_Sum; 

-- 34 (UnMatched_With_Sum) 
 create table UnMatched_With_Sum as
select Unmatched.*, Unmatched_LVL_2.Summed_LVL_6_Rate
from Unmatched, Unmatched_LVL_2
where Unmatched.run_id             = Unmatched_LVL_2.run_id
  and Unmatched.agent              = Unmatched_LVL_2.agent
  and Unmatched.verb               = Unmatched_LVL_2.verb
  and Unmatched.SupplyClass        = Unmatched_LVL_2.SupplyClass
  and Unmatched.SupplyType         = Unmatched_LVL_2.SupplyType
  and Unmatched.to_location        = Unmatched_LVL_2.to_location
  and Unmatched.for_organization   = Unmatched_LVL_2.for_organization
  and Unmatched.preferred_end_date = Unmatched_LVL_2.preferred_end_date
  and Unmatched.Level_Two_Rate     = Unmatched_LVL_2.Level_Two_Rate
  and Unmatched.Level_Two_Task     = Unmatched_LVL_2.Level_Two_Task
  and Unmatched.Level_Two_NSN      = Unmatched_LVL_2.Level_Two_NSN
  and Unmatched.maintaining        = Unmatched_LVL_2.maintaining; 
\!date
-- 35 (drop_Completion_unmatched) 
 drop table Completion_unmatched; 

-- 36 (Completion_unmatched) 
 create TABLE Completion_unmatched as
SELECT DISTINCT Run_ID, Task_ID, Agent, Verb, NSN_Number, ClassName,
  		SupplyClass, SupplyType, For_Organization,
  		To_Location, Maintaining, Preferred_Start_Date,
  		Preferred_End_Date, Preferred_Rate,
  		Scoring_Fn_Start_Date, Scoring_Fn_End_Date,
  		Scoring_Fn_Rate, Pref_Score_Start_Date,
  		Pref_Score_End_Date, Pref_Score_Rate, Start_Date,
  		End_Date, Rate, Score_Start_Date, Score_End_Date,
  		Score_Rate, Phase_no, Confidence, Success,
  		Deviation_Start_Date, Deviation_End_Date,
  		Deviation_Rate, Level_Two_Task,
                Level_Two_NSN, Level_Two_Rate, Summed_LVL_6_Rate,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Start_Date IS NULL then NULL
                else 1
                end as Dev_Is_CC_Start_Date,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_End_Date IS NULL then NULL
                else  1
                end as Dev_Is_CC_End_Date,
                case
                when Confidence < 0.89            then NULL
                when Success    = '0'             then 0
                when Deviation_Rate IS NULL then NULL
                else  1
                end as Dev_Is_CC_Rate,
                case
                when Confidence < 0.89            then NULL
                when Score_Start_Date IS NULL then NULL
                else 1
                end as Is_CC_Start_Date,
                case
                when Confidence < 0.89            then NULL
                when Score_End_Date IS NULL then NULL
                     else 1
                end as Is_CC_End_Date,
                case
                when Confidence < 0.89            then NULL
                when Level_Two_Rate = 0 AND Summed_LVL_6_Rate = 0 then 1
                when Level_Two_Rate = 0 then 0
                when (Summed_LVL_6_Rate / Level_Two_Rate >= 1.005 )  then 0
                     else 1
                end
FROM UnMatched_With_Sum; 

\!date
