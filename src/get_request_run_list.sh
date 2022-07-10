#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: 
    get_request_run_list.sh [ options ]

Options (all options required):
-h: Print this help message
-d: print debug messages
-C CATALOG: Path to catalog3 file. Required 
-o OUTD: Output directory.  Required.  May be per-disease
-s CASES_FN: Path to file listing cases of interest.  Required
-p PIPELINE_NAME: canonical name of pipeline we're evaluating.  Required
-P PIPELINE_CONFIG_FN: configuration file with per-pipeline definitions.  Required
-D DAS: Path to data analysis summary file.  If not defined, request run list is canonical run list
-q: Add aliquot information to run_list

Create canonical run list for all cases of interest
Optionally refines this run list by excluding all runs which have already been performed
  based on information from data analysis summary file and writes request run list

TODO: in future, optionally filter by aliquot names already processed
TODO: indicate which files are written

Given a list of cases of interest, generate canonical run_list for which analyses need to
be performed.  This workflow focuses on run_lists, which for paired (i.e.
somatic) workflows consists of a pair of datsets.  It can identify analyses to
perform even when some analyses have been performed for that case

Algorithm and outputs
  1. we are given list of cases of interest (-s CASES_FN)
  2. read configuration parameters from PIPELINE_CONFIG_FN
	 * process all lines in config file which match pipeline.  This allows for better control with multiple sample types
  3. Generate canonical run_list for cases of interest
    * for paired workflows, for one case, with M sample1 and N sample2, canonical run_list will consist of 
      MxN runs
  4. Optionally, get all UUIDs (or UUID pairs) which have been analyzed (analyzed UUIDs)
     -> Based on data analysis summary file
  5. Find request run list as difference between canonical run_list and that formerly analyzed 
     -> This is the run list which needs to be analyzed
EOF

PYTHON="python3"
XARGS="" # arguments passed to make_canonical_run_list.py
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdC:o:s:p:P:D:q" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)
      DEBUG="-d"
      ;;
    C) 
      CATALOG="$OPTARG"
      ;;
    o) 
      OUTD="$OPTARG"
      ;;
    s) 
      CASES_FN="$OPTARG"
      ;;
    p) 
      PIPELINE_NAME="$OPTARG"
      ;;
    P) 
      PIPELINE_CONFIG_FN="$OPTARG"
      ;;
    D) 
      DAS="$OPTARG"
      ;;
    q) 
      MRL_ARGS="$MRL_ARGS -q" # make run list arguments.  Others can be passed this way too
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z $CATALOG ]; then    # check if file exists later
    >&2 echo ERROR: -c CATALOG
    >&2 echo "$USAGE"
    exit 1
fi

if [ -z $OUTD ]; then
    >&2 echo ERROR: -o OUTD
    >&2 echo "$USAGE"
    exit 1
fi

if [ -z $CASES_FN ]; then
    >&2 echo ERROR: -s CASES_FN
    >&2 echo "$USAGE"
    exit 1
fi
if [ ! -e $CASES_FN ] ; then
    >&2 echo ERROR: File not found: $CASES_FN 
    exit 1
fi

if [ -z $PIPELINE_NAME ]; then
    >&2 echo ERROR: -p PIPELINE_NAME
    >&2 echo "$USAGE"
    exit 1
fi

if [ -z $PIPELINE_CONFIG_FN ]; then
    >&2 echo ERROR: -P PIPELINE_CONFIG_FN
    >&2 echo "$USAGE"
    exit 1
fi
if [ ! -e $PIPELINE_CONFIG_FN ] ; then
    >&2 echo ERROR: File not found: PIPELINE_CONFIG_FN $PIPELINE_CONFIG_FN 
    exit 1
fi

if [ -z $DAS ]; then
    >&2 echo NOTE: DAS not defined, assuming no analyses performed
elif [ ! -e $DAS ] ; then
    # if it is defined then it must exist
    >&2 echo ERROR: File not found: DAS $DAS 
    exit 1
fi


function test_exit_status {
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo ERROR: Fatal error.  Exiting.
            exit $rc;
        fi;
    done
}

mkdir -p $OUTD
test_exit_status 

