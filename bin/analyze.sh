#!/bin/bash 
#                               -*- Mode: Sh -*- 
# analyze.sh --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Sun Oct 27 23:38:06 2002
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Fri Dec 13 14:51:36 2002
# Last Machine Used: ember.green-gryphon.com
# Update Count     : 66
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

set -e

DATABASE=cnccalc
PGHOST=localhost
PGUSER=postgres


progname="`basename \"$0\"`"
pversion=' $Revision: 1.11 $ '

setq() {
    # Variable Value Doc string
    if [ "x$2" = "x" ]; then
        echo >&2 "$progname: Unable to determine $3"
        exit 1;
    else
        if [ ! "x$Verbose" = "x" ]; then
            echo "$progname: $3 is $2";
        fi
        eval "$1=\"\$2\"";
    fi
}

withecho () {
        echo " $@" >&2
        "$@"
}


usageversion () {
        cat >&2 <<END
$progname $pversion.

Usage: $progname  [options] stress_run_id
Options: 
 -h           This help
 -H<hostname> Set host to <hostnamename>                
 -U<user>     Use <user> instead of postgres            
 -C<path>     Look for the sql files in <path>, instead of 
              \$COUGAAR_INSTALL_PATH/assesment/bin      
 -b<id>       Append to the list of baseline runs. Can be used multiple
              times to add to the list of baseline runs. If, and only
              if, this list is empty, we shall use the runs labelled
              base in the runs table in the database shall be used.
 -d<database> Use database <database> instead of cnccalc
 -s           Only do the stressed run analysis (Assumes that the baseline
                                                 table exists)
 -n           "Dry-run" mode - No action taken, only print commands.
 -v           make the command verbose

Assumptions:
 1) All base runs have finished fine (status = 100, status = 55 means
    an aborted run)
 2) The baseline tables are recalculated for every stress run, in case
    the runs table has been modified since the last tie the baseline
    runs were calculated, unless the -s option is given.

END
}

# The defaults
docmd='YES'
action='withecho'
DEBUG=0
VERBOSE=0

TAGOPT=

# Command line
TEMP=$(getopt -a -s bash -o hC:H:U:d:sb:nv -n 'analyze.sh' -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi


# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"


# Command line
while true ; do
    case "$1" in
        -h)   usageversion;  exit 0      ; shift   ;;
        -H)   PGHOST="$2"                ; shift 2 ;;
        -U)   PGUSER="$2"                ; shift 2 ;;
        -C)   OPT_INSTALL_PATH="$2"      ; shift 2 ;;
        -d)   DATABASE="$2"              ; shift 2 ;;
        -s)   STRESSED_ONLY='YES'        ; shift   ;;
	-b)   baseline_runs=("${baseline_runs[@]}" "$2") ; shift 2 ;;
        -n)   action='echo';docmd='NO'   ; shift   ;;
        -v)   VERBOSE=1                  ; shift   ;;
        --)      shift ; break ;;
        *) echo >&2 "Internal error!($1)"
            usageversion; exit 1           ;;
    esac
done

set +e
if [ "X$docmd" = "XYES" ]; then
    echo 'select count(*) from runs;' | \
      psql -U $PGUSER -h $PGHOST $DATABASE > /dev/null 2>&1 \
        || echo '**ERROR** PostreSQL error. Please Correct the following errors'
    set -e
    echo 'select count(*) from runs;' | \
      psql -U $PGUSER -h $PGHOST $DATABASE 
else
    echo 'select count(*) from runs;' \| \
      psql -U $PGUSER -h $PGHOST $DATABASE \> /dev/null '2>&1'
fi
set -e


for arg in ${1+"$@"}; do
    stressed_runs=("${stressed_runs[@]}" "$arg") ;
done


if [ "X$OPT_INSTALL_PATH" = "X" ]; then
    if [ "X$COUGAAR_INSTALL_PATH" = "X" ]; then
	if [ -e $HOME/bin/stressed_ro.sql  ]; then
	    INSTALL_PATH=$HOME/bin
	else
	    echo $progname $pversion : COUGAAR_INSTALL_PATH not set. Aborting
	    if [ "X$docmd" = "XYES" ]; then
		exit 1;
	    fi
	fi
    else
	INSTALL_PATH=$COUGAAR_INSTALL_PATH/assesment/bin
    fi
else
    INSTALL_PATH=$OPT_INSTALL_PATH
fi

if [ -z "${stressed_runs[*]}" ]; then
    if [ -z "${baseline_runs[*]}" ]; then
	echo Using  baseline ids in the database
    else
	 echo using baseline id ${baseline_runs[@]}
    fi
else
    if [ -n "${baseline_runs[*]}"  ]; then
	echo using baseline id ${baseline_runs[@]}
    fi
    echo using stressed id ${stressed_runs[@]}
