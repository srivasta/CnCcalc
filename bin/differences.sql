DROP TABLE  Root_1;
CREATE TABLE Root_1 (
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Count                 integer                default '1'
);

DROP TABLE  Root_2;
CREATE TABLE Root_2 (
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Count                 integer                default '1'
);

DROP TABLE  Root_3;
CREATE TABLE Root_3 (
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Count                 integer                default '1'
);

INSERT INTO Root_1 (Agent, Verb, NSN_Number, From_Location, To_Location,
                      Preferred_Start_Date, Preferred_End_Date, Count)
SELECT tasks.agent, tasks.Verb,  assets.typepg_id  as NSN_Number,
       prep2.val as From_Location, prep1.val as To_Location,
       pref2.bestvalue as Preferred_Start_Date, 
       pref1.bestvalue as Preferred_End_Date, '1'
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, task_asset, assets
WHERE tasks.run_id = '1'
  AND tasks.parent_id in (SELECT id FROM tasks 
                         WHERE verb = 'DetermineRequirements')
  AND tasks.verb       	       = 'Transport'
  AND prep1.prep       	       = 'To'
  AND prep1.task_id    	       = tasks.id
  AND prep2.prep       	       = 'From'
  AND prep2.task_id    	       = tasks.id
  AND pref1.aspecttype 	       = 'END_TIME'
  AND pref1.task_id    	       = tasks.id
  AND pref2.aspecttype 	       = 'START_TIME' 
  AND pref2.task_id    	       = tasks.id
  AND task_asset.task_id       = tasks.id
  AND task_asset.asset_id      = assets.id;

INSERT INTO Root_2 (Agent, Verb, NSN_Number, From_Location, To_Location,
                      Preferred_Start_Date, Preferred_End_Date, Count)
SELECT tasks.agent, tasks.Verb,  assets.typepg_id  as NSN_Number,
       prep2.val as From_Location, prep1.val as To_Location,
       pref2.bestvalue as Preferred_Start_Date, 
       pref1.bestvalue as Preferred_End_Date, '1'
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, task_asset, assets
WHERE tasks.run_id = '2'
  AND tasks.parent_id in (SELECT id FROM tasks 
                         WHERE verb = 'DetermineRequirements')
  AND tasks.verb       	       = 'Transport'
  AND prep1.prep       	       = 'To'
  AND prep1.task_id    	       = tasks.id
  AND prep2.prep       	       = 'From'
  AND prep2.task_id    	       = tasks.id
  AND pref1.aspecttype 	       = 'END_TIME'
  AND pref1.task_id    	       = tasks.id
  AND pref2.aspecttype 	       = 'START_TIME' 
  AND pref2.task_id    	       = tasks.id
  AND task_asset.task_id       = tasks.id
  AND task_asset.asset_id      = assets.id;

INSERT INTO Root_3 (Agent, Verb, NSN_Number, From_Location, To_Location,
                      Preferred_Start_Date, Preferred_End_Date, Count)
SELECT tasks.agent, tasks.Verb,  assets.typepg_id  as NSN_Number,
       prep2.val as From_Location, prep1.val as To_Location,
       pref2.bestvalue as Preferred_Start_Date, 
       pref1.bestvalue as Preferred_End_Date, '1'
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, task_asset, assets
WHERE tasks.run_id = '3'
  AND tasks.parent_id in (SELECT id FROM tasks 
                         WHERE verb = 'DetermineRequirements')
  AND tasks.verb       	       = 'Transport'
  AND prep1.prep       	       = 'To'
  AND prep1.task_id    	       = tasks.id
  AND prep2.prep       	       = 'From'
  AND prep2.task_id    	       = tasks.id
  AND pref1.aspecttype 	       = 'END_TIME'
  AND pref1.task_id    	       = tasks.id
  AND pref2.aspecttype 	       = 'START_TIME' 
  AND pref2.task_id    	       = tasks.id
  AND task_asset.task_id       = tasks.id
  AND task_asset.asset_id      = assets.id;

