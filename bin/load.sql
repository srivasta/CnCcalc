COPY runs FROM '/home/srivasta/data/02/runs.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY tasks FROM '/home/srivasta/data/02/tasks.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY mp_tasks FROM '/home/srivasta/data/02/mp_tasks.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY task_parent FROM '/home/srivasta/data/02/task_parent.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY typepg FROM '/home/srivasta/data/02/typepg.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY itempg FROM '/home/srivasta/data/02/itempg.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY assets FROM '/home/srivasta/data/02/assets.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
-- COPY task_asset FROM '/home/srivasta/data/02/task_asset.txt' 
--   USING DELIMITERS '|' WITH NULL AS '\\N';
COPY preferences FROM '/home/srivasta/data/02/preferences.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY prepositions FROM '/home/srivasta/data/02/prepositions.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY planelements FROM '/home/srivasta/data/02/planelements.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY allocation_results FROM '/home/srivasta/data/02/allocation_results.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY consolidated_aspects FROM '/home/srivasta/data/02/consolidated_aspects.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY phased_aspects FROM '/home/srivasta/data/02/phased_aspects.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
COPY phased_aspect_values FROM '/home/srivasta/data/02/phased_aspect_values.txt' 
  USING DELIMITERS '|' WITH NULL AS '\\N';
