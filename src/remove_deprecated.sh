#!/bin/bash
# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: 
    remove_deprecated.sh [ options ] run_list

Options (all options required):
-h: Print this help message
-d: print debug messages
-Q exclude_list_aliquot: list of aliquots to exclude
-U exclude_list_uuid: list of uuids to exclude
-o output: output runlist file ID.  Required

Remove all UUIDs or aliquots which are listed in exclude_list from run_list
EOF

PYTHON="python3"
XARGS="" # arguments passed to make_canonical_run_list.py
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdo:Q:U:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)
      DEBUG="-d"
      ;;
    o) 
      OUTFN="$OPTARG"
      ;;
    Q) 
      EXCLUDE_LIST_ALIQUOT="$OPTARG"
      ;;
    U) 
      EXCLUDE_LIST_UUID="$OPTARG"
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

if [ -z "$OUTFN" ]; then
    >&2 echo ERROR: Output file not specified
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

RL=$1
if [ ! -f $RL ]; then
    >&2 echo ERROR: RunList $RL does not exist
    exit 1
fi

# First exclude by aliquot, then UUID
# writing a temp file
OUTD=$(dirname "$OUTFN")
TMP="$OUTD/readlist.tmp"

if [ ! -z "$EXCLUDE_LIST_ALIQUOT" ]; then
    CMD="$PYTHON src/refine_run_list.py -X $EXCLUDE_LIST_ALIQUOT -o $TMP $RL "
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
else
    >&2 echo NOTE: EXCLUDE_LIST_ALIQUOT not specified.  Copying $RL to $TMP
    cp $RL $TMP
    test_exit_status
fi

if [ ! -z "$EXCLUDE_LIST_UUID" ]; then
    CMD="$PYTHON src/refine_run_list.py -X $EXCLUDE_LIST_UUID -o $OUTFN $TMP "
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
else
    >&2 echo NOTE: EXCLUDE_LIST_UUID not specified.  Copying $TMP to $OUTFN
    cp $TMP $OUTFN
    test_exit_status
fi

if [ -z "$DEBUG" ]; then
    CMD="rm -f $TMP"
    >&2 echo Running: $CMD
    eval $CMD
else
    >&2 echo Retaining temp file $TMP
fi

>&2 echo Written to $OUTFN
