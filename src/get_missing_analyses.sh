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
-G UUID_COL: comma-separated list of integers which identify columns having UUIDs in DAS
   e.g., -G 12,14.  Default: 12

Given a list of cases of interest for one disease, identify the UUIDs for which
analyses need to be performed and the UUIDs which need to be downloaded to a
particular system.  This workflow is UUID (rather than CASE) centric, so that
it can identify analyses to perform even when some analyses have been performed
for that case

Catalog, data analysis summary, and BamMap files can be found in 
[CPTAC3 Catalog project](https://github.com/ding-lab/CPTAC3.catalog)

CATALOG_FILTER is string in the form of unix pipes which identifies entries in catalog file 
  necessary for this analysis.  Example:
      CATALOG_FILTER="grep WXS | grep hg38 | grep -v tissue_normal"
  And the relevant lines in catalog file are identified with something like `cat CATALOG | CATALOG_FILTER`
  Note that in some cases it may be necessary to filter catalog file more precisely by using e.g. awk
  to evaluate particular fields 

For pipelines which take two UUIDs as input (either tumor/normal, or red/green for Methylation),
-G flag allows both to be obtained from analysis summary file (columns 12 and 14)

Algorithm and outputs
  1. we are given list of cases of interest (-s CASES)
  2. Identify all UUIDs associated with cases of interest (UUIDs of interest)
  3. Get all UUIDs which have been analyzed (analyzed UUIDs)
     -> Based on data analysis summary file
     -> tumor/normal pipelines parsed to capture both input UUIDs
     -> Writes out OUTD/DIS/analyzed_UUIDs.dat
  4. Find analysis UUIDs as difference between UUIDs of interest and analyzed UUIDs
     -> These are the UUIDs which are to be analyzed
     -> Writes out OUTD/DIS/analysis_UUIDs.dat
  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
     -> Writes out OUTD/DIS/download_UUID.dat
EOF

UUID_COL="12"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hd:c:a:b:o:s:f:G:" opt; do
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
    G) 
      UUID_COL="$OPTARG"
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

#  1. we are given list of cases of interest (-s CASES)
#  2. Identify all UUIDs associated with cases of interest (UUIDs of interest)
#  3. Get all UUIDs which have been analyzed (analyzed UUIDs)
#     -> Based on data analysis summary file
#     -> capture all input UUIDs
#     -> Writes out OUTD/DIS/analyzed_UUIDs.dat
#  4. Find analysis UUIDs as difference between UUIDs of interest and analyzed UUIDs
#     -> These are the UUIDs which are to be analyzed
#     -> Writes out OUTD/DIS/analysis_UUIDs.dat
#  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
#     -> Writes out OUTD/DIS/download_UUID.dat


#  2. Identify all UUIDs associated with cases of interest (UUIDs of interest)
#     Find all appropriate datasets (as determined by CATALOG_FILTER) whose case is in CASES file
#     and extract the UUID
#     Using AWK to evaluate case field ($2) of CATALOG file
# https://stackoverflow.com/questions/42851582/find-in-word-from-one-file-to-another-file-using-awk-nr-fnr

UUIDS_OF_INTEREST="$OUTD/$DIS/UUIDs_of_interest.dat"
CMD="awk 'FNR==NR{a[\$0];next} (\$2 in a) {print \$0}' $CASES $CATALOG | $CATALOG_FILTER | cut -f 11 | sort -u > $UUIDS_OF_INTEREST"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $UUIDS_OF_INTEREST

#  3. Get all UUIDs which have been analyzed (analyzed UUIDs)
OUT_ANALYZED="$OUTD/$DIS/analyzed_UUIDs.dat"
CMD="awk -v dis=$DIS 'BEGIN{FS=\"\t\";OFS=\"\t\"}{if (\$2 == dis ) print }' $DAS | cut -f $UUID_COL | tr '\t' '\n' | sort -u > $OUT_ANALYZED"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_ANALYZED 

#  4. Find analysis UUIDs as difference between UUIDs of interest and analyzed UUIDs
#     -> These are the UUIDs which are to be analyzed
#     -> Writes out OUTD/DIS/analysis_UUIDs.dat
OUT_ANALYSIS="$OUTD/$DIS/analysis_UUIDs.dat"
CMD="comm -23 $UUIDS_OF_INTEREST $OUT_ANALYZED  > $OUT_ANALYSIS"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_ANALYSIS

#  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
#     -> Writes out OUTD/DIS/download_UUID.dat
OUT_DOWNLOAD_UUID="$OUTD/$DIS/download_UUID.dat"
CMD="comm -23 $OUT_ANALYSIS <(cut -f 10 $BAMMAP | sort) > $OUT_DOWNLOAD_UUID"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_DOWNLOAD_UUID

