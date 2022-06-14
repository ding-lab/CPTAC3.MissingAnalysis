#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: 
    get_request_run_list.sh [ options ]

Options (all options required):
-h: Print this help message
-C CATALOG: Path to catalog3 file. Required 
-o OUTD: Output directory.  Required.  May be per-disease
-s CASES_FN: Path to file listing cases of interest.  Required
-p PIPELINE_NAME: canonical name of pipeline we're evaluating.  Required
-P PIPELINE_CONFIG_FN: configuration file with per-pipeline definitions.  Required
-D DAS: Path to data analysis summary file.  If not defined, request run list is canonical run list

Creates a canonical run list for all cases of interest
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
while getopts ":hC:o:s:p:P:D:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
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
    >&2 echo ERROR: File not found: CASES_FN $CASES_FN 
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

PIPELINE_DETS=$(grep $PIPELINE_NAME $PIPELINE_CONFIG_FN)
test_exit_status 
if [ -z "$PIPELINE_DETS" ]; then
    >&2 echo ERROR: Pipeline info for $PIPELINE_NAME not found in $PIPELINE_CONFIG_FN
    exit 1
fi
#     1	pipeline
#     2	alignment
#     3	experimental_strategy
#     4	data_format
#     5	data_variety
#     6	data_variety2
#     7	sample_type
#     8	sample_type2
#     9	label1
#    10	label2
#    11	uuid_col

PIPELINE=$(echo "$PIPELINE_DETS" | cut -f 1)
ALIGNMENT=$(echo "$PIPELINE_DETS" | cut -f 2)
EXPERIMENTAL_STRATEGY=$(echo "$PIPELINE_DETS" | cut -f 3)
DATA_FORMAT=$(echo "$PIPELINE_DETS" | cut -f 4)
DATA_VARIETY=$(echo "$PIPELINE_DETS" | cut -f 5)
DATA_VARIETY2=$(echo "$PIPELINE_DETS" | cut -f 6)
SAMPLE_TYPE=$(echo "$PIPELINE_DETS" | cut -f 7)
SAMPLE_TYPE2=$(echo "$PIPELINE_DETS" | cut -f 8)
LABEL1=$(echo "$PIPELINE_DETS" | cut -f 9)
LABEL2=$(echo "$PIPELINE_DETS" | cut -f 10)
UUID_COL=$(echo "$PIPELINE_DETS" | cut -f 11)
IS_PAIRED=$(echo "$PIPELINE_DETS" | cut -f 12)

#    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
#    parser.add_argument("-C", "--catalog", dest="catalog_fn", help="Catalog file name", required=True)
#    parser.add_argument("-o", "--output", dest="outfn", default="stdout", help="Output file name.  Default writes to stdout")
#    parser.add_argument("-a", "--alignment", help="Alignment of datasets, e.g., 'harmonized'")
#    parser.add_argument("-e", "--experimental_strategy", help="Experimental strategy of datasets, e.g., 'WGS'")
#    parser.add_argument("-f", "--data_format", help="Data format of datasets, e.g., 'BAM'")
#    parser.add_argument("-v", "--data_variety", help="Data variety of dataset, e.g., 'genomic'")
#    parser.add_argument("-V", "--data_variety2", help="Data variety of dataset 2, if different")
#    parser.add_argument("-t", "--sample_type", required=True, help="Comma-separated list of sample types for sample1")
#    parser.add_argument("-T", "--sample_type2", help="Comma-separated list of sample types for sample2.  Implies paired workflow")
#    parser.add_argument("-l", "--label1", default="dataset1", help="Label used for this dataset, e.g., 'tumor'")
#    parser.add_argument("-L", "--label2", default="dataset2", help="Label used for this dataset, e.g., 'normal'")
#    parser.add_argument("-p", "--pipeline", help="Target pipeline name")
#    parser.add_argument('cases', nargs='+', help="Cases to be evaluated")

CRL="$OUTD/canonical_run_list.dat"
CASES=$(cat $CASES_FN)

ARGS="-C $CATALOG -o $CRL -a $ALIGNMENT -e $EXPERIMENTAL_STRATEGY -f $DATA_FORMAT -v $DATA_VARIETY -t $SAMPLE_TYPE -l $LABEL1 -p $PIPELINE"
if [ $IS_PAIRED == "1" ]; then
    if [ ! -z $DATA_VARIETY2 ]; then
        ARGS="$ARGS -V $DATA_VARIETY2"
    fi
    ARGS="$ARGS -T $SAMPLE_TYPE2 -L $LABEL2"
fi

CMD="$PYTHON src/make_canonical_run_list.py $ARGS $CASES"
>&2 echo Running: $CMD
eval $CMD
test_exit_status

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
    CMD="head -n1 $DAS | cut -f $UUID_COL >  $OUT_ANALYZED && tail -n +2 $DAS | cut -f $UUID_COL | sort -u >> $OUT_ANALYZED"
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status

    CMD="$PYTHON src/refine_run_list.py -U $OUT_ANALYZED -o $OUT_ANALYSIS $CRL "
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
    >&2 echo Written to $OUT_ANALYSIS 
fi

