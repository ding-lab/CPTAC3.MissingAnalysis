#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Runs get_missing_analyses.sh and get_download_UUID.sh 

Usage:
  evaluate_analysis_status.sh [options] 

Options:
-h: Print this help message
-c DCC_UUID_COL: specify which columns in DCC analysis summary files have the UUIDs (e.g., '12' or '12,14').  Required
-D DAS: Data analysis summary file to identify which analyses already performed.  Skip this step if not provided
-B BAMMAP: Path to BamMap file.  Required
-C CATALOG: Path to Catalog file.  Required
-F CATALOG_FILTER: Filter commands to perform to identify appropriate entries.  See src/get_missing_analyses.sh
-o OUTD: Ouput directory base.  Default: ./dat  (typically, e.g., "dat/RNA-Seq_Expression")
-d DIS: disease, e.g., LUAD.  Required
-S CASES: path to CASES file.  Default dat/cases.dat (typically, e.g., "dat/cases/$DIS.dat")
-s SYSTEM: Name of destination system.  Used for output file creation only

Data analysis summary file may be obtained for various pipelines with,
https://github.com/ding-lab/CPTAC3.catalog/tree/master/DCC_Analysis_Summary 

EOF

# Assume a default location for CASES file
CASES="dat/cases.dat"

function confirm {
    FN=$1
    if [ ! -s $FN ]; then
        >&2 echo ERROR: $FN does not exist or is empty
        exit 1
    fi
}

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hc:D:B:C:F:o:d:S:s:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    c)  
      DCC_UUID_COL=$OPTARG
      ;;
    D)  
      confirm $OPTARG
      DAS_ARG="-a $OPTARG"
      ;;
    B)  
      BAMMAP=$OPTARG
      ;;
    C)  
      CATALOG=$OPTARG
      ;;
    F)  
      CATALOG_FILTER="$OPTARG"
      ;;
    o)  
      OUTD=$OPTARG
      ;;
    d)  
      DIS=$OPTARG
      ;;
    S)  
      CASES=$OPTARG
      ;;
    s)  
      SYSTEM=$OPTARG
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

# Called after running scripts to catch fatal (exit 1) errors
# works with piped calls ( S1 | S2 | S3 > OUT )
function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    # exit code 137 is fatal error signal 9: http://tldp.org/LDP/abs/html/exitcodes.html

    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal error.  Exiting
            exit $rc;
        fi;
    done
}

function run_cmd {
    CMD=$1

    NOW=$(date)
    if [ "$DRYRUN" == "d" ]; then
        >&2 echo [ $NOW ] Dryrun: $CMD
    else
        >&2 echo [ $NOW ] Running: $CMD
        eval $CMD
        test_exit_status
    fi
}

if [ "$#" -ne 0 ]; then
    >&2 echo Error: Wrong number of arguments
    echo "$USAGE"
    exit 1
fi

# General scripts

if [ -z $DIS ]; then
    >&2 echo ERROR: DIS not specified
    exit 1
fi
if [ -z $OUTD ]; then
    >&2 echo ERROR: OUTD not specified
    exit 1
fi
if [ -z $DCC_UUID_COL ]; then
    >&2 echo ERROR: DCC_UUID_COL not specified
    exit 1
fi

confirm $CASES 

ARGS=" -d $DIS -c $CATALOG $DAS_ARG -o $OUTD -s $CASES -f \"$CATALOG_FILTER\" -G $DCC_UUID_COL -D"
CMD="bash src/get_missing_analyses.sh $ARGS"
run_cmd "$CMD"

ARGS=" -d $DIS -o $OUTD -b $BAMMAP -s $SYSTEM"
CMD="bash src/get_download_UUID.sh $ARGS"
run_cmd "$CMD"

