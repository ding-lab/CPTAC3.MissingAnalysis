#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: 
    get_download_UUID.sh [ options ]

Options (all options required):
-h: Print this help message
-d DIS : Disease. e.g., LUAD
-b BAMMAP: Path to BamMap file
-s SYSTEM: Name of destination system.  Used for output file creation only
-o OUTD: Output directory

Given a list of cases of interest for one disease, identify the UUIDs which
need to be downloaded to a particular system.  This workflow is UUID (rather
than CASE) centric, so that it can identify analyses to perform even when some
analyses have been performed for that case

This script is meant to be run following `src/get_missing_analyses.sh`, with the output of
that script expected to be in the default location.  This script can be run more than once
with multiple destination systems, but the BamMap and SYSTEM paramaters must match

BamMap files can be found in 
[CPTAC3 Catalog project](https://github.com/ding-lab/CPTAC3.catalog)

Algorithm and outputs
  1. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
     -> Writes out OUTD/DIS/download_UUID.SYSTEM.dat
EOF

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hd:b:s:o:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d) 
      DIS="$OPTARG"
      ;;
    b) 
      BAMMAP="$OPTARG"
      ;;
    s) 
      SYSTEM="$OPTARG"
      ;;
    o) 
      OUTD="$OPTARG"
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

if [ -z $SYSTEM ]; then
    >&2 echo ERROR: -s SYSTEM
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

OUT_ANALYSIS="$OUTD/$DIS/analysis_UUID.dat"

#  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
#     -> Writes out OUTD/DIS/download_UUID.dat
OUT_DOWNLOAD_UUID="$OUTD/$DIS/download_UUID.$SYSTEM.dat"
CMD="comm -23 $OUT_ANALYSIS <(cut -f 10 $BAMMAP | sort) > $OUT_DOWNLOAD_UUID"
>&2 echo Running: $CMD
eval $CMD
test_exit_status
report $OUT_DOWNLOAD_UUID

