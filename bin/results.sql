-- 000 (Temp_Results) 
 
CREATE TEMPORARY TABLE Temp_Results (
  NAME                  varchar(255)          default NULL,
  Transport_VALUE        double  precision     default '0.0',
  Supply_VALUE           double  precision     default '0.0',
  Project_Supply_VALUE   double  precision     default '0.0',
  VALUE                  double  precision     default '0.0'
); 

\!date
-- 001 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Total Number', (SELECT 2 * COUNT(*) FROM Baseline
                              WHERE VERB = 'Transport'),
        (SELECT 2 * COUNT(*) FROM Baseline
                              WHERE VERB = 'Supply'),
        (SELECT 3 * COUNT(*) FROM Baseline
                              WHERE VERB = 'ProjectSupply'),
         (SELECT 2 * COUNT(*) FROM Baseline) +
         (SELECT COUNT(*) FROM Baseline WHERE VERB = 'ProjectSupply'); 

\!date
-- 002 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incomplete Number Level 6',
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Rate IS NULL) ; 

\!date
-- 003 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incomplete Number  Level 6'; 

\!date
-- 004 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incomplete Number Level 2', NULL, NULL,
        (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Rate IS NULL); 

\!date
-- 005 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incomplete Number Level 2'; 

\!date
-- 006 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incomplete Number L2 Class IX', NULL, NULL,
        (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Start_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIX%') +
         (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_End_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIX%')   +
          (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Rate IS NULL
                                 AND SupplyClass LIKE 'ClassIX%'); 

\!date
-- 007 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incomplete Number L2 Class IX'; 

\!date
-- 008 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incomplete Number L2 Class V', NULL, NULL,
        (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Start_Date IS NULL
                                 AND SupplyClass LIKE 'ClassV%') +
         (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_End_Date IS NULL
                                 AND SupplyClass LIKE 'ClassV%')   +
          (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Rate IS NULL
                                 AND SupplyClass LIKE 'ClassV%'); 

\!date
-- 009 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incomplete Number L2 Class V'; 

\!date
-- 010 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incomplete Number L2 Class III', NULL, NULL,
        (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Start_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIII%') +
         (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_End_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIII%')   +
          (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Rate IS NULL
                                 AND SupplyClass LIKE 'ClassIII%'); 

\!date
-- 011 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incomplete Number L2 Class III'; 

\!date
-- 012 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incomplete Number',
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Rate IS NULL) +
        (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM Completion_L2
                               WHERE Dev_Is_CC_Rate IS NULL); 

\!date
-- 013 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incomplete Number'; 

\!date
-- 014 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Complete Number Level 6',
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Rate IS NULL); 

\!date
-- 015 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Complete Number Level 6'; 

\!date
-- 016 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Complete Number Level 2', NULL, NULL, 
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Start_Date IS NULL) +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_End_Date IS NULL)   +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Rate IS NULL); 

\!date
-- 017 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Complete Number Level 2'; 

\!date
-- 018 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Complete Number L2 Class IX', NULL, NULL, 
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Start_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIX%') +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_End_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIX%')   +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Rate IS NULL
                                 AND SupplyClass LIKE 'ClassIX%'); 

\!date
-- 019 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Complete Number L2 Class IX'; 

\!date
-- 020 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Complete Number L2 Class V', NULL, NULL, 
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Start_Date IS NULL
                                 AND SupplyClass LIKE 'ClassV%') +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_End_Date IS NULL
                                 AND SupplyClass LIKE 'ClassV%')   +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Rate IS NULL
                                 AND SupplyClass LIKE 'ClassV%'); 

\!date
-- 021 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Complete Number L2 Class V'; 

\!date
-- 022 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Complete Number L2 Class III', NULL, NULL, 
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Start_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIII%') +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_End_Date IS NULL
                                 AND SupplyClass LIKE 'ClassIII%')   +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Rate IS NULL
                                 AND SupplyClass LIKE 'ClassIII%'); 

\!date
-- 023 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Complete Number L2 Class III'; 

\!date
-- 024 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Unadjusted Complete Number',
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Rate IS NULL) +
       1.0 * ((SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Start_Date IS NULL) +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_End_Date IS NULL)   +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Rate IS NULL)); 

\!date
-- 025 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Unadjusted Complete Number'; 

