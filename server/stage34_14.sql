-- 000 (Today) 
 
CREATE TEMPORARY TABLE TEMP_TODAY AS
SELECT ID, 
       case when Today < 1124082000000 then 1124082000000
       else Today
       end
FROM runs
; 

-- 001 (CREATE_TempResults) 
 
CREATE TEMPORARY TABLE "Stage34_1072311638_TRslt" (
  NAME                  varchar(255)          default NULL,
  Transport_VALUE        double  precision     default '0.0',
  Supply_VALUE           double  precision     default '0.0',
  Project_Supply_VALUE   double  precision     default '0.0',
  Inventory_VALUE        double  precision     default '0.0',
  VALUE                  double  precision     default '0.0'
);
 

-- 002 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Total Number', (SELECT 2 * COUNT(*) FROM "Stage34"
                              WHERE VERB = 'Transport'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 2 * COUNT(*) FROM "Stage34"
                              WHERE VERB = 'Supply'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 3 * COUNT(*) FROM "Stage34"
                              WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 2 * COUNT(*) FROM "Stage34"
                              WHERE VERB = 'Supply'
                              AND NSN_Number NOT LIKE 'Level2%') +
        (SELECT 3 * COUNT(*) FROM "Stage34"
                              WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%'),
         (SELECT 2 * COUNT(*) FROM "Stage34"
                              WHERE NSN_Number NOT LIKE 'Level2%') +
         (SELECT COUNT(*) FROM "Stage34" WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%');
 

-- 003 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Incomplete Number',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Rate IS NULL) ;

 

-- 004 (Update_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incomplete Number';
 

-- 005 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Complete Number',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Rate IS NULL);

 

-- 006 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Complete Number';
 

-- 007 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Incorrect Number', 
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                     WHERE VERB = 'Transport'
                     AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                     WHERE VERB = 'Transport'
                     AND Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' );
 

-- 008 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incorrect Number';

 

-- 009 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Correct Number',
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Rate = '0' );
 

-- 010 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Correct Number';
 

-- 011 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Incomplete Number',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Rate IS NULL);
 

-- 012 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Incomplete Number';
 

-- 013 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Complete Number',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Rate IS NULL);
 

-- 014 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Complete Number';
 

-- 015 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Incorrect Number', 
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' );
 

-- 016 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Incorrect Number';
 

-- 017 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Correct Number',
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Rate = '0' );
 

-- 018 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Correct Number';
 

-- 019 (UPDATE_TempResults) 
 
UPDATE "Stage34_1072311638_TRslt"
SET Inventory_VALUE = Supply_VALUE  + Project_Supply_VALUE;
 

-- 020 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Total Number (First 7)',
                      (SELECT 2 * COUNT(*) FROM "Stage34", temp_today
                              WHERE "Stage34".VERB = 'Transport'
                              AND    temp_today.ID = 1072311638
                              AND "Stage34".min_start_date <
                                  temp_today.today + 14 * 86400000
                              AND "Stage34".min_start_date >
                                  temp_today.today
                              AND "Stage34".NSN_Number NOT LIKE 'Level2%'),
                       NULL,
                       NULL,
                       NULL,
                       (SELECT 2 * COUNT(*) FROM "Stage34", temp_today
                              WHERE "Stage34".VERB = 'Transport'
                              AND    temp_today.ID = 1072311638
                              AND "Stage34".min_start_date < 
                                  temp_today.today + 14 * 86400000
                              AND "Stage34".min_start_date >
                                  temp_today.today
                              AND "Stage34".NSN_Number NOT LIKE 'Level2%');
 

-- 021 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Incomplete Number (First 7)',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                    WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                    AND "Stage34_1072311638_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                    WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                      AND "Stage34_1072311638_Completion".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
            (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                    WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                      AND "Stage34_1072311638_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                         WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                              AND    temp_today.ID = 1072311638
                              AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                              AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                          AND "Stage34_1072311638_Completion".Dev_Is_CC_End_Date IS NULL);

 

-- 022 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Complete Number (First 7)',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                         WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
               AND NOT "Stage34_1072311638_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                         WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                AND NOT "Stage34_1072311638_Completion".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
                          (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                         WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                AND NOT "Stage34_1072311638_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                         WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                   AND NOT "Stage34_1072311638_Completion".Dev_Is_CC_End_Date IS NULL);

 

-- 023 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Incorrect Number (First 7)', 
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Completion".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Completion".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Completion".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Completion".Is_CC_End_Date = '0' );
 

-- 024 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Correct Number (First 7)',
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Completion".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Completion".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Completion".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Completion", temp_today
                     WHERE "Stage34_1072311638_Completion".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Completion".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Completion".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Completion".Is_CC_End_Date = '0' );
 

-- 025 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Incomplete Number (First 7)',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND "Stage34_1072311638_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND "Stage34_1072311638_Part_Cred".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND "Stage34_1072311638_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND "Stage34_1072311638_Part_Cred".Dev_Is_CC_End_Date IS NULL);
 

-- 026 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Complete Number (First 7)',
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "Stage34_1072311638_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "Stage34_1072311638_Part_Cred".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "Stage34_1072311638_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                         WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "Stage34_1072311638_Part_Cred".Dev_Is_CC_End_Date IS NULL);
 

