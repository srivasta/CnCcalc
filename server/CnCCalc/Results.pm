#                              -*- Mode: Perl -*- 
# Results.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Apr  2 08:35:51 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Feb  2 16:46:36 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 62
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Results;

use strict;
use DBI;
{
  my %Results =
    (
     'Clean' => [qw("XXbaseXX_XXX_TRslt" "XXbaseXX_XXX_Results") ],
      'Tables' => 
      {
      "000_Today" => qq(
CREATE TEMPORARY TABLE TEMP_TODAY AS
SELECT ID, 
       case when Today < 1124082000000 then 1124082000000
       else Today
       end
FROM runs
;),

       "001_CREATE_TempResults" => qq(
CREATE __TEMP__ TABLE "XXbaseXX_XXX_TRslt" (
  NAME                  varchar(255)          default NULL,
  Transport_VALUE        double  precision     default '0.0',
  Supply_VALUE           double  precision     default '0.0',
  Project_Supply_VALUE   double  precision     default '0.0',
  Inventory_VALUE        double  precision     default '0.0',
  VALUE                  double  precision     default '0.0'
);
),
      "002_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Total Number', (SELECT 2 * COUNT(*) FROM "XXbaseXX"
                              WHERE VERB = 'Transport'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 2 * COUNT(*) FROM "XXbaseXX"
                              WHERE VERB = 'Supply'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 3 * COUNT(*) FROM "XXbaseXX"
                              WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 2 * COUNT(*) FROM "XXbaseXX"
                              WHERE VERB = 'Supply'
                              AND NSN_Number NOT LIKE 'Level2%') +
        (SELECT 3 * COUNT(*) FROM "XXbaseXX"
                              WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%'),
         (SELECT 2 * COUNT(*) FROM "XXbaseXX"
                              WHERE NSN_Number NOT LIKE 'Level2%') +
         (SELECT COUNT(*) FROM "XXbaseXX" WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%');
),
      "003_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Incomplete Number',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Rate IS NULL) ;

),
      "004_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Total Number (Stressed)', (SELECT 2 * COUNT(*) FROM "stressed_XXX"
                              WHERE VERB = 'Transport'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 2 * COUNT(*) FROM "stressed_XXX"
                              WHERE VERB = 'Supply'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 3 * COUNT(*) FROM "stressed_XXX"
                              WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%'),
        (SELECT 2 * COUNT(*) FROM "stressed_XXX"
                              WHERE VERB = 'Supply'
                              AND NSN_Number NOT LIKE 'Level2%') +
        (SELECT 3 * COUNT(*) FROM "stressed_XXX"
                              WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%'),
         (SELECT 2 * COUNT(*) FROM "stressed_XXX"
                              WHERE NSN_Number NOT LIKE 'Level2%') +
         (SELECT COUNT(*) FROM "stressed_XXX" WHERE VERB = 'ProjectSupply'
                              AND NSN_Number NOT LIKE 'Level2%');
),
      "005_Update_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incomplete Number';
),
      "006_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Complete Number',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Rate IS NULL);

),
      "007_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Complete Number';
),
      "008_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Incorrect Number', 
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                     WHERE VERB = 'Transport'
                     AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                     WHERE VERB = 'Transport'
                     AND Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' );
),
      "009_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Incorrect Number';

),
      "010_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Correct Number',
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Rate = '0' );
),
      "011_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Correct Number';
),
      "012_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Incomplete Number',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND Dev_Is_CC_Rate IS NULL);
),
      "013_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Incomplete Number';
),
      "014_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Complete Number',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                         WHERE VERB = 'Transport'
                          AND NOT Dev_Is_CC_End_Date IS NULL),
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_QUANTITY IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'Supply'
                               AND NOT Dev_Is_CC_End_Date IS NULL ),
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Start_Date IS NULL) +
         (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_End_Date IS NULL)   +
          (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                               WHERE VERB = 'ProjectSupply'
                               AND NOT Dev_Is_CC_Rate IS NULL);
),
      "015_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Complete Number';
),
      "016_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Incorrect Number', 
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND Is_CC_Rate = '0' );
),
      "017_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Incorrect Number';
),
      "018_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Correct Number',
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                     WHERE VERB = 'Transport'
                     AND NOT Is_CC_End_Date = '0' ),
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_QUANTITY = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                      WHERE VERB = 'Supply'
                      AND NOT Is_CC_End_Date = '0' ),
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_End_Date = '0' )  +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred"
                       WHERE VERB = 'ProjectSupply'
                       AND NOT Is_CC_Rate = '0' );
),
      "019_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET VALUE = Transport_VALUE + Supply_VALUE  + Project_Supply_VALUE