\!date
-- 026 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Complete Number',
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM Completion
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM Completion
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Rate IS NULL) +
       0.8 * ((SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Start_Date IS NULL) +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_End_Date IS NULL)   +
              (SELECT COUNT(*) FROM Completion_L2
                               WHERE NOT Dev_Is_CC_Rate IS NULL)); 

\!date
-- 027 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Complete Number'; 

\!date
-- 028 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incorrect Number Level 6', 
                    (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' ); 

\!date
-- 029 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incorrect Number Level 6'; 

\!date
-- 030 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incorrect Number Level 2',  
                    (SELECT COUNT(*) FROM Completion_L2
                     WHERE VERB = 'Transport'
                     AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion_L2
                     WHERE VERB = 'Transport'
                     AND Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' ); 

\!date
-- 031 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incorrect Number Level 2'; 

\!date
-- 032 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incorrect Number L2 Class IX',  NULL,
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0'
                       AND SupplyClass LIKE 'ClassIX%') +
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' 
                       AND SupplyClass LIKE 'ClassIX%'),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0'
                       AND SupplyClass LIKE 'ClassIX%') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' 
                       AND SupplyClass LIKE 'ClassIX%')  +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' 
                       AND SupplyClass LIKE 'ClassIX%'); 

\!date
-- 033 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incorrect Number L2 Class IX'; 

\!date
-- 034 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incorrect Number L2 Class V',  NULL,
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0'
                       AND SupplyClass LIKE 'ClassV%') +
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' 
                       AND SupplyClass LIKE 'ClassV%'),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0'
                       AND SupplyClass LIKE 'ClassV%') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' 
                       AND SupplyClass LIKE 'ClassV%')  +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' 
                       AND SupplyClass LIKE 'ClassV%'); 

\!date
-- 035 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incorrect Number L2 Class V'; 

\!date
-- 036 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incorrect Number L2 Class III',  NULL,
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0'
                       AND SupplyClass LIKE 'ClassIII%') +
                     (SELECT COUNT(*) FROM Completion_L2
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' 
                       AND SupplyClass LIKE 'ClassIII%'),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0'
                       AND SupplyClass LIKE 'ClassIII%') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' 
                       AND SupplyClass LIKE 'ClassIII%')  +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' 
                       AND SupplyClass LIKE 'ClassIII%'); 

\!date
-- 037 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Project_Supply_VALUE
WHERE NAME='Incorrect Number L2 Class III'; 

\!date
-- 038 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incorrect Number',  (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' ) +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Is_CC_Rate = '0' ); 

\!date
-- 039 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incorrect Number'; 

\!date
-- 040 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Correct Number Level 6',  (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Rate = '0' ); 

\!date
-- 041 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Correct Number Level 6'; 

\!date
-- 042 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Correct Number Level 2', NULL, NULL,
                              (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Start_Date = '0') +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_End_Date = '0' )  +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Rate = '0' ); 

\!date
-- 043 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Correct Number Level 2'; 

\!date
-- 044 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Correct Number L2 Class IX', NULL, NULL,
                              (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIX%') +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIX%')  +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassIX%'); 

\!date
-- 045 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Correct Number L2 Class IX'; 

\!date
-- 046 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Correct Number L2 Class V', NULL, NULL,
                              (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassV%') +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassV%')  +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassV%'); 

\!date
-- 047 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Correct Number L2 Class V'; 

\!date
-- 048 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Correct Number L2 Class III', NULL, NULL,
                              (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIII%') +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIII%')  +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassIII%'); 

\!date
-- 049 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Correct Number L2 Class III'; 

\!date
-- 050 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Unadjusted Correct Number',  (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Rate = '0' ) +
                      1.0 * ((SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Start_Date = '0') +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_End_Date = '0' )  +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Rate = '0' )); 

\!date
-- 051 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Unadjusted Correct Number'; 

\!date
-- 052 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Correct Number',  (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Rate = '0' ) +
                      0.8 * ((SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Start_Date = '0') +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_End_Date = '0' )  +
                      	      (SELECT COUNT(*) FROM Completion_L2
                      	       WHERE NOT Is_CC_Rate = '0' )); 

\!date
-- 053 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Correct Number'; 

\!date
-- 054 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Variant Number Level 6',  
                      (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Dev_Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Dev_Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Dev_Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Dev_Is_CC_End_Date = '0' ) +
		       (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Dev_Is_CC_Rate = '0' ); 

