
SELECT count(*)
FROM tasks
WHERE tasks.run_id = '1'
  AND tasks.parent_id in (SELECT id FROM tasks 
                         WHERE verb = 'DetermineRequirements')
  AND tasks.verb       	       = 'Transport';
SELECT count(*)
FROM tasks
WHERE tasks.run_id = '2'
  AND tasks.parent_id in (SELECT id FROM tasks 
                         WHERE verb = 'DetermineRequirements')
  AND tasks.verb       	       = 'Transport';
SELECT count(*)
FROM tasks
WHERE tasks.run_id = '3'
  AND tasks.parent_id in (SELECT id FROM tasks 
                         WHERE verb = 'DetermineRequirements')
  AND tasks.verb       	       = 'Transport';

SELECT count(*)
FROM tasks
WHERE tasks.run_id = '1'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'Supply';

SELECT count(*)
FROM tasks
WHERE tasks.run_id = '2'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'Supply';

SELECT count(*)
FROM tasks
WHERE tasks.run_id = '3'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'Supply';

SELECT count(*)
FROM tasks
WHERE tasks.run_id = '1'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'ProjectSupply';

SELECT count(*)
FROM tasks
WHERE tasks.run_id = '2'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'ProjectSupply';

SELECT count(*)
FROM tasks
WHERE tasks.run_id = '3'
  AND tasks.parent_id in (SELECT id FROM tasks
                               WHERE verb = 'GenerateProjections')
  AND tasks.verb       = 'ProjectSupply';

select count(*) from baseline where verb = 'Transport';
select count(*) from baseline where verb = 'Supply';
select count(*) from baseline where verb = 'ProjectSupply';