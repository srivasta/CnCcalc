#                               -*- Mode: Sh -*- 
# update_wiki.sh --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Dec 11 08:59:26 2002
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Thu Dec 12 18:25:37 2002
# Last Machine Used: ember.green-gryphon.com
# Update Count     : 81
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

DATABASE=current
PGHOST=localhost
PGUSER=postgres


progname="`basename \"$0\"`"
pversion=' $Revision: 1.1 $ '

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

Usage: $progname  [options]
 -h           This help
 -H<hostname> Set host to <hostnamename>                 (no spaces after -H)
 -U<user>     Use <user> instead of postgres             (no spaces after -U)
 -d<database> Use database <database> instead of cnccalc (no spaces after -d)
END
}

# Command line
while [ $# != 0 ]; do
    value="`echo x\"$1\" | sed -e 's/^x-.//'`"
    case "$1" in
        -h)  usageversion; exit 0        ;;
        -H*)  PGHOST="$value"            ;;
        -U*)  PGUSER="$value"            ;;
        -d*)  DATABASE="$value"          ;;
        -*)   echo Uknown option ;;
        *)    stressed_runs=("${stressed_runs[@]}" "$1") ;;
    esac
    shift
done


header0='  |  *id*  |  *Experimentid*  |  *description*  |  *Notes*  |  *Completeness*  |  *Correctness*  |  *Variation*  |  *Transport*  |  *Supply*  |  *ProjectSupply*  |  *type*  |  *status*  |  *gls*  |  *logging*  |  *finished*  |  *Experiment Started*  |  *Oplan*  |  *GLS*  |  *Final Planning Complete*  |  *Log Started*  |'

header1='  |  *id*  |  *Experimentid*  |  *description*  |  *Notes*  |  *type*  |  *status*  |  *gls*  |  *logging*  |  *finished*  |  *Log Started*  |'

header2='  |  *id*  |  *Experimentid*  |  *description*  |  *Notes*  |  *Experiment Started*  |  *Oplan*  |  *GLS*  |  *Planning Complete*  |  *PC at C+5*  |  *Perturbation 1*  |  *PC at C+7*  |  *Perturbation 2*  |  *PC at C+10*  |  *Perturbation 3*  |  *Log Started*  |  *Logging Ended*  |  *Experiment Ended*  |'

header3='  |  *id*  |  *Experimentid*  |  *description*  |  *Notes*  |  *Completeness*  |  *Correctness*  |  *Variation*  |  *Transport*  |  *Supply*  |  *ProjectSupply*  |  *Total*  |  *Log Started*  |'

header4='  |  *id*  |  *Experimentid*  |  *description*  |  *Notes*  |  *Total*  |  *Incomplete_L6*  |  *Incomplete_L2*  |  *Complete_l6*  |  *Complete_l2*  |  *Phased_l6*  |  *Phased_l2*  |  *Log Started*  |'