-- 027 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Incorrect Number (First 7)', 
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Part_Cred".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Part_Cred".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Part_Cred".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND "Stage34_1072311638_Part_Cred".Is_CC_End_Date = '0' );
 

-- 028 (INSERT_TempResults) 
 
INSERT INTO "Stage34_1072311638_TRslt"
SELECT 'Partial Correct Number (First 7)',
                    (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Part_Cred".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Part_Cred".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Part_Cred".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "Stage34_1072311638_Part_Cred", temp_today
                     WHERE "Stage34_1072311638_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = 1072311638
                      AND  "Stage34_1072311638_Part_Cred".start_date <
                                  temp_today.today + 14 * 86400000
                      AND  "Stage34_1072311638_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "Stage34_1072311638_Part_Cred".Is_CC_End_Date = '0' );
 

-- 029 (CREATE_Results) 
 
CREATE TABLE "Stage34_1072311638_14_RSLT" AS SELECT * from "Stage34_1072311638_TRslt"; 

-- 030 (INSERT_Results) 
 
INSERT INTO "Stage34_1072311638_14_RSLT"
SELECT 'Raw Completeness %',
       case
       when total.transport_value > 0 then
          (complete.transport_value) /  total.transport_value * 100
       else 100
       end,
       case
       when total.supply_value > 0 then
          (complete.supply_value) / total.supply_value * 100
       else 100
       end,
       case
       when total.project_supply_value > 0 then
          (complete.project_supply_value) / total.project_supply_value * 100
       else 100
       end,
       case
       when total.inventory_value > 0 then
          (complete.inventory_value) / total.inventory_value * 100
       else 100
       end,
       case
       when total.value > 0 then
          (complete.value) / total.value * 100
       else 100
       end
FROM "Stage34_1072311638_TRslt" total,   "Stage34_1072311638_TRslt" complete,
     "Stage34_1072311638_TRslt" correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number';
 

-- 031 (INSERT_Results) 
 
INSERT INTO "Stage34_1072311638_14_RSLT"
SELECT 'Raw Correctness %',
       case
       when complete.transport_value > 0 then
          (correct.transport_value) / 
            complete.transport_value * 100
       when total.transport_value > 0 then 0
       else 100
       end,
       case
       when complete.supply_value > 0 then
          (correct.supply_value) /
              complete.supply_value * 100
       when total.supply_value > 0 then 0
       else 100
       end,
       case
       when complete.project_supply_value > 0 then
          (correct.project_supply_value) /
            complete.project_supply_value * 100
       when total.project_supply_value > 0 then 0
       else 100
       end,
       case
       when complete.inventory_value > 0 then
          (correct.inventory_value) /
            complete.inventory_value * 100
       when total.inventory_value > 0 then 0
       else 100
       end,
       case
       when complete.value > 0 then
          (correct.value) / complete.value * 100
       when total.value > 0 then 0
       else 100
       end
FROM "Stage34_1072311638_TRslt" total,   "Stage34_1072311638_TRslt" complete,
      "Stage34_1072311638_TRslt" correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number';
 

-- 032 (INSERT_Results) 
 
INSERT INTO "Stage34_1072311638_14_RSLT"
SELECT 'Completeness %',
       case
       when total.transport_value > 0 then
          (complete.transport_value + 0.8 * partial_complete.transport_value) / 
            total.transport_value * 100
       else 100
       end,
       case
       when total.supply_value > 0 then
          (complete.supply_value + 0.8 * partial_complete.supply_value) /
              total.supply_value * 100
       else 100
       end,
       case
       when total.project_supply_value > 0 then
          (complete.project_supply_value + 0.8 * partial_complete.project_supply_value) /
            total.project_supply_value * 100
       else 100
       end,
       case
       when total.inventory_value > 0 then
          (complete.inventory_value + 0.8 * partial_complete.inventory_value) /
            total.inventory_value * 100
       else 100
       end,
       case
       when total.value > 0 then
          (complete.value + 0.8 * partial_complete.value) / total.value * 100
       else 100
       end
FROM "Stage34_1072311638_TRslt" total,   "Stage34_1072311638_TRslt" complete,
     "Stage34_1072311638_TRslt" correct, "Stage34_1072311638_TRslt" partial_complete
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number' 
  AND partial_complete.name = 'Partial Complete Number';
 

-- 033 (INSERT_Results) 
 
INSERT INTO "Stage34_1072311638_14_RSLT"
SELECT 'Correctness %',
       case
       when complete.transport_value > 0 then
          (correct.transport_value + 0.8 * partial_correct.transport_value) / 
            complete.transport_value * 100
       when total.transport_value > 0 then 0
       else 100
       end,
       case
       when complete.supply_value > 0 then
          (correct.supply_value + 0.8 * partial_correct.supply_value) /
              complete.supply_value * 100
       when total.supply_value > 0 then 0
       else 100
       end,
       case
       when complete.project_supply_value > 0 then
          (correct.project_supply_value + 0.8 * partial_correct.project_supply_value) /
            complete.project_supply_value * 100
       when total.project_supply_value > 0 then 0
       else 100
       end,
       case
       when complete.inventory_value > 0 then
          (correct.inventory_value + 0.8 * partial_correct.inventory_value) /
            complete.inventory_value * 100
       when total.inventory_value > 0 then 0
       else 100
       end,
       case
       when complete.value > 0 then
          (correct.value + 0.8 * partial_correct.value) / complete.value * 100
       when total.value > 0 then 0
       else 100
       end
FROM "Stage34_1072311638_TRslt" total,   "Stage34_1072311638_TRslt" complete,
     "Stage34_1072311638_TRslt" correct, "Stage34_1072311638_TRslt" partial_correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number'
  AND partial_correct.name = 'Partial Correct Number';
 

-- 034 (INSERT_Results) 
 
INSERT INTO "Stage34_1072311638_14_RSLT"
SELECT '(First 7) Completeness %',
       case
       when total.transport_value > 0 then
          (complete.transport_value + 0.8 * partial_complete.transport_value) / 
            total.transport_value * 100
       else 100
       end,
       NULL,
       NULL,
       NULL,
       case
       when total.value > 0 then
          (complete.value + 0.8 * partial_complete.value) / total.value * 100
       else 100
       end
FROM "Stage34_1072311638_TRslt" total,   "Stage34_1072311638_TRslt" complete,
     "Stage34_1072311638_TRslt" correct, "Stage34_1072311638_TRslt" partial_complete
WHERE total.name    = 'Total Number (First 7)' 
  AND complete.name = 'Complete Number (First 7)'
  AND correct.name  = 'Correct Number (First 7)' 
  AND partial_complete.name = 'Partial Complete Number';
 

-- 035 (INSERT_Results) 
 
INSERT INTO "Stage34_1072311638_14_RSLT"
SELECT '(First 7) Correctness %',
       case
       when complete.transport_value > 0 then
          (correct.transport_value + 0.8 * partial_correct.transport_value) / 
            complete.transport_value * 100
       when total.transport_value > 0 then 0
       else 100
       end,
       NULL,
       NULL,
       NULL,
       case
       when complete.value > 0 then
          (correct.value + 0.8 * partial_correct.value) / complete.value * 100
       when total.transport_value > 0 then 0
       else 100
       end
FROM "Stage34_1072311638_TRslt" complete,"Stage34_1072311638_TRslt" total,
     "Stage34_1072311638_TRslt" correct, "Stage34_1072311638_TRslt" partial_correct
WHERE total.name    = 'Total Number (First 7)' 
  AND complete.name = 'Complete Number (First 7)'
  AND correct.name = 'Correct Number (First 7)'
  AND partial_correct.name = 'Partial Correct Number (First 7)';
 


-- Id: cnccalc,v 1.7 2003/12/16 01:33:47 srivasta Exp . done
