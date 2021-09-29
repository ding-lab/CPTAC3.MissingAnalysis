# Usage: evaluate_WGS_SV.sh DIS OUTD

# Pipeline-specific definitions

# Processing WGS hg38 on storage1
DAS="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/DCC_Analysis_Summary/WGS_SV.DCC_analysis_summary.dat"
BAMMAP="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/BamMap/storage1.BamMap.dat"
CATALOG_FILTER="grep WGS | grep hg38 "
CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

# OUTD="dat/WGS_SV"

# General scripts

DIS=$1
OUTD=$2

# Assume a specific location for CASES file: cases/DIS.dat
CASES="cases/$DIS.dat"
if [ ! -e $CASES ] ; then
    >&2 echo ERROR: File $CASES does not exist
    exit
fi

ARGS=" -d $DIS -c $CATALOG -a $DAS -b $BAMMAP -o $OUTD -s $CASES -f \"$CATALOG_FILTER\" "

CMD="bash src/get_missing_analyses.sh $ARGS"
>&2 echo Running: $CMD
eval $CMD

