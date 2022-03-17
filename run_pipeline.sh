
#PIPELINE="RNA-Seq_Expression"
#SYSTEM="storage1"
#DCC_UUID_COL="12" 
#CATALOG_FILTER="grep \"RNA-Seq\" | grep -v miRNA | grep genomic"
#SKIP_DAS=1

# Usage: run_pipeline.sh config_script.sh

# This will run script with the following definitions, which will then be used to remainder
# Pretty fragile

CONFIG=$1
>&2 echo Sourcing $CONFIG
source $CONFIG


# Typical definitions - 
OUTD="dat/$PIPELINE"
CATALOGD="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/" # works for katmai
DAS="$CATALOGD/DCC_Analysis_Summary/$PIPELINE.DCC_analysis_summary.dat"
BAMMAP="$CATALOGD/BamMap/${SYSTEM}.BamMap.dat"
CATALOG="$CATALOGD/CPTAC3.Catalog.dat"
DISEASES_FN="dat/diseases.dat"

if [ ! $SKIP_DAS ]; then
    DAS_ARG="-D $DAS"
fi

ARGS="-c $DCC_UUID_COL $DAS_ARG -B $BAMMAP -C $CATALOG -F \"$CATALOG_FILTER\" -o $OUTD -s $SYSTEM"


#-h: Print this help message
#-c DCC_UUID_COL: specify which columns in DCC analysis summary files have the UUIDs (e.g., '12' or '12,14').  Required
#-D DAS: Data analysis summary file to identify which analyses already performed.  Skip this step if not provided
#-B BAMMAP: Path to BamMap file.  Required
#-C CATALOG: Path to Catalog file.  Required
#-F CATALOG_FILTER: Filter commands to perform to identify appropriate entries.  See src/get_missing_analyses.sh
#-o OUTD: Ouput directory base.  Default: ./dat  (typically, e.g., "dat/RNA-Seq_Expression")
#-d DIS: disease, e.g., LUAD.  Required
#-S CASES: path to CASES file.  Default dat/cases.dat (typically, e.g., "dat/cases/$DIS.dat")
#-s SYSTEM: Name of destination system.  Used for output file creation only

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