\!date
-- 055 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Variant Number Level 6'; 

\!date
-- 056 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Variant Number Level 2', NULL, 
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                         AND VERB = 'Supply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                         AND VERB = 'Supply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                         AND VERB = 'Supply'),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                         AND VERB = 'ProjectSupply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                         AND VERB = 'ProjectSupply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                         AND VERB = 'ProjectSupply'); 

\!date
-- 057 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Variant Number Level 2'; 

\!date
-- 058 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Variant Number L2 Class IX', NULL, 
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIX%'
                                 AND VERB = 'Supply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND VERB = 'Supply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassIX%'
                                 AND VERB = 'Supply'),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIX%'
                                 AND VERB = 'ProjectSupply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND VERB = 'ProjectSupply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassIX%'
                                 AND VERB = 'ProjectSupply'); 

\!date
-- 059 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Variant Number L2 Class IX'; 

\!date
-- 060 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Variant Number L2 Class V', NULL, 
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassV%'
                                 AND VERB = 'Supply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassV%'
                                 AND VERB = 'Supply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassV%'
                                 AND VERB = 'Supply'),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassV%'
                                 AND VERB = 'ProjectSupply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassV%'
                                 AND VERB = 'ProjectSupply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassV%'
                                 AND VERB = 'ProjectSupply'); 

\!date
-- 061 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Variant Number L2 Class V'; 

\!date
-- 062 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Variant Number L2 Class III', NULL,
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIII%'
                                 AND VERB = 'Supply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIII%'
                                 AND VERB = 'Supply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassIII%'
                                 AND VERB = 'Supply'),
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIII%'
                                 AND VERB = 'ProjectSupply') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIII%'
                                 AND VERB = 'ProjectSupply') +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' 
                                 AND SupplyClass LIKE 'ClassIII%'
                                 AND VERB = 'ProjectSupply'); 

\!date
-- 063 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Variant Number L2 Class III'; 

\!date
-- 064 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Variant Number',  (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND Dev_Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Dev_Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND Dev_Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Dev_Is_CC_End_Date = '0' ) +
		       (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND Dev_Is_CC_Rate = '0' ) +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_End_Date = '0' ) +
		       (SELECT COUNT(*) FROM Completion_L2
                       WHERE Dev_Is_CC_Rate = '0' ); 

\!date
-- 065 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Variant Number'; 

\!date
-- 066 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Invariant Number Level 6',  (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Dev_Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Dev_Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Dev_Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Dev_Is_CC_End_Date = '0' ) +
		       (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Dev_Is_CC_Rate = '0' ); 

\!date
-- 067 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Invariant Number Level 6'; 

\!date
-- 068 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Invariant Number Level 2',  NULL, (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Start_Date = '0'
                                AND verb = 'Supply') +
                      	       (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_End_Date = '0' 
                                AND verb = 'Supply') +
		      	        (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Rate = '0'
                                AND verb = 'Supply'), 
	               (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Start_Date = '0'
                                AND verb = 'ProjectSupply') +
                      	       (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_End_Date = '0' 
                                AND verb = 'ProjectSupply') +
		      	        (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Rate = '0'
                                AND verb = 'ProjectSupply') ; 

\!date
-- 069 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Invariant Number Level 2'; 

\!date
-- 070 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Invariant Number L2 Class IX',  NULL,
                                (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND verb = 'Supply') +
                      	       (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND verb = 'Supply') +
		      	        (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Rate = '0'
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND verb = 'Supply'), 
	               (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND verb = 'ProjectSupply') +
                      	       (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND verb = 'ProjectSupply') +
		      	        (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Rate = '0'
                                 AND SupplyClass LIKE 'ClassIX%'
                                AND verb = 'ProjectSupply') ; 

\!date
-- 071 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Invariant Number L2 Class IX'; 