fi

if [ ! -e $INSTALL_PATH/baseline_ro.sql ]; then
    echo $progname $pversion : Could not find baseline_ro.sql. Aborting
    if [ "X$docmd" = "XYES" ]; then
	exit 1;
    fi
fi
if [ ! -e $INSTALL_PATH/stressed_ro.sql ]; then
    echo $progname $pversion : Could not find stressed_ro.sql. Aborting
    if [ "X$docmd" = "XYES" ]; then
	exit 1;
    fi
fi
if [ ! -e $INSTALL_PATH/completion.sql ]; then
    echo $progname $pversion : Could not find completion.sql. Aborting
    if [ "X$docmd" = "XYES" ]; then
	exit 1;
    fi
fi


if [ "X$STRESSED_ONLY" = "X" ]; then
    if [ "X$VERBOSE" = "XYES" ]; then
	echo "Prepare for the Baseline analysis."
    fi
    if [ -n "${baseline_runs[*]}"  ]; then
	for BASE in ${baseline_runs[@]}; do
	    if [ "X$base_Range" = "X" ]; then
		base_Range="$BASE"
	    else
		base_Range="$base_Range, $BASE"
	    fi
	done
	if [ "X$docmd" = "XYES" ]; then
	date --utc
	date --utc >> $$.log
	    echo "update runs set experimentid = 'Robustness_1' where id in ($base_Range);" 
	    echo "update runs set experimentid = 'Robustness_1' where id in ($base_Range);" \
		| psql -a -U $PGUSER -h $PGHOST $DATABASE >> $$.log    
	else
	date --utc
	date --utc >> $$.log
	    echo "update runs set experimentid = 'Robustness_1' where id in ($base_Range);" 
	    echo "update runs set experimentid = 'Robustness_1' where id in ($base_Range);" \
		\| psql -a -U $PGUSER -h $PGHOST $DATABASE   \> $$.log     
	fi
    else
	if [ "X$docmd" = "XYES" ]; then
	date --utc
	date --utc >> $$.log
	    echo "update runs set experimentid = 'Robustness_1' where type = 'base' and status = 100;" 
	    echo "update runs set experimentid = 'Robustness_1' where type = 'base' and status = 100;" \
		| psql -a -U $PGUSER -h $PGHOST $DATABASE >> $$.log    
	else
	date --utc
	date --utc >> $$.log
	    echo "update runs set experimentid = 'Robustness_1' where type = 'base' and status = 100;" 
	    echo "update runs set experimentid = 'Robustness_1' where type = 'base' and status = 100;" \
		\| psql -a -U $PGUSER -h $PGHOST $DATABASE   \> $$.log     
	fi
    fi
fi



if [ "X$STRESSED_ONLY" = "X" ]; then
    if [ "X$VERBOSE" = "XYES" ]; then
	echo "Run the Baseline analysis."
	date --utc
	date --utc >> $$.log
    fi
    if [ "X$docmd" = "XYES" ]; then
	psql -a -U $PGUSER -h $PGHOST $DATABASE < $INSTALL_PATH/baseline_ro.sql >> $$.log
    else
	echo psql -a -U $PGUSER -h $PGHOST $DATABASE \< $INSTALL_PATH/baseline_ro.sql \>\> $$.log
    fi
	date --utc
	date --utc >> $$.log
fi