WHERE NAME='Partial Correct Number';
),

      "020_UPDATE_TempResults" => qq(
UPDATE "XXbaseXX_XXX_TRslt"
SET Inventory_VALUE = Supply_VALUE  + Project_Supply_VALUE;
),


      "021_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Total Number (Near Term)',
                      (SELECT 2 * COUNT(*) FROM "XXbaseXX", temp_today
                              WHERE "XXbaseXX".VERB = 'Transport'
                              AND    temp_today.ID = XXX
                              AND "XXbaseXX".min_start_date <
                                  temp_today.today + 21 * 86400000
                              AND "XXbaseXX".min_start_date >
                                  temp_today.today
                              AND "XXbaseXX".NSN_Number NOT LIKE 'Level2%'),
                       NULL,
                       NULL,
                       NULL,
                       (SELECT 2 * COUNT(*) FROM "XXbaseXX", temp_today
                              WHERE "XXbaseXX".VERB = 'Transport'
                              AND    temp_today.ID = XXX
                              AND "XXbaseXX".min_start_date < 
                                  temp_today.today + 21 * 86400000
                              AND "XXbaseXX".min_start_date >
                                  temp_today.today
                              AND "XXbaseXX".NSN_Number NOT LIKE 'Level2%');
),
      "022_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Total Number (Near Term Stressed)',
                      (SELECT 2 * COUNT(*) FROM "stressed_XXX", temp_today
                              WHERE "stressed_XXX".VERB = 'Transport'
                              AND    temp_today.ID = XXX
                              AND "stressed_XXX".start_date <
                                  temp_today.today + 21 * 86400000
                              AND "stressed_XXX".start_date >
                                  temp_today.today
                              AND "stressed_XXX".NSN_Number NOT LIKE 'Level2%'),
                       NULL,
                       NULL,
                       NULL,
                       (SELECT 2 * COUNT(*) FROM "stressed_XXX", temp_today
                              WHERE "stressed_XXX".VERB = 'Transport'
                              AND    temp_today.ID = XXX
                              AND "stressed_XXX".start_date < 
                                  temp_today.today + 21 * 86400000
                              AND "stressed_XXX".start_date >
                                  temp_today.today
                              AND "stressed_XXX".NSN_Number NOT LIKE 'Level2%');
),

      "023_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Incomplete Number (Near Term)',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                    WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                    AND "XXbaseXX_XXX_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                    WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                      AND "XXbaseXX_XXX_Completion".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
            (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                    WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                      AND "XXbaseXX_XXX_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                         WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                              AND    temp_today.ID = XXX
                              AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                              AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                          AND "XXbaseXX_XXX_Completion".Dev_Is_CC_End_Date IS NULL);

),
      "024_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Complete Number (Near Term)',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                         WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
               AND NOT "XXbaseXX_XXX_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                         WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                AND NOT "XXbaseXX_XXX_Completion".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
                          (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                         WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                AND NOT "XXbaseXX_XXX_Completion".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                         WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                   AND NOT "XXbaseXX_XXX_Completion".Dev_Is_CC_End_Date IS NULL);

),

      "025_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Incorrect Number (Near Term)', 
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Completion".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Completion".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Completion".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Completion".Is_CC_End_Date = '0' );
),
      "026_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Correct Number (Near Term)',
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Completion".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Completion".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Completion".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Completion", temp_today
                     WHERE "XXbaseXX_XXX_Completion".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Completion".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Completion".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Completion".Is_CC_End_Date = '0' );
),

      "027_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Incomplete Number (Near Term)',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_End_Date IS NULL);
),
      "028_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Complete Number (Near Term)',
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_End_Date IS NULL),
                               NULL,
                               NULL,
                               NULL,
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_Start_Date IS NULL) +
        (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                         WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                          AND NOT "XXbaseXX_XXX_Part_Cred".Dev_Is_CC_End_Date IS NULL);
),

      "029_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Incorrect Number (Near Term)', 
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Part_Cred".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Part_Cred".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Part_Cred".Is_CC_Start_Date = '0') +
                      (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND "XXbaseXX_XXX_Part_Cred".Is_CC_End_Date = '0' );
),

      "030_INSERT_TempResults" => qq(
INSERT INTO "XXbaseXX_XXX_TRslt"
SELECT 'Partial Correct Number (Near Term)',
                    (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Part_Cred".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Part_Cred".Is_CC_End_Date = '0' ),
                               NULL,
                               NULL,
                               NULL,
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Part_Cred".Is_CC_Start_Date = '0') +
                     (SELECT COUNT(*) FROM "XXbaseXX_XXX_Part_Cred", temp_today
                     WHERE "XXbaseXX_XXX_Part_Cred".VERB = 'Transport'
                      AND    temp_today.ID = XXX
                      AND  "XXbaseXX_XXX_Part_Cred".start_date <
                                  temp_today.today + 21 * 86400000
                      AND  "XXbaseXX_XXX_Part_Cred".start_date >
                                  temp_today.today
                     AND NOT "XXbaseXX_XXX_Part_Cred".Is_CC_End_Date = '0' );
),





      "031_CREATE_Results" => qq(
CREATE TABLE "XXbaseXX_XXX_Results" AS SELECT * from "XXbaseXX_XXX_TRslt";),

      "032_INSERT_Results" => qq(
INSERT INTO "XXbaseXX_XXX_Results"
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
FROM "XXbaseXX_XXX_TRslt" total,   "XXbaseXX_XXX_TRslt" complete,
     "XXbaseXX_XXX_TRslt" correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number';
),
      "033_INSERT_Results" => qq(
INSERT INTO "XXbaseXX_XXX_Results"
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
FROM "XXbaseXX_XXX_TRslt" total,   "XXbaseXX_XXX_TRslt" complete,
      "XXbaseXX_XXX_TRslt" correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number';
),
      "034_INSERT_Results" => qq(
INSERT INTO "XXbaseXX_XXX_Results"
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
FROM "XXbaseXX_XXX_TRslt" total,   "XXbaseXX_XXX_TRslt" complete,
     "XXbaseXX_XXX_TRslt" correct, "XXbaseXX_XXX_TRslt" partial_complete
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number' 
  AND partial_complete.name = 'Partial Complete Number';
),
      "035_INSERT_Results" => qq(
INSERT INTO "XXbaseXX_XXX_Results"
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
FROM "XXbaseXX_XXX_TRslt" total,   "XXbaseXX_XXX_TRslt" complete,
     "XXbaseXX_XXX_TRslt" correct, "XXbaseXX_XXX_TRslt" partial_correct
WHERE total.name = 'Total Number' and complete.name = 'Complete Number'
  AND correct.name = 'Correct Number'
  AND partial_correct.name = 'Partial Correct Number';
),
      "036_INSERT_Results" => qq(
INSERT INTO "XXbaseXX_XXX_Results"
SELECT '(Near Term) Completeness %',
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
FROM "XXbaseXX_XXX_TRslt" total,   "XXbaseXX_XXX_TRslt" complete,
     "XXbaseXX_XXX_TRslt" correct, "XXbaseXX_XXX_TRslt" partial_complete
WHERE total.name    = 'Total Number (Near Term)' 
  AND complete.name = 'Complete Number (Near Term)'
  AND correct.name  = 'Correct Number (Near Term)' 
  AND partial_complete.name = 'Partial Complete Number';
),
      "037_INSERT_Results" => qq(
INSERT INTO "XXbaseXX_XXX_Results"
SELECT '(Near Term) Correctness %',
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
FROM "XXbaseXX_XXX_TRslt" complete,"XXbaseXX_XXX_TRslt" total,
     "XXbaseXX_XXX_TRslt" correct, "XXbaseXX_XXX_TRslt" partial_correct
WHERE total.name    = 'Total Number (Near Term)' 
  AND complete.name = 'Complete Number (Near Term)'
  AND correct.name = 'Correct Number (Near Term)'
  AND partial_correct.name = 'Partial Correct Number (Near Term)';
), 
    },
);

  for my $datum (keys %Results ) {
    no strict "refs";
    *$datum = sub {
      use strict "refs";
      my ($self, $newvalue) = @_;
      $Results{$datum} = $newvalue if @_ > 1;
      return $Results{$datum};
    }
  }
}

