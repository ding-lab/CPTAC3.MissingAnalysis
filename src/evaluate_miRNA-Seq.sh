# Usage: evaluate_miRNA-Seq.sh DIS OUTD

# Pipeline-specific definitions
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="13"

# Processing miRNA-Seq data.  Typically on katmai
# Will be looking for aligned (hg38) miRNA-Seq data
DAS="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/DCC_Analysis_Summary/miRNA-Seq.DCC_analysis_summary.dat"
BAMMAP="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/BamMap/katmai.BamMap.dat"
CATALOG_FILTER="grep \"miRNA-Seq\" | grep hg38"
CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

# General scripts

DIS=$1
OUTD=$2

# Assume a specific location for CASES file: dat/DIS.dat
CASES="dat/$DIS.dat"
if [ ! -e $CASES ] ; then
    >&2 echo ERROR: File $CASES does not exist
    exit
fi

ARGS=" -d $DIS -c $CATALOG -a $DAS -b $BAMMAP -o $OUTD -s $CASES -f \"$CATALOG_FILTER\" -G $DCC_UUID_COL -D"

CMD="bash src/get_missing_analyses.sh $ARGS"
>&2 echo Running: $CMD
eval $CMD