if [ -n "${stressed_runs[*]}" ]; then
    for STRESS in ${stressed_runs[@]}; do
	if [ "X$VERBOSE" = "XYES" ]; then
	    echo "Starting to deal with $STRESS."
	fi
	if [ "X$docmd" = "XYES" ]; then
	    touch $$.log
	date --utc >> $$.log
	    echo "update runs set type = 'stress' where id = $STRESS;" | \
		psql -a -U $PGUSER -h $PGHOST $DATABASE >> $$.log;
	date --utc >> $$.log
	    echo "update runs set experimentid = 'Not_Considered' where type = 'stress' and not id = $STRESS;" \
              | psql -a -U $PGUSER -h $PGHOST $DATABASE >> $$.log;
	date --utc >> $$.log
	    echo "update runs set experimentid = 'Robustness_1' where id = $STRESS;" |\
		psql -a -U $PGUSER -h $PGHOST $DATABASE >> $$.log;
	    EXPERIMENT=$(echo "select description from runs where id = $STRESS ; " |\
		psql -U $PGUSER -h $PGHOST $DATABASE  |\
		egrep -v '1 row|description|-----+|^ *$' |\
		awk ' { print $1; }' );
	    
	    START_TIME=$(echo "select starttime from runs where id = $STRESS ; " |\
		psql -U $PGUSER -h $PGHOST $DATABASE  |\
		egrep -v '1 row|starttime|-----+|^ *$' | awk ' { print $1; }')
	    
	    #STARTED_AT=$(( $START_TIME / 1000 ))
            STARTED_AT=$(perl -e "print int ($START_TIME / 1000 ). \"\n\" ;")
	else
	    echo touch $$.log
	    echo "update runs set type = 'stress' where id = $STRESS;" \| \
		psql -a -U $PGUSER -h $PGHOST $DATABASE \>\> $$.log;
	    echo "update runs set experimentid = 'Not_Considered' where type = 'stress' and not id = $STRESS;" \
                \| psql -a -U $PGUSER -h $PGHOST $DATABASE \>\> $$.log;
	    echo "update runs set experimentid = 'Robustness_1' where id = $STRESS;"\|\
		psql -a -U $PGUSER -h $PGHOST $DATABASE \>\> $$.log;
	    EXPERIMENT='Some-experiment-id'
	    STARTED_AT=$(date --utc +%s)
	fi
	echo "Updated runs table for $STRESS."

	TIME=$(date --utc -d "1970-01-01 UTC $STARTED_AT seconds" +"%Y-%m-%d_%T")
	DIR_TIME=$(date --utc -d "1970-01-01 UTC $STARTED_AT seconds" +"%y-%m-%d_%H")
	
	if [ "X$docmd" = "XYES" ]; then
	    echo "Starting analysis"
	date --utc
	date --utc >> $$.log
	    psql -a -U $PGUSER -h $PGHOST $DATABASE < $INSTALL_PATH/stressed_ro.sql >> $$.log;
	    echo "Created Stressed Table, starting completion"
	date --utc
	date --utc >> $$.log
	    psql -a -U $PGUSER -h $PGHOST $DATABASE < $INSTALL_PATH/completion.sql  >> $$.log;
	    echo "Finished completion, calculating results"
	date --utc
	date --utc >> $$.log
	    psql -a -U $PGUSER -h $PGHOST $DATABASE < $INSTALL_PATH/results.sql     >> $$.log;
	else
	    echo "Starting analysis"
	    echo psql -a -U $PGUSER -h $PGHOST $DATABASE \< $INSTALL_PATH/stressed_ro.sql \>\> $$.log
	    echo "Created Stressed Table, starting completion"
	    echo psql -a -U $PGUSER -h $PGHOST $DATABASE \< $INSTALL_PATH/completion.sql \>\> $$.log
	    echo "Finished completion, calculating results"
	    echo psql -a -U $PGUSER -h $PGHOST $DATABASE \< $INSTALL_PATH/results.sql \>\> $$.log
	fi
	echo "Starting to dump analsis results for run id $STRESS"
	if [ "X$docmd" = "XYES" ]; then
	    if [ ! -d ${EXPERIMENT}_${DIR_TIME} ]; then
		mkdir ${EXPERIMENT}_${DIR_TIME}
	    fi
	    if [ -x $INSTALL_PATH/dump_denormalized -a "X$PGHOST" = "Xlocalhost" ]; then
		$INSTALL_PATH/dump_denormalized -s_user $PGUSER \
		    -src "dbi:Pg:dbname=$DATABASE" stressed > \
		    ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_stressed.txt
	    fi
	    pg_dump -U $PGUSER -h $PGHOST -t stressed      \
                 -f ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_stressed.sql $DATABASE 
	    pg_dump -U $PGUSER -h $PGHOST -t completion    \
                 -f ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_completion.sql $DATABASE 
	    pg_dump -U $PGUSER -h $PGHOST -t completion_l2 \
                 -f ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_completion_l2.sql $DATABASE 
	    echo "select * from results;" | psql -U $PGUSER -h $PGHOST $DATABASE > \
		${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_results.txt
	    mv $$.log ${EXPERIMENT}_${DIR_TIME}/
	else
	    if [ -x $INSTALL_PATH/dump_denormalized -a "X$PGHOST" = "Xlocalhost" ]; then
		echo $INSTALL_PATH/dump_denormalized -s_user $PGUSER \
		    -src "dbi:Pg:dbname=$DATABASE" stressed \> \
		    ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_stressed.txt
	    fi
	    echo pg_dump -U $PGUSER -h $PGHOST -t stressed      \
                 -f ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_stressed.sql $DATABASE 
	    echo pg_dump -U $PGUSER -h $PGHOST -t completion    \
                 -f ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_completion.sql $DATABASE 
	    echo pg_dump -U $PGUSER -h $PGHOST -t completion_l2 \
                 -f ${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_completion_l2.sql $DATABASE 
	    echo "select * from results;" \| psql -U $PGUSER -h $PGHOST $DATABASE \> \
		${EXPERIMENT}_${DIR_TIME}/${EXPERIMENT}_${TIME}_results.txt
	    echo mv $$.log ${EXPERIMENT}_${DIR_TIME}/
	fi
	echo "Done with run id $STRESS"
    done
fi



