CREATE VIEW rdd as
SELECT DISTINCT tasks.run_id, tasks.id as task_id, tasks.Verb, tasks.agent,
       prep1.val as to_location, prep2.val,
       pref1.bestvalue as end_time, pref2.bestvalue
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND ((tasks.verb       = 'Transport'
        AND prep2.prep       = 'From'
        AND pref2.aspecttype = 'START_TIME' )
       OR
        (tasks.verb       = 'Supply'
         AND prep2.prep       = 'For'
         AND pref2.aspecttype = 'QUANTITY')
       OR
        (tasks.verb       = 'ProjectSupply'
         AND prep2.prep       = 'For'
         AND pref2.aspecttype = 'START_TIME'))
  AND pref1.task_id = tasks.id
  AND pref2.task_id = tasks.id
  AND pref1.aspecttype = 'END_TIME'
  AND prep1.task_id = tasks.id
  AND prep2.task_id = tasks.id
  AND prep1.prep    = 'To'
;


CREATE VIEW transport_rdd as
SELECT DISTINCT tasks.run_id, tasks.id as task_id, tasks.Verb, tasks.agent,
       prep2.val as from_location, prep1.val as to_location,
       pref2.bestvalue as start_time, pref1.bestvalue as end_time
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND pref1.aspecttype = 'END_TIME'
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'START_TIME' 
  AND pref2.task_id    = tasks.id
  AND prep1.prep       = 'To'
  AND prep1.task_id    = tasks.id
  AND prep2.prep       = 'From'
  AND prep2.task_id    = tasks.id
  AND tasks.verb       = 'Transport'
;


CREATE VIEW supply_rdd as
SELECT DISTINCT tasks.run_id, tasks.id as task_id, tasks.Verb, tasks.agent,
       prep1.val as to_location, prep2.val as for_organization,
       pref1.bestvalue as end_time, pref2.bestvalue as quantity
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb       = 'Supply'
  AND pref1.aspecttype = 'END_TIME'
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'QUANTITY'
  AND pref2.task_id    = tasks.id
  AND prep1.prep       = 'To'
  AND prep1.task_id    = tasks.id
  AND prep2.prep       = 'For'
  AND prep2.task_id    = tasks.id
;


CREATE VIEW project_supply_rdd as
SELECT DISTINCT tasks.run_id, tasks.id as task_id, tasks.Verb, tasks.agent,
       prep1.val as to_location, prep2.val as for_organization,
       prep3.val as Maintaining,
       pref2.bestvalue as start_time, pref1.bestvalue as end_time
FROM tasks, preferences pref1, preferences pref2, prepositions prep1,
     prepositions prep2, prepositions prep3
WHERE tasks.run_id in (SELECT min(ID) FROM runs 
                       WHERE runs.type = 'base' 
                         AND runs.ExperimentID = 'Robustness_1')
  AND tasks.verb       = 'ProjectSupply'
  AND pref1.aspecttype = 'END_TIME'
  AND pref1.task_id    = tasks.id
  AND pref2.aspecttype = 'START_TIME'
  AND pref2.task_id    = tasks.id
  AND prep1.prep       = 'To'
  AND prep1.task_id    = tasks.id
  AND prep2.prep       = 'For'
  AND prep2.task_id    = tasks.id
  AND prep3.prep       = 'Maintaining'
  AND prep3.task_id    = tasks.id
;

