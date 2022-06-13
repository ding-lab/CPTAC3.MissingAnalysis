#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: 
    get_request_run_list.sh [ options ]

Options (all options required):
-h: Print this help message
-c CATALOG: Path to catalog3 file.  
-D DAS: Path to data analysis summary file.  If not defined, assume nothing analyzed
-o OUTD: Output directory.  Required.  May be per-disease
-s CASES_FN: Path to file listing cases of interest.  Required
-G UUID_COL: comma-separated list of integers which identify columns having UUIDs in DAS
   e.g., -G 12 for unpaired and -G 12,14 for unpaired.  Required if DAS specified
-x xargs: additional arguments to pass to parse_aliquot.py
-a alignment: Alignment of datasets, e.g., 'harmonized'
-e experimental_strategy: Experimental strategy of datasets, e.g., 'WGS'
-t sample_type: Comma-separated list of sample types for sample1
-T sample_type2: Comma-separated list of sample types for sample2.  Implies paired workflow

Given a list of cases of interest, generate run_list for which analyses need to
be performed.  This workflow focuses on run_lists, which for paired (i.e.
somatic) workflows consists of a pair of datsets.  It can identify analyses to
perform even when some analyses have been performed for that case

Algorithm and outputs
  1. we are given list of cases of interest (-s CASES_FN)
  2. Generate canonical run_list for cases of interest
    * for paired workflows, for one case, with M sample1 and N sample2, canonical run_list will consist of 
      MxN runs
  3. Get all UUIDs (or UUID pairs) which have been analyzed (analyzed UUIDs)
     -> Based on data analysis summary file
     -> Writes out OUTD/analyzed_UUID.dat ???
  4. Find request run list as difference between canonical run_list and that formerly analyzed 
     -> This is the run list which needs to be analyzed
     -> Writes out OUTD/analysis_UUID.dat ???
     -> Also writes OUTD/analysis_SN.dat, with the fields "sample_name, case, disease, UUID" ????

It is expected that the script src/get_download_UUID.sh will be run following this one ???
EOF

PYTHON="python3"
PA_ARGS="" # arguments passed to parse_aliquot.py
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hC:D:o:s:a:t:T:e:x:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    C) 
      #CATALOG="$OPTARG"
      PA_ARGS="$PA_ARGS -C $OPTARG"
      ;;
    D) 
      DAS="$OPTARG"
      ;;
    o) 
      OUTD="$OPTARG"
      ;;
    s) 
      CASES_FN="$OPTARG"
      ;;
    a) 
      PA_ARGS="$PA_ARGS -a $OPTARG"
      ;;
    t) 
      PA_ARGS="$PA_ARGS -t $OPTARG"
      ;;
    T) 
      PA_ARGS="$PA_ARGS -T $OPTARG"
#      PAIRED_WORKFLOW=1        # not clear we care here
      ;;
    e) 
      PA_ARGS="$PA_ARGS -e $OPTARG"
      ;;
    x) 
      PA_ARGS="$PA_ARGS -x $OPTARG"
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

if [ -z $CATALOG ]; then
    >&2 echo ERROR: -c CATALOG
    >&2 echo "$USAGE"
    exit 1
fi
if [ ! -e $CATALOG ] ; then
    >&2 echo ERROR: File not found: CATALOG $CATALOG 
    exit 1
fi

if [ -z $DAS ]; then
    >&2 echo NOTE: DAS not defined, assuming no analyses performed
elif [ ! -e $DAS ] ; then
    # if it is defined then it must exist
    >&2 echo ERROR: File not found: DAS $DAS 
    exit 1
    if [-z $UUID_COL]; then
        >&2 echo ERROR: -G UUID_COL not specified
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

function test_exit_status {
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal error.  Exiting.
            exit $rc;
        fi;
    done
}

function report {
    FN=$1
    if [ ! -e $FN ]; then
        >&2 echo ERROR: $FN does not exist
        exit 1
    fi
    N=$(wc -l $FN | sed 's/^ *//' | cut -f 1 -d ' ')
    echo Written to $FN \( $N \)
    echo 
}

mkdir -p $OUTD

#  2. Identify all UUIDs associated with cases of interest (UUIDs of interest)
#     Find all appropriate datasets (as determined by CATALOG_FILTER) whose case is in CASES file
#     and extract the UUID
#     Using AWK to evaluate case field ($2) of CATALOG file
# https://stackoverflow.com/questions/42851582/find-in-word-from-one-file-to-another-file-using-awk-nr-fnr

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
CASES=<(echo $CASES_FN)

CMD="$PYTHON src/parse_aliquot.py -o $CRL $CASES"

>&2 echo Running: $CMD
eval $CMD
test_exit_status

#  3. Get all UUIDs which have been analyzed (analyzed UUIDs), possibly paired
#     If DAS not defined, assume that nothing has been analyzed
OUT_ANALYZED="$OUTD/analyzed_UUIDs.dat"
if [ -z $DAS ]; then
    >&2 echo Analysis summary file not defined, assuming nothing analyzed.
    touch $OUT_ANALYZED
    eval $CMD
    test_exit_status
else
    CMD="cut -f $UUID_COL $DAS | sort -u > $OUT_ANALYZED"
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
    report $OUT_ANALYZED 
fi

#  4. Find analysis UUIDs as difference between UUIDs of interest and analyzed UUIDs
#     -> These are the UUIDs which are to be analyzed
#     -> Writes out OUTD/DIS/analysis_UUID.dat
OUT_ANALYSIS="$OUTD/$DIS/analysis_UUID.dat"
CMD="comm -23 $UUIDS_OF_INTEREST $OUT_ANALYZED  > $OUT_ANALYSIS"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_ANALYSIS

# For convenience of analysts, also create file which lists sample names associated with analysis UUIDs
OUT_ANALYSIS_SN="$OUTD/$DIS/analysis_SN.dat"
CMD="fgrep -f $OUT_ANALYSIS $CATALOG | cut -f 1,2,3,11 | sort > $OUT_ANALYSIS_SN"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_ANALYSIS_SN

