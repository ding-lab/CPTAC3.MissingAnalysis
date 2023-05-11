#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: 
    get_oldrun_list.sh [ options ]

Options (all options required):
-h: Print this help message
-d: print debug messages
-C CATALOG: Path to REST API-based catalog file. Required 
-o OUTFN: Output file. Required
-p PIPELINE_NAME: canonical name of pipeline we're evaluating.  Required
-P PIPELINE_CONFIG_FN: configuration file with per-pipeline definitions.  Required
-D DAS: Path to data analysis summary file.  Required

Generate a list of aliquots or aliquot pairs corresponding to previously analyzed runs.
UUIDs of input to previously analyzed runs is obtined from DAS.  These are then converted

The only thing we use pipeline info for is to get the correct columns of the DCC Analysis Summary file for
the UUID(s)

EOF

PYTHON="python3"
XARGS="" # arguments passed to make_canonical_run_list.py
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdC:o:p:P:D:" opt; do
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
      OUTFN="$OPTARG"
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

if [ -z $OUTFN ]; then
    >&2 echo ERROR: -o OUTFN required
    >&2 echo "$USAGE"
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
    >&2 echo ERROR: DAS not defined
    exit 1
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

# Search for an aliquot in a catalog2 file based on UUID
# WARNING if anything other than one aliquot found
# Actually, situation of no aliquot found is common. For instance, we've processed a dataset which did not 
# exist at time historical catalog was made.  Would be good to pre-filter results based on timestamp - TODO

#$ header DLBCL.Catalog3.tsv
#     1  dataset_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  sample_type
#     6  specimen_name
#     7  filename
#     8  filesize
#     9  data_format
#    10  data_variety
#    11  alignment
#    12  project
#    13  uuid
#    14  md5
#    15  metadata

function get_aliquot {
    UUID=$1
    # CATALOG is read as a global

    if [ ! -f $CATALOG ]; then
        >&2 echo ERROR: $CATALOG not found
        exit 1
    fi

    ALIQUOT=$(awk -v uuid=$UUID 'BEGIN{FS="\t"; OFS="\t"}{if ($13 == uuid) print $6}' $CATALOG | sort -u)

    if [ -z $ALIQUOT ]; then
        >&2 echo WARNING: No entry found in $CATALOG for $UUID
        return
    elif [ $(echo "$ALIQUOT" | wc -l) != "1" ]; then
        >&2 echo WARNING: multiple entries found in $CATALOG for $UUID
        exit 1
    fi

    echo $ALIQUOT
}

UUID_COL=$(awk -v PN=$PIPELINE_NAME 'BEGIN{FS="\t"; OFS="\t"}{if ($1 == PN) print $9}' $PIPELINE_CONFIG_FN | sort -u)

OUTD=$(dirname "$OUTFN")
mkdir -p $OUTD
TMP="$OUTD/processed_UUID.tmp"
rm -f $TMP

CMD="cut -f $UUID_COL $DAS | tr -d $'\r' | tail -n +2 | sort -u >> $TMP"
echo Running $CMD
eval $CMD


# First, get the right header for OUT_ANALYZED.  These are UUIDs, and have different headers depending
# on if it is paired run_list or not.  Paired run_lists have commas in $UUID_COL
# xargs strips the whitespace to allow for string matching
NCOL=$( echo "$UUID_COL" | grep -o "," | wc -l | xargs) # 0 or 1
if [ "$NCOL" == "0" ]; then
    IS_PAIRED=0
    printf "datafile_aliquot\n" > $OUTFN
elif [ "$NCOL" == "1" ]; then
    IS_PAIRED=1
    printf "datafile1_aliquot\tdatafile2_aliquot\n" > $OUTFN
else
    >&2 echo "ERROR: unexpected format of UUID_COL: $UUID_COL"
    exit 1
fi

# Now go through all UUID / UUID pairs in file TMP and convert them to aliquots
# This is quite slow.  Better to implement in python / pandas
while read L; do
    if [ $DEBUG ]; then
        >&2 echo Processing $L
    fi
    U1=$(echo "$L" | cut -f 1)
    A1=$(get_aliquot $U1)

    if [ -z $A1 ]; then
        continue
    fi

    if [ $IS_PAIRED == "1" ]; then
        U2=$(echo "$L" | cut -f 2)
        A2=$(get_aliquot $U2)

        printf "$A1\t$A2\n" >> $OUTFN
    else
        printf "$A1\n" >> $OUTFN
    fi

done <$TMP

if [ -z "$DEBUG" ]; then
    CMD="rm -f $TMP"
    >&2 echo NOT Running: $CMD
#    eval $CMD
else
    >&2 echo Retaining temp file $TMP
fi

>&2 echo Written to $OUTFN
