
# Usage: run_pipeline.sh config_script.sh

# This will run script with the following definitions, which will then be used to remainder
# Pretty fragile

CONFIG=$1
>&2 echo Sourcing $CONFIG
source $CONFIG

# Typical definitions - 
OUTD="dat/$PIPELINE"
CATALOGD="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog" # works for katmai
DAS="$CATALOGD/DCC_Analysis_Summary/$PIPELINE.DCC_analysis_summary.dat"
BAMMAP="$CATALOGD/BamMap/${SYSTEM}.BamMap.dat"
CATALOG="$CATALOGD/CPTAC3.Catalog.dat"
DISEASES_FN="dat/diseases.dat"

if [ $SKIP_DAS != 1 ]; then
    DAS_ARG="-D $DAS"
fi

ARGS="-c $DCC_UUID_COL $DAS_ARG -B $BAMMAP -C $CATALOG -F \"$CATALOG_FILTER\" -o $OUTD -s $SYSTEM"

while read DIS; do
    >&2 echo Running $DIS
    CASES="dat/cases/$DIS.dat"
    ARGS_DIS=" -d $DIS -S $CASES"

    CMD="bash src/evaluate_analysis_status.sh $ARGS $ARGS_DIS "
    >&2 echo Running: $CMD
    eval $CMD
done <$DISEASES_FN

>&2 echo Summary
>&2 echo $PIPELINE UUID to run
wc -l $OUTD/*/analysis_SN.dat
>&2 echo $PIPELINE files to download
wc -l $OUTD/*/download_UUID.*.dat