\!date
-- 072 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Invariant Number L2 Class V',  NULL, NULL, 
	               (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassV%') +
                      	       (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassV%') +
		      	        (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Rate = '0'
                                 AND SupplyClass LIKE 'ClassV%') ; 

\!date
-- 073 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Invariant Number L2 Class V'; 

\!date
-- 074 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Invariant Number L2 Class III',  NULL, NULL, 
	               (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Start_Date = '0'
                                 AND SupplyClass LIKE 'ClassIII%') +
                      	       (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_End_Date = '0' 
                                 AND SupplyClass LIKE 'ClassIII%') +
		      	        (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Rate = '0'
                                 AND SupplyClass LIKE 'ClassIII%') ; 

\!date
-- 075 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = case 
            when not Supply_VALUE is null 
            then Supply_VALUE  + Project_Supply_VALUE
            else Project_Supply_VALUE
            end
WHERE NAME='Invariant Number L2 Class III'; 

\!date
-- 076 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Invariant Number',  (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                     WHERE VERB = 'Transport'
                     AND NOT Dev_Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Dev_Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM Completion
                      WHERE VERB = 'Supply'
                      AND NOT Dev_Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Dev_Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Dev_Is_CC_End_Date = '0' ) +
		       (SELECT COUNT(*) FROM Completion
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Dev_Is_CC_Rate = '0' ) +
	               1.0 * ((SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Start_Date = '0') +
                      	       (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_End_Date = '0' ) +
		      	        (SELECT COUNT(*) FROM Completion_L2
                      	        WHERE NOT Dev_Is_CC_Rate = '0' )); 

\!date
-- 077 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Invariant Number'; 

\!date
-- 078 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Phased AR  Number Level 6',                          
	               (SELECT COUNT(DISTINCT Task_Id) FROM Completion
                      	WHERE Phase_no > 0
                          AND verb = 'Transport'),                         
	               (SELECT COUNT(DISTINCT Task_Id) FROM Completion
                      	WHERE Phase_no > 0
                          AND verb = 'Supply'),                        
	               (SELECT COUNT(DISTINCT Task_Id) FROM Completion
                      	WHERE Phase_no > 0
                          AND verb = 'ProjectSupply'); 

\!date
-- 079 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Phased AR  Number Level 6'; 

\!date
-- 080 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Phased AR  Number Level 2',                          
	               (SELECT COUNT(DISTINCT Task_Id) FROM Completion_L2
                      	WHERE Phase_no > 0
                          AND verb = 'Transport'),                         
	               (SELECT COUNT(DISTINCT Task_Id) FROM Completion_L2
                      	WHERE Phase_no > 0
                          AND verb = 'Supply'),                        
	               (SELECT COUNT(DISTINCT Task_Id) FROM Completion_L2
                      	WHERE Phase_no > 0
                          AND verb = 'ProjectSupply'); 

\!date
-- 081 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Phased AR  Number Level 2'; 

\!date
-- 082 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Matching L6 Phased AR  L2',                          
	               (SELECT COUNT(Task_Id) FROM Completion_L2
                      	WHERE Phase_no > 0
                          AND verb = 'Transport'),                         
	               (SELECT COUNT(Task_Id) FROM Completion_L2
                      	WHERE Phase_no > 0
                          AND verb = 'Supply'),                        
	               (SELECT COUNT(Task_Id) FROM Completion_L2
                      	WHERE Phase_no > 0
                          AND verb = 'ProjectSupply'); 

\!date
-- 083 (Insert_Temp_Results) 
 
UPDATE Temp_Results
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Matching L6 Phased AR  L2'; 

\!date
-- 084 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Total Number (First 7) min_start',
        (SELECT 2 * COUNT(*) FROM Baseline, Temp_Seventh_day
                              WHERE Baseline.VERB = 'Transport'
                                AND Baseline.min_start_date <
                                    Temp_Seventh_day.Boundary), 
        NULL,
        NULL,
        (SELECT 2 * COUNT(*) FROM Baseline, Temp_Seventh_day
                              WHERE Baseline.VERB = 'Transport'
                                AND Baseline.min_start_date <
                                    Temp_Seventh_day.Boundary); 

\!date
-- 085 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Total Number (First 7) Preferred_start',
        (SELECT 2 * COUNT(*) FROM Baseline, Temp_Seventh_day
                              WHERE Baseline.VERB = 'Transport'
                                AND Baseline.preferred_start_date <
                                    Temp_Seventh_day.Boundary), 
        NULL,
        NULL,
        (SELECT 2 * COUNT(*) FROM Baseline, Temp_Seventh_day
                              WHERE Baseline.VERB = 'Transport'
                                AND Baseline.preferred_start_date <
                                    Temp_Seventh_day.Boundary); 

\!date
-- 086 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incomplete Number (First 7)',
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                           AND Completion.Dev_Is_CC_Start_Date IS NULL
                           AND Completion.start_date <
                              Temp_Seventh_day.Boundary) +
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                           AND Completion.Dev_Is_CC_End_Date IS NULL
                           AND Completion.start_date <
                               Temp_Seventh_day.Boundary),
        NULL,
        NULL,
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                           AND Completion.Dev_Is_CC_Start_Date IS NULL
                           AND Completion.start_date <
                              Temp_Seventh_day.Boundary) +
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                           AND Completion.Dev_Is_CC_End_Date IS NULL
                           AND Completion.start_date <
                               Temp_Seventh_day.Boundary); 