-- INSERT INTO Root_1 (Agent, Verb, NSN_Number, For_Organization, 
--                            To_Location, Preferred_Quantity,
--                            Preferred_End_Date)
-- SELECT tasks.agent, tasks.Verb, assets.typepg_id  as NSN_Number,
--        prep2.val as For_Organization, prep1.val as To_Location, 
--        pref2.bestvalue as Preferred_Quantity,
--        pref1.bestvalue as Preferred_End_Date
-- FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
--      prepositions prep2, task_asset, assets
-- WHERE tasks.run_id = '1'
--   AND tasks.parent_id in (SELECT id FROM tasks
--                                WHERE verb = 'GenerateProjections')
--   AND tasks.verb       = 'Supply'
--   AND prep1.prep       = 'To'
--   AND prep1.task_id    = tasks.id
--   AND prep2.prep       = 'For'
--   AND prep2.task_id    = tasks.id
--   AND pref1.aspecttype = 'END_TIME'
--   AND pref1.task_id    = tasks.id
--   AND pref2.aspecttype = 'QUANTITY'
--   AND pref2.task_id    = tasks.id
--   AND task_asset.task_id       = tasks.id
--   AND task_asset.asset_id      = assets.id;

INSERT INTO Root_1 (Agent, Verb, NSN_Number, For_Organization, 
                    To_Location, Preferred_Start_Date,
                    Preferred_End_Date, Count)
SELECT tasks.agent, tasks.Verb, assets.typepg_id  as NSN_Number,
       prep2.val as For_Organization, prep1.val as To_Location, 
       pref2.bestvalue as Preferred_Start_Date, 
       pref1.bestvalue as Preferred_End_Date, '1'
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, task_asset, assets
WHERE tasks.run_id = '1'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'ProjectSupply'
  AND prep1.prep       = 'To'
  AND prep1.task_id    = tasks.id
  AND prep2.prep       = 'For'
  AND prep2.task_id    = tasks.id
  AND pref1.aspecttype = 'END_TIME'
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'START_TIME'
  AND pref2.task_id    = tasks.id
  AND task_asset.task_id       = tasks.id
  AND task_asset.asset_id      = assets.id;

INSERT INTO Root_2 (Agent, Verb, NSN_Number, For_Organization, 
                    To_Location, Preferred_Start_Date,
                    Preferred_End_Date, Count)
SELECT tasks.agent, tasks.Verb, assets.typepg_id  as NSN_Number,
       prep2.val as For_Organization, prep1.val as To_Location, 
       pref2.bestvalue as Preferred_Start_Date, 
       pref1.bestvalue as Preferred_End_Date, '1'
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, task_asset, assets
WHERE tasks.run_id = '2'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'ProjectSupply'
  AND prep1.prep       = 'To'
  AND prep1.task_id    = tasks.id
  AND prep2.prep       = 'For'
  AND prep2.task_id    = tasks.id
  AND pref1.aspecttype = 'END_TIME'
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'START_TIME'
  AND pref2.task_id    = tasks.id
  AND task_asset.task_id       = tasks.id
  AND task_asset.asset_id      = assets.id;

INSERT INTO Root_3 (Agent, Verb, NSN_Number, For_Organization, 
                    To_Location, Preferred_Start_Date,
                    Preferred_End_Date, Count)
SELECT tasks.agent, tasks.Verb, assets.typepg_id  as NSN_Number,
       prep2.val as For_Organization, prep1.val as To_Location, 
       pref2.bestvalue as Preferred_Start_Date, 
       pref1.bestvalue as Preferred_End_Date, '1'
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, task_asset, assets
WHERE tasks.run_id = '3'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'ProjectSupply'
  AND prep1.prep       = 'To'
  AND prep1.task_id    = tasks.id
  AND prep2.prep       = 'For'
  AND prep2.task_id    = tasks.id
  AND pref1.aspecttype = 'END_TIME'
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'START_TIME'
  AND pref2.task_id    = tasks.id
  AND task_asset.task_id       = tasks.id
  AND task_asset.asset_id      = assets.id;


----------------------------------------------------------------------
DROP TABLE  Squished_Root_1;
CREATE TABLE Squished_Root_1 (
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Count                 integer                default '1'
);

DROP TABLE  Squished_Root_2;
CREATE TABLE Squished_Root_2 (
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Count                 integer                default '1'
);

