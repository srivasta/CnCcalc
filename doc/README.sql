######################################################################
#### Quick and dirty method for analyzing data dumped by the CnCcalc
#### root only logging plugin:
######################################################################

cat vacuum.sql rdd_ro.sql baseline_ro.sql stressed_ro.sql completion.sql \
    results.sql | psql -a [-h <hostname>] [-U <user>] [-p] <database>

######################################################################
#### Quick and dirty method for analyzing data from a full dump for
#### the CnCcalc delayed logging plugin
######################################################################

cat vacuum.sql rdd.sql baseline.sql stressed.sql completion.sql \
    results.sql | psql -a [-h <hostname>] [-U <user>] [-p] <database>


######################################################################
####                  Detailed instructions:
####       Creating a new database and loading data
######################################################################

# If you already have data loggied into a database by the CnCcalc
# plugins, you can skip this section.

# There a re a number of ways we can start with a clean data base. We
# can either drop and create the whole database, like so:
echo 'drop database rootonly;' | psql -a -U postgres template1
createdb rootonly

# Tne name of the database can be anything you desire. Of course, this
# assumes that you have the priviledges to create new databases. If
# that is not te case, we can try dropping individual tables:
: psql -a -U postgres rootonly2 < /path/to/scripts/drop.sql

# Next, we create all the tables needed 
psql -a -U postgres rootonly2 < /path/to/scripts/create.sql

# Now comes the load: you may need to edit the path to data in the
# following script:
psql -a -U postgres rootonly2 < /path/to/scripts/load.sql

######################################################################
####       Analyzing data
######################################################################

# First, the RDD views:
psql -a -U postgres rootonly2 < /path/to/scripts/rdd.sql

# We now start the analysis. There are two sets of scripts,
# corresponding to the data gathered by the full delayed logging
# plugin, and the second set for the data gathered by the root tasks
# plugin (the former has a test to select only the root task set)


# Then come the base line tables
psql -a -U postgres rootonly2 < /path/to/scripts/baseline_ro.sql
# or 
psql -a -U postgres rootonly2 < /path/to/scripts/baseline.sql

# Digest the stressed runs
psql -a -U postgres rootonly2 < /path/to/scripts/stressed_ro.sql
# or
psql -a -U postgres rootonly2 < /path/to/scripts/stressed.sql


######################################################################
####                  Results
######################################################################

# The completion table
psql -a -U postgres rootonly2 < /path/to/scripts/completion.sql

# And finally, the summary results table
psql -a -U postgres rootonly2 < /path/to/scripts/results.sql
