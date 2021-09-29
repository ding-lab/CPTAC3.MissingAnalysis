#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: 
    get_missing_analyses.sh [ options ]

Options (all options required):
-h: Print this help message
-d DIS : Disease. e.g., LUAD
-c CATALOG: Path to catalog file.  
-a DAS: Path to data analysis summary file
-b BAMMAP: Path to BamMap file
-o OUTD: Output directory
-s CASES: Path to file listing cases of interest
-f CATALOG_FILTER: string used to filter contents of catalog file for this analysis.  See below

Catalog, data analysis summary, and BamMap files can be found in 
[CPTAC3 Catalog project](https://github.com/ding-lab/CPTAC3.catalog)

CATALOG_FILTER is string in the form of unix pipes which identifies entries in catalog file 
  necessary for this analysis.  Example:
      CATALOG_FILTER="grep WXS | grep hg38 | grep -v tissue_normal"
  And the relevant lines in catalog file are identified with something like `cat CATALOG | CATALOG_FILTER`
  Note that in some cases it may be necessary to filter catalog file more precisely by using e.g. awk
  to evaluate particular fields 

Algorithm and outputs
  0. we are given list of cases of interest (-s CASES)
  1. Get all cases of a disease which have been analyzed (analyzed cases)
     -> Writes out OUTD/DIS/analyzed_cases.dat
  2. Find target cases as difference between cases of interest and analyzed cases
     -> Writes out OUTD/DIS/target_cases.dat
  3. Find cases to analyze as target cases which have data available at GDC (analysis cases)
     -> Writes out OUTD/DIS/analysis_cases.dat
  4. Find UUIDs associated with data required for processing of analysis cases (analysis UUID)
     -> Writes out OUTD/DIS/analysis_UUID.dat
  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
     -> Writes out OUTD/DIS/download_UUID.dat
EOF

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hd:c:a:b:o:s:f:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d) 
      DIS="$OPTARG"
      ;;
    c) 
      CATALOG="$OPTARG"
      ;;
    a) 
      DAS="$OPTARG"
      ;;
    b) 
      BAMMAP="$OPTARG"
      ;;
    o) 
      OUTD="$OPTARG"
      ;;
    s) 
      CASES="$OPTARG"
      ;;
    f) 
      CATALOG_FILTER="$OPTARG"
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

if [ -z $DIS ]; then
    >&2 echo ERROR: -d DIS
    >&2 echo "$USAGE"
    exit
fi

if [ -z $CATALOG ]; then
    >&2 echo ERROR: -c CATALOG
    >&2 echo "$USAGE"
    exit
fi
if [ ! -e $CATALOG ] ; then
    >&2 echo ERROR: File not found: CATALOG $CATALOG 
    exit
fi

if [ -z $DAS ]; then
    >&2 echo ERROR: -a DAS
    >&2 echo "$USAGE"
    exit
fi
if [ ! -e $DAS ] ; then
    >&2 echo ERROR: File not found: DAS $DAS 
    exit
fi

if [ -z $BAMMAP ]; then
    >&2 echo ERROR: -b BAMMAP
    >&2 echo "$USAGE"
    exit
fi
if [ ! -e $BAMMAP ] ; then
    >&2 echo ERROR: File not found: BAMMAP $BAMMAP 
    exit
fi

if [ -z $OUTD ]; then
    >&2 echo ERROR: -o OUTD
    >&2 echo "$USAGE"
    exit
fi

if [ -z $CASES ]; then
    >&2 echo ERROR: -s CASES
    >&2 echo "$USAGE"
    exit
fi
if [ ! -e $CASES ] ; then
    >&2 echo ERROR: File not found: CASES $CASES 
    exit
fi

if [ -z "$CATALOG_FILTER" ]; then
    >&2 echo ERROR: -f CATALOG_FILTER
    >&2 echo "$USAGE"
    exit
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

mkdir -p $OUTD/$DIS

#  0. we are given list of cases of interest (-s CASES)
#  1. Get all cases of a disease which have been analyzed (analyzed cases)
#     -> Writes out OUTD/DIS/analyzed_cases.dat
#  2. Find target cases as difference between cases of interest and analyzed cases
#     -> Writes out OUTD/DIS/target_cases.dat
#  3. Find cases to analyze as target cases which have data available at GDC (analysis cases)
#     -> Writes out OUTD/DIS/analysis_cases.dat
#  4. Find UUIDs associated with data required for processing of analysis cases (analysis UUID)
#     -> Writes out OUTD/DIS/analysis_UUID.dat
#  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
#     -> Writes out OUTD/DIS/download_UUID.dat

#  1. Get all cases of a disease which have been analyzed
OUT_ANALYZED="$OUTD/$DIS/analyzed_cases.dat"
CMD="awk -v dis=$DIS 'BEGIN{FS=\"\t\";OFS=\"\t\"}{if (\$2 == dis ) print \$1}' $DAS | cut -f 1 | sort -u > $OUT_ANALYZED"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_ANALYZED 

# 2. Find those cases of interest which are not in list of analyzed cases
# i.e., find cases in interest and analyzed lists unique to interest
OUT_TARGET="$OUTD/$DIS/target_cases.dat"
CMD="comm -23 $CASES $OUT_ANALYZED  > $OUT_TARGET"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_TARGET

# 3. Now make a list of those cases which we want which also have data available
# this is the list of cases of interest not yet analyzed available at GDC
# and is the list of new analyses we want to do
OUT_TO_ANALYZE="$OUTD/$DIS/analysis_cases.dat"
CMD="grep -f $OUT_TARGET $CATALOG | $CATALOG_FILTER | cut -f 2 | sort -u > $OUT_TO_ANALYZE"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_TO_ANALYZE

# 4. Next, get list of all UUIDs associated with relevant data for cases to analyze
OUT_TO_ANALYZE_UUID="$OUTD/$DIS/analysis_UUID.dat"
CMD="grep -f $OUT_TO_ANALYZE $CATALOG | $CATALOG_FILTER | cut -f 11 | sort -u > $OUT_TO_ANALYZE_UUID"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_TO_ANALYZE_UUID

# 5. Finally, get UUIDs to download - those on UUIDs to analyze not on system of interest
# This is those UUIDs unique to cases_to_analyze_UUID not in bammap
OUT_TO_DOWNLOAD_UUID="$OUTD/$DIS/download_UUID.dat"
CMD="comm -23 $OUT_TO_ANALYZE_UUID <(cut -f 10 $BAMMAP | sort) > $OUT_TO_DOWNLOAD_UUID"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_TO_DOWNLOAD_UUID