header5='  |  *id*  |  *Experimentid*  |  *description*  |  *Notes*  |  *Total*  |  *Total_7_AR*  |  *Completeness_7_AR*  |  *Correcness_7_AR*  |  *Total_7_Pref*  |  *Completeness_7_Pref*  |  *Correctness_7_Pref*  |  *Log Started*  |'

     
for index in $(seq 0 5); do
    if [ -e "runs$index.txt" ]; then
	cp runs$index.txt runs$index.new
	min_run_id=$(eval perl -nle \''if(m/^\s*\|\s*(\d+)\s*\|/) {$runid = $1;} END { print $runid;}'\' "runs$index.new")
	eval "min_run_id_$index=$min_run_id"
    else
	eval "echo \"\$header$index\" > runs$index.new"
	eval "min_run_id_$index=0";
    fi
done


select0=" SET TIME ZONE 'UTC';
          SELECT id           as \"*id*\", 
                description  as \"*Experimentid*\", 
                description  as \"*description*\", 
                '  &nbsp;  ' as \"*Notes*\",  
                '  &nbsp;  ' as \"*Completeness*\", 
                '  &nbsp;  ' as \"*Correctness*\", 
                '  &nbsp;  ' as \"*Variation*\", 
                '  &nbsp;  ' as \"*Transport*\", 
                '  &nbsp;  ' as \"*Supply*\", 
                '  &nbsp;  ' as \"*ProjectSupply*\", 
                type         as \"*type*\", 
                status       as \"*status*\", 
                gls          as \"*gls*\", 
                logging      as \"*logging*\", 
                finished     as \"*finished*\", 
                '  &nbsp;  ' as \"*Experiment Started*\", 
                '  &nbsp;  ' as \"*Oplan*\", 
                '  &nbsp;  ' as \"*GLS*\",  
                '  &nbsp;  ' as \"*Final Planning Complete*\",  
                datetime(int4(starttime/1000))    as \"*Log Started*\"
        FROM runs WHERE id > $min_run_id_0
        ORDER BY id;"

select1="SET TIME ZONE 'UTC';
          SELECT id           as \"*id*\",  
                description  as \"*Experimentid*\", 
                description  as \"*description*\", 
                '  &nbsp;  ' as \"*Notes*\",  
                type         as \"*type*\",  
                status       as \"*status*\", 
                gls          as \"*gls*\", 
                logging      as \"*logging*\", 
                finished     as \"*finished*\",
                datetime(int4(starttime/1000))  as \"*Log Started*\"  
        FROM runs WHERE id > $min_run_id_1
        ORDER BY id;"

select2="SET TIME ZONE 'UTC';
          SELECT id           as \"*id*\",  
                description  as \"*Experimentid*\", 
                description  as \"*description*\", 
                '  &nbsp;  ' as \"*Notes*\",  
                '  &nbsp;  ' as \"*Experiment Started*\", 
                '  &nbsp;  ' as \"*Oplan*\", 
                '  &nbsp;  ' as \"*GLS*\",  
                '  &nbsp;  ' as \"*Planning Complete*\",  
                '  &nbsp;  ' as \"*PC at C+5*\",  
                '  &nbsp;  ' as \"*Perturbation 1*\",  
                '  &nbsp;  ' as \"*PC at C+7*\",  
                '  &nbsp;  ' as \"*Perturbation 2*\",  
                '  &nbsp;  ' as \"*PC at C+10*\",  
                '  &nbsp;  ' as \"*Perturbation 3*\",  
                datetime(int4(starttime/1000))    as \"*Log Started*\", 
                datetime(int4(endtime/1000)) as \"*Logging Ended*\",
                '  &nbsp;  ' as \"*Experiment Ended*\"
        FROM runs WHERE id > $min_run_id_2
        ORDER BY id;"

select3="SET TIME ZONE 'UTC';
          SELECT id           as \"*id*\",  
                description  as \"*Experimentid*\", 
                description  as \"*description*\", 
                '  &nbsp;  ' as \"*Notes*\",  
                '  &nbsp;  ' as \"*Completeness*\", 
                '  &nbsp;  ' as \"*Correctness*\", 
                '  &nbsp;  ' as \"*Variation*\", 
                '  &nbsp;  ' as \"*Transport*\", 
                '  &nbsp;  ' as \"*Supply*\", 
                '  &nbsp;  ' as \"*ProjectSupply*\", 
                '  &nbsp;  ' as \"*Total*\", 
                datetime(int4(starttime/1000))     as \"*Log Started*\" 
        FROM runs WHERE id > $min_run_id_3
        ORDER BY id;"

select4="SET TIME ZONE 'UTC';
          SELECT id           as \"*id*\",  
                description  as \"*Experimentid*\", 
                description  as \"*description*\", 
                '  &nbsp;  ' as \"*Notes*\",  
                '  &nbsp;  ' as \"*Total*\", 
                '  &nbsp;  ' as \"*Incomplete_L6*\", 
                '  &nbsp;  ' as \"*Incomplete_L2*\", 
                '  &nbsp;  ' as \"*Complete_l6*\", 
                '  &nbsp;  ' as \"*Complete_l2*\", 
                '  &nbsp;  ' as \"*Phased_l6*\", 
                '  &nbsp;  ' as \"*Phased_l2*\", 
                datetime(int4(starttime/1000))     as \"*Log Started*\"
        FROM runs WHERE id > $min_run_id_4
        ORDER BY id;"

select5="SET TIME ZONE 'UTC';
          SELECT id           as \"*id*\",  
                description  as \"*Experimentid*\", 
                description  as \"*description*\", 
                '  &nbsp;  ' as \"*Notes*\",  
                '  &nbsp;  ' as \"*Total*\", 
                '  &nbsp;  ' as \"*Total_7_AR*\",  
                '  &nbsp;  ' as \"*Completeness_7_AR*\", 
                '  &nbsp;  ' as \"*Correcness_7_AR*\", 
                '  &nbsp;  ' as \"*Total_7_Pref*\", 
                '  &nbsp;  ' as \"*Completeness_7_Pref*\", 
                '  &nbsp;  ' as \"*Correctness_7_Pref*\", 
                datetime(int4(starttime/1000))     as \"*Log Started*\"
        FROM runs WHERE id > $min_run_id_5
        ORDER BY id;"

for index in $(seq 0 5); do
    if [ -e "runs$index.txt" ]; then
	eval "echo \"\$select$index\"" |  \
          psql -U $PGUSER -h $PGHOST $DATABASE | \
             egrep -v  '^( \*)|^(\-+)' >> runs$index.new
	perl -pli~ -e 's/^(\s*\d+\s*\|\s*)(\S+)[^\|]+(\|\s*)\S+\s+\-(.*$)/$1$2  $3$4/;' runs$index.new
	perl -pli~ -e 's/^\s*SET VARIABLE\s*$//g' runs$index.new
	perl -pli~ -e 's/^\s*.\d+ rows.\s*$//g' runs$index.new
	perl -pli~ -e 's/^\s+(\d)/  |  $1/g' runs$index.new
	perl -pli~ -e 's/([^|\s])\s*$/$1  | /g' runs$index.new
	perl -pli~ -e 's/(2002-\d+-\d+) (\d+:\d+:\d+)/$1_$2/g' runs$index.new
	perl -pli~ -e 's/(1970-\d+-\d+) (\d+:\d+:\d+)/0/g' runs$index.new
    else
	eval "echo \"\$select$index\"" | \
          psql -U $PGUSER -h $PGHOST $DATABASE | \
             egrep -v  '^( \*)|^(\-+)' >> runs$index.new
	perl -pli~ -e 's/^(\s*\d+\s*\|\s*)(\S+)[^\|]+(\|\s*)\S+\s+\-(.*$)/$1$2  $3$4/;' runs$index.new
	perl -pli~ -e 's/^\s*SET VARIABLE\s*$//g' runs$index.new
	perl -pli~ -e 's/^\s*\(\d+ rows\)\s*$//g' runs$index.new
	perl -pli~ -e 's/^\s+(\d)/  |  $1/g' runs$index.new
	perl -pli~ -e 's/([^|\s])\s*$/$1  | /g' runs$index.new
	perl -pli~ -e 's/(2002-\d+-\d+) (\d+:\d+:\d+)/$1_$2/g' runs$index.new
	perl -pli~ -e 's/(1970-\d+-\d+) (\d+:\d+:\d+)/0/g' runs$index.new
    fi
done