sub new{
  my $this = shift;
  my %params = @_;
  my $class = ref($this) || $this;
  my $self = {};
  warn "New CnCCalc::Results object" if $::ConfOpts{'TRACE_SUBS'};

  bless $self, $class;

  $self->{' _Debug'} = 0;
  return $self;
}

sub create_tables() {
  my $self = shift;
  my %params = @_;

  warn "CnCCalc::Results::create_tables" if $::ConfOpts{'TRACE_SUBS'};
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
	  $return_code = $dbh->err;
	  my $err = $dbh->errstr;
	  warn "Could not commit data ($err)";
	}
	$body .= qq(<li>Dropped table $drop_table</li>\n);
      }
    }
  }

  my $err;
  for my $table_id (sort keys %{ $hashref }) {
    my ($table) = $table_id =~ /^\d\d\d_(\S+)/;
    my ($count) = $table_id =~ /^(\d\d\d)/;
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
    warn "$now_string: doing instruction $count";
    eval {
      $retval = $dbh->do($instruction);
    };
    if ($@) {
      warn "Instruction number $count failed.";
      warn "undef value returned" unless defined $retval;
      $err = $dbh->errstr;
      warn "$err";
      $body .= "Failed instruction number $count($table).<br>$@<br></li>\n";
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
      } else {
	warn "Committed changes\n";
      }
      $body .= qq(<li>Instruction $count($table) done</li>\n);
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

  warn "CnCCalc::Results::dump" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'Baseline Name' missing"
    unless defined $params{'Baseline Name'};
  die "Required parameter 'Stressed RunID' missing"
    unless defined $params{'Stressed RunID'};

  my $hashref = $self->Tables();
  my $body = "";

  for my $table_id (sort keys %{ $hashref }) {
    my ($table) = $table_id =~ /^\d\d\d_(\S+)/;
    my ($count) = $table_id =~ /^(\d\d\d)/;
    ## We have drop table commands, so we do not check to see if the
    ## table exists. This allows us to interleave commands into the
    ## initialization steps.
    # next if $::ConfOpts{'HaveTable'}{$table};
    my $instruction = $hashref->{$table_id};
    $instruction =~ s/XXbaseXX/$params{'Baseline Name'}/g;
    $instruction =~ s/XXX/$params{'Stressed RunID'}/g;
    $instruction =~ s/__TEMP__/TEMPORARY/g;
    $body .= qq(-- $count ($table) \n );
    $body .= qq($instruction \n\n);
  }
  $body .= "\n";
  return $body;
}




1;

__END__;