\!date
-- 087 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Complete Number (First 7)',
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                          AND NOT Completion.Dev_Is_CC_Start_Date IS NULL
                           AND Completion.start_date <
                               Temp_Seventh_day.Boundary) +
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                          AND NOT Completion.Dev_Is_CC_End_Date IS NULL
                           AND Completion.start_date <
                               Temp_Seventh_day.Boundary),
        NULL,
        NULL,
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                          AND NOT Completion.Dev_Is_CC_Start_Date IS NULL
                           AND Completion.start_date <
                               Temp_Seventh_day.Boundary) +
        (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                         WHERE Completion.VERB = 'Transport'
                          AND NOT Completion.Dev_Is_CC_End_Date IS NULL
                           AND Completion.start_date <
                               Temp_Seventh_day.Boundary); 

\!date
-- 088 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Incorrect Number (First 7)', 
                    (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                       AND Completion.Is_CC_Start_Date = '0'
                       AND Completion.start_date <
                           Temp_Seventh_day.Boundary) +
                      (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                       AND Completion.Is_CC_End_Date = '0' 
                       AND Completion.start_date <
                           Temp_Seventh_day.Boundary),
                     NULL,
                     NULL,
                    (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                       AND Completion.Is_CC_Start_Date = '0'
                       AND Completion.start_date <
                           Temp_Seventh_day.Boundary) +
                      (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                       AND Completion.Is_CC_End_Date = '0' 
                       AND Completion.start_date <
                           Temp_Seventh_day.Boundary); 

\!date
-- 089 (Insert_Temp_Results) 
 
INSERT INTO Temp_Results
SELECT 'Correct Number (First 7)',
                    (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                     AND NOT Completion.Is_CC_Start_Date = '0'
                         AND Completion.start_date <
                             Temp_Seventh_day.Boundary) +
                     (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                     AND NOT Completion.Is_CC_End_Date = '0' 
                         AND Completion.start_date <
                             Temp_Seventh_day.Boundary),
                     NULL,
                     NULL,
                   (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                     AND NOT Completion.Is_CC_Start_Date = '0'
                         AND Completion.start_date <
                             Temp_Seventh_day.Boundary) +
                     (SELECT COUNT(*) FROM Completion, Temp_Seventh_day
                     WHERE Completion.VERB = 'Transport'
                     AND NOT Completion.Is_CC_End_Date = '0' 
                         AND Completion.start_date <
                             Temp_Seventh_day.Boundary); 

\!date
-- 090 (Insert_Temp_Results) 
 
DROP TABLE Results; 

\!date
-- 091 (Insert_Temp_Results) 
 
CREATE TABLE Results AS SELECT * from Temp_Results; 