# Iterate over all lines in pipeline configuration file and process any that exists

# We delete this file if it exists because make_canonical_run_list.py will append to existing files
CRL="$OUTD/canonical_run_list.dat"
rm -f $CRL
test_exit_status 
PROCESSED=0		# flag indicating if pipeline was processed at least once

CASES=$(cat $CASES_FN)

while read PIPELINE_DETS; do
	PN=$(echo "$PIPELINE_DETS" | cut -f 1)

	if [ $PN != $PIPELINE_NAME ]; then
		continue
	fi
	PROCESSED=1

	ALIGNMENT=$(echo "$PIPELINE_DETS" | cut -f 2)
	EXPERIMENTAL_STRATEGY=$(echo "$PIPELINE_DETS" | cut -f 3)
	DATA_FORMAT=$(echo "$PIPELINE_DETS" | cut -f 4)
	DATA_VARIETY=$(echo "$PIPELINE_DETS" | cut -f 5)
	SAMPLE_TYPE=$(echo "$PIPELINE_DETS" | cut -f 6)
	SAMPLE_TYPE2=$(echo "$PIPELINE_DETS" | cut -f 7)
	SUFFIX=$(echo "$PIPELINE_DETS" | cut -f 8)
	UUID_COL=$(echo "$PIPELINE_DETS" | cut -f 9)

	ARGS="$DEBUG -C $CATALOG -o $CRL -a $ALIGNMENT -e $EXPERIMENTAL_STRATEGY -f $DATA_FORMAT -t $SAMPLE_TYPE $MRL_ARGS"
    
	if [ $DATA_VARIETY != "." ]; then
		ARGS="$ARGS -v $DATA_VARIETY"
	fi

    if [ $SAMPLE_TYPE2 != "." ]; then
        ARGS="$ARGS -T $SAMPLE_TYPE2"
    fi

    if [ $SUFFIX != "." ]; then
        ARGS="$ARGS -s $SUFFIX"
    fi

	CMD="$PYTHON src/make_canonical_run_list.py $ARGS $CASES"
	>&2 echo Running: $CMD
	eval $CMD
	test_exit_status

done <$PIPELINE_CONFIG_FN

if [ $PROCESSED == 0 ]; then
	>&2 echo ERROR: Pipeline $PIPELINE_NAME not found in $PIPELINE_CONFIG_FN
	exit 1
fi

OUT_ANALYSIS="$OUTD/request_run_list.dat"
#  3. Get all UUIDs which have been analyzed (analyzed UUIDs), possibly paired
#     If DAS not defined, assume that nothing has been analyzed
if [ -z $DAS ]; then
    >&2 echo Analysis summary file not defined.  Request run list is canonical 
    cp $CRL $OUT_ANALYSIS
    test_exit_status
else
    OUT_ANALYZED="$OUTD/analyzed_UUIDs.dat"
    # Note that we need to retain the header and it doesn't necessarily sort right
#echo "a" | grep -o ',' | wc -l

    # First, get the right header for OUT_ANALYZED.  These are UUIDs, and have different headers depending
    # on if it is paired run_list or not.  Paired run_lists have commas in $UUID_COL
    NCOL=$( echo "$UUID_COL" | grep -o "," | wc -l ) # 0 or 1
    if [ "$NCOL" == "0" ]; then
        printf "datafile_uuid\n" > $OUT_ANALYZED
    elif [ "$NCOL" == "1" ]; then
        printf "datafile1_uuid\tdatafile2_uuid\n" > $OUT_ANALYZED
    else
        >&2 echo "ERROR: unexpected format of UUID_COL: $UUID_COL"
        exit 1
    fi

    #CMD="head -n1 $DAS | cut -f $UUID_COL >  $OUT_ANALYZED && tail -n +2 $DAS | cut -f $UUID_COL | sort -u >> $OUT_ANALYZED"
    CMD="tail -n +2 $DAS | cut -f $UUID_COL | sort -u >> $OUT_ANALYZED"
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status

    CMD="$PYTHON src/refine_run_list.py -X $OUT_ANALYZED -o $OUT_ANALYSIS $CRL "
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
    >&2 echo Written to $OUT_ANALYSIS 
fi

