#                               -*- Mode: Sh -*- 
# cctool.sh --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Tue Jul  9 11:14:33 2002
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Jul  9 12:09:46 2002
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 10
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

set -e

progname="`basename \"$0\"`"
pversion='$Revision: 1.1 $'

BASE_LOW='0'
BASE_HIGH='2'
STRESS='3'

DEFAULT_HOST='-h localhost'
DEFAULT_PASSWORD='-p'
DEFAULT_USER='-uroot'
DEFAULT_DATABASE='assesment'

echo testing to see of we have all the log files
for run in $(seq $BASE_LOW $BASE_HIGH) $STRESS; do
    echo "    testing for cheetah.$run.log"
    test -e cheetah.$run.log || exit 2
    echo "    testing for  cougar.$run.log"
    test -e cougar.$run.log || exit 2
    echo ""
done

echo ''
echo Loading base runs
for run in $(seq $BASE_LOW $BASE_HIGH); do
    echo "    Base run number $run"
    ./gendot.pl --run $run --status base \
                cheetah.$run.log  cougar.$run.log > load-$run.sql
done

echo ''
echo Loading stressed case
for run in $STRESS; do
    echo "    Run number $run"
    ./gendot.pl --run $run --status stress --desc '50 percent CPU Load' \
                cheetah.$run.log  cougar.$run.log > load-$run.sql
done

echo ''
echo Now creating the SQL for the  derived table
./gen_deriv.pl > derived.sql

echo ''
echo '# Now run:'
for run in $(seq $BASE_LOW $BASE_HIGH); do
     mysql ${HOST:=DEFAULT_HOST} ${PASSWORD:=DEFAULT_PASSWORD} ${USER:=DEFAULT_USER} ${DATABASE:=DEFAULT_DATABASE} <  load-$run.sql
done
for run in $STRESS; do
     mysql $HOST $PASSWORD $USER $DATABASE  <  load-$run.sql
done

    mysql $HOST $PASSWORD $USER $DATABASE <  derived.sql