\!date
-- 092 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Completeness %',
       case
       when total.transport_value > 0 then
          (complete.transport_value) / total.transport_value * 100
       else 0
       end,
       case
       when total.supply_value > 0 then
          (complete.supply_value) / total.supply_value * 100
       else 0
       end,
       case
       when total.project_supply_value > 0 then
          (complete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (complete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number'; 

\!date
-- 093 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Correctness %',
       case
       when complete.transport_value > 0 then
          (correct.transport_value) / (complete.transport_value) * 100
       else 0
       end,
       case
       when complete.supply_value > 0 then
          (correct.supply_value) / (complete.supply_value)* 100
       else 0
       end,
       case
       when complete.project_supply_value > 0 then
          (correct.project_supply_value) /(complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (correct.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number'; 

\!date
-- 094 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted Completeness %',
       case
       when total.transport_value > 0 then
          (complete.transport_value) / total.transport_value * 100
       else 0
       end,
       case
       when total.supply_value > 0 then
          (complete.supply_value) / total.supply_value * 100
       else 0
       end,
       case
       when total.project_supply_value > 0 then
          (complete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (complete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number'
  AND complete.name = 'Unadjusted Complete Number'
  AND correct.name  = 'Unadjusted Correct Number'; 

\!date
-- 095 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted Correctness %',
       case
       when complete.transport_value > 0 then
          (correct.transport_value) / (complete.transport_value) * 100
       else 0
       end,
       case
       when complete.supply_value > 0 then
          (correct.supply_value) / (complete.supply_value)* 100
       else 0
       end,
       case
       when complete.project_supply_value > 0 then
          (correct.project_supply_value) /(complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (correct.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number'
 AND complete.name = 'Unadjusted Complete Number'
  AND correct.name = 'Unadjusted Correct Number'; 

\!date
-- 096 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Class IX Incompleteness %', NULL, NULL, 
       case
       when total.project_supply_value > 0 then
          (incomplete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (incomplete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results incomplete, Temp_Results incorrect
WHERE total.name = 'Total Number'
  AND incomplete.name = 'Incomplete Number L2 Class IX'
  AND incorrect.name = 'Incorrect Number L2 Class IX'; 

\!date
-- 097 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Class IX Incorrectness %',  NULL, NULL, 
       case
       when complete.project_supply_value > 0 then
          (incorrect.project_supply_value) /
                (complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (incorrect.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results incorrect
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND incorrect.name = 'Incorrect Number L2 Class IX'; 

\!date
-- 098 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted L2 Class IX Incompleteness %', NULL, NULL, 
       case
       when total.project_supply_value > 0 then
          (incomplete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (incomplete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results incomplete, Temp_Results incorrect
WHERE total.name = 'Total Number'
  AND incomplete.name = 'Incomplete Number L2 Class IX'
  AND incorrect.name = 'Incorrect Number L2 Class IX'; 

\!date
-- 099 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted L2 Class IX Incorrectness %',  NULL, NULL, 
       case
       when complete.project_supply_value > 0 then
          (incorrect.project_supply_value) /
                (complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (incorrect.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results incorrect
WHERE total.name = 'Total Number'
 AND complete.name = 'Unadjusted Complete Number'
  AND incorrect.name = 'Incorrect Number L2 Class IX'; 

\!date
-- 100 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Class V Incompleteness %', NULL, NULL, 
       case
       when total.project_supply_value > 0 then
          (incomplete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (incomplete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results incomplete, Temp_Results incorrect
WHERE total.name = 'Total Number'
  AND incomplete.name = 'Incomplete Number L2 Class V'
  AND incorrect.name = 'Incorrect Number L2 Class V'; 

\!date
-- 101 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Class V Incorrectness %',  NULL, NULL, 
       case
       when complete.project_supply_value > 0 then
          (incorrect.project_supply_value) /
                (complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (incorrect.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results incorrect
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND incorrect.name = 'Incorrect Number L2 Class V'; 

\!date
-- 102 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted L2 Class V Incompleteness %', NULL, NULL, 
       case
       when total.project_supply_value > 0 then
          (incomplete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (incomplete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results incomplete, Temp_Results incorrect
WHERE total.name = 'Total Number'
  AND incomplete.name = 'Incomplete Number L2 Class V'
  AND incorrect.name = 'Incorrect Number L2 Class V'; 

\!date
-- 103 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted L2 Class V Incorrectness %',  NULL, NULL, 
       case
       when complete.project_supply_value > 0 then
          (incorrect.project_supply_value) /
                (complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (incorrect.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results incorrect
WHERE total.name = 'Total Number'
 AND complete.name = 'Unadjusted Complete Number'
  AND incorrect.name = 'Incorrect Number L2 Class V'; 

\!date
-- 104 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Class III Incompleteness %', NULL, NULL, 
       case
       when total.project_supply_value > 0 then
          (incomplete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (incomplete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results incomplete, Temp_Results incorrect
WHERE total.name = 'Total Number'
  AND incomplete.name = 'Incomplete Number L2 Class III'
  AND incorrect.name = 'Incorrect Number L2 Class III'; 

\!date
-- 105 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Class III Incorrectness %',  NULL, NULL, 
       case
       when complete.project_supply_value > 0 then
          (incorrect.project_supply_value) /
                (complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (incorrect.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results incorrect
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND incorrect.name = 'Incorrect Number L2 Class III'; 

\!date
-- 106 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted L2 Class III Incompleteness %', NULL, NULL, 
       case
       when total.project_supply_value > 0 then
          (incomplete.project_supply_value) / total.project_supply_value * 100
       else 0
       end,
       case
       when total.value > 0 then
          (incomplete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results incomplete, Temp_Results incorrect
WHERE total.name = 'Total Number'
  AND incomplete.name = 'Incomplete Number L2 Class III'
  AND incorrect.name = 'Incorrect Number L2 Class III'; 

\!date
-- 107 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Unadjusted L2 Class III Incorrectness %',  NULL, NULL, 
       case
       when complete.project_supply_value > 0 then
          (incorrect.project_supply_value) /
                (complete.project_supply_value) * 100
       else 0
       end,
       case
       when complete.value > 0 then
          (incorrect.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results incorrect
WHERE total.name = 'Total Number'
 AND complete.name = 'Unadjusted Complete Number'
  AND incorrect.name = 'Incorrect Number L2 Class III'; 

\!date
-- 108 (Insert_Results) 
 
INSERT INTO Results
SELECT '(First 7) Completeness % using baseline min_start_date',
       case
       when total.transport_value > 0 then
          (complete.transport_value) / total.transport_value * 100
       else 0
       end,
       NULL,
       NULL,
       case
       when total.value > 0 then
          (complete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number (First 7) min_start'
  AND complete.name = 'Complete Number (First 7)'
  AND correct.name  = 'Correct Number (First 7)'; 

\!date
-- 109 (Insert_Results) 
 
INSERT INTO Results
SELECT '(First 7) Completeness % using baseline Preferred_start_date',
       case
       when total.transport_value > 0 then
          (complete.transport_value) / total.transport_value * 100
       else 0
       end,
       NULL,
       NULL,
       case
       when total.value > 0 then
          (complete.value) / total.value * 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number (First 7) Preferred_start'
  AND complete.name = 'Complete Number (First 7)'
  AND correct.name  = 'Correct Number (First 7)'; 

\!date
-- 110 (Insert_Results) 
 
INSERT INTO Results
SELECT '(First 7) Correctness % using baseline min_start_date',
       case
       when complete.transport_value > 0 then
          (correct.transport_value) / (complete.transport_value) * 100
       else 0
       end,
       NULL,
       NULL,
       case
       when complete.value > 0 then
          (correct.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number (First 7) min_start'
 AND complete.name = 'Complete Number (First 7)'
  AND correct.name = 'Correct Number (First 7)'; 

\!date
-- 111 (Insert_Results) 
 
INSERT INTO Results
SELECT '(First 7) Correctness % using baseline Preferred_start_date',
       case
       when complete.transport_value > 0 then
          (correct.transport_value) / (complete.transport_value) * 100
       else 0
       end,
       NULL,
       NULL,
       case
       when complete.value > 0 then
          (correct.value) / (complete.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete, Temp_Results correct
WHERE total.name = 'Total Number (First 7) Preferred_start'
 AND complete.name = 'Complete Number (First 7)'
  AND correct.name = 'Correct Number (First 7)'; 

\!date
-- 112 (Insert_Results) 
 
INSERT INTO Results
SELECT 'Variation %',
       case
       when (complete_l6.transport_value) > 0
          then
          (invariant.transport_value) / (complete_l6.transport_value) * 100
       else 0
       end,
       case
       when (complete_l6.supply_value) > 0 then
          (invariant.supply_value) / (complete_l6.supply_value) * 100
       else 0
       end,
       case
       when (complete_l6.project_supply_value + 
           complete_l2.project_supply_value) > 0 then
          (invariant.project_supply_value) /
          (complete_l6.project_supply_value + 
           complete_l2.project_supply_value) * 100
       else 0
       end,
       case
       when (complete_l6.value + complete_l2.value) > 0 then
          (invariant.value) / (complete_l6.value + complete_l2.value)* 100
       else 0
       end
FROM Temp_Results total, Temp_Results complete_l6, Temp_Results invariant,
     Temp_Results complete_l2
WHERE total.name = 'Total Number'
  AND complete_l6.name = 'Complete Number Level 6'
  AND complete_l2.name = 'Complete Number Level 2'
  AND invariant.name = 'Invariant Number'; 

\!date