DROP TABLE  Squished_Root_3;
CREATE TABLE Squished_Root_3 (
  Agent                 varchar(63) NOT NULL default '',
  Verb                  varchar(31) NOT NULL default '',
  NSN_Number            varchar(63)          default NULL,
  From_Location         varchar(63)          default NULL,
  For_Organization      varchar(63)          default NULL,
  To_Location           varchar(63)          default NULL,
  Preferred_Quantity    double precision                default NULL,
  Preferred_Start_Date  double precision              default NULL,
  Preferred_End_Date    double precision              default NULL,
  Count                 integer                default '1'
);

INSERT INTO Squished_Root_1 (Agent, Verb, NSN_Number, From_Location,
                             To_Location, Preferred_Start_Date,
                             Preferred_End_Date, Count)
SELECT Root.agent, Root.Verb,  Root.NSN_Number,
       Root.From_Location, Root.To_Location,
       Root.Preferred_Start_Date, Root.Preferred_End_Date,
       sum(Root.Count)
FROM Root_1 Root
WHERE Root.verb       	       = 'Transport'
GROUP BY agent, Verb, NSN_Number, From_Location, To_Location,
         Preferred_Start_Date, Preferred_End_Date;

INSERT INTO Squished_Root_2 (Agent, Verb, NSN_Number, From_Location,
                             To_Location, Preferred_Start_Date,
                             Preferred_End_Date, Count)
SELECT Root.agent, Root.Verb,  Root.NSN_Number,
       Root.From_Location, Root.To_Location,
       Root.Preferred_Start_Date, Root.Preferred_End_Date,
       sum(Root.Count)
FROM Root_2 Root
WHERE Root.verb       	       = 'Transport'
GROUP BY agent, Verb, NSN_Number, From_Location, To_Location,
         Preferred_Start_Date, Preferred_End_Date;

INSERT INTO Squished_Root_3 (Agent, Verb, NSN_Number, From_Location,
                             To_Location, Preferred_Start_Date,
                             Preferred_End_Date, Count)
SELECT Root.agent, Root.Verb,  Root.NSN_Number,
       Root.From_Location, Root.To_Location,
       Root.Preferred_Start_Date, Root.Preferred_End_Date,
       sum(Root.Count)
FROM Root_3 Root
WHERE Root.verb       	       = 'Transport'
GROUP BY agent, Verb, NSN_Number, From_Location, To_Location,
         Preferred_Start_Date, Preferred_End_Date;


INSERT INTO Squished_Root_1 (Agent, Verb, NSN_Number, For_Organization, 
                             To_Location, Preferred_Start_Date,
                             Preferred_End_Date, Count)
SELECT Root.agent, Root.Verb, Root.NSN_Number,
       Root.For_Organization, Root.To_Location,
       Root.Preferred_Start_Date, Root.Preferred_End_Date,
       sum(Root.Count)
FROM Root_1 Root
WHERE Root.verb       	       = 'ProjectSupply'
GROUP BY agent, Verb, NSN_Number, For_Organization, To_Location,
           Preferred_Start_Date,  Preferred_End_Date;

INSERT INTO Squished_Root_2 (Agent, Verb, NSN_Number, For_Organization, 
                             To_Location, Preferred_Start_Date,
                             Preferred_End_Date, Count)
SELECT Root.agent, Root.Verb, Root.NSN_Number,
       Root.For_Organization, Root.To_Location,
       Root.Preferred_Start_Date, Root.Preferred_End_Date,
       sum(Root.Count)
FROM Root_2 Root
WHERE Root.verb       	       = 'ProjectSupply'
GROUP BY agent, Verb, NSN_Number, For_Organization, To_Location,
           Preferred_Start_Date,  Preferred_End_Date;


INSERT INTO Squished_Root_3 (Agent, Verb, NSN_Number, For_Organization, 
                             To_Location, Preferred_Start_Date,
                             Preferred_End_Date, Count)
SELECT Root.agent, Root.Verb, Root.NSN_Number,
       Root.For_Organization, Root.To_Location,
       Root.Preferred_Start_Date, Root.Preferred_End_Date,
       sum(Root.Count)
FROM Root_3 Root
WHERE Root.verb       	       = 'ProjectSupply'
GROUP BY agent, Verb, NSN_Number, For_Organization, To_Location,
           Preferred_Start_Date,  Preferred_End_Date;
