#!/bin/bash
#                               -*- Mode: Sh -*- 
# load_new_db.sh --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Dec 11 08:18:28 2002
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Dec 11 08:47:37 2002
# Last Machine Used: ember.green-gryphon.com
# Update Count     : 8
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

set -e

DUMP_DIR=/mnt/archive/JTG
TEMP_DIR=/mnt/archive/tmp_data

WORKDIR=$HOME/analysis_data

DATABASE=current
PGHOST=localhost
PGUSER=postgres


if [ ! -d $DUMP_DIR ]; then
    echo "Could not find dump dir"
    exit 2
fi


if [ ! -d $TEMP_DIR ]; then
    echo "Could not find temp dir"
    exit 2
fi
if [ ! -d $WORKDIR ]; then
    echo "Could not find work dir"
    exit 2
fi

latest_dump=$(ls -1tr $DUMP_DIR/JTG-*/CnCCalcDBDump.*.tgz | tail -1)
dump_filename=$(echo $latest_dump | sed -e 's,.*/,,')

cp $latest_dump $TEMP_DIR 
gunzip $TEMP_DIR/$dump_filename


database=$TEMP_DIR/${dump_filename%%tgz}tar

if [ ! -e $database ]; then
    echo "Can not find uncompressed database"
    exit 3
fi

echo "drop   database $DATABASE;"        | psql -U $PGUSER -h $PGHOST template1
echo "drop   database ${DATABASE}_exec;" | psql -U $PGUSER -h $PGHOST template1
echo "create database $DATABASE;"        | psql -U $PGUSER -h $PGHOST template1
echo "create database ${DATABASE}_exec;" | psql -U $PGUSER -h $PGHOST template1

if [ -e $WORKDIR/baseline.sql ]; then
    psql -a -U $PGUSER -h $PGHOST $DATABASE < $WORKDIR/baseline.sql
fi

if [ -e $WORKDIR/exec_baseline.sql ]; then
    psql -a -U $PGUSER -h $PGHOST ${DATABASE}_exec < $WORKDIR/exec_baseline.sql
fi

pg_restore -U $PGUSER -h $PGHOST  -v -d $DATABASE       $database
pg_restore -U $PGUSER -h $PGHOST  -v -d {DATABASE}_exec $database
