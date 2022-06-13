# Usage: evaluate_RNA-Seq_Fusion.sh DIS OUTD

# Pipeline-specific definitions
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="12,14" 
SYSTEM="storage1"

# Processing RNA-Seq genomic BAMs on katmai
# Will be looking for genomic (hg38) RNA-Seq data 
DAS="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/DCC_Analysis_Summary/RNA-Seq_Fusion.DCC_analysis_summary.dat"
BAMMAP="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/BamMap/${SYSTEM}.BamMap.dat"
CATALOG_FILTER="grep \"RNA-Seq\" | grep -v miRNA | grep -v hg38"
CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

# General scripts

DIS=$1
OUTD=$2

if [ -z $DIS ]; then
    >&2 echo ERROR: DIS not specified
    exit 1
fi
if [ -z $OUTD ]; then
    >&2 echo ERROR: OUTD not specified
    exit 1
fi

# Assume a specific location for CASES file: dat/DIS.dat
CASES="dat/cases/$DIS.dat"
if [ ! -e $CASES ] ; then
    >&2 echo ERROR: File $CASES does not exist
    exit
fi

ARGS=" -d $DIS -c $CATALOG -a $DAS -o $OUTD -s $CASES -f \"$CATALOG_FILTER\" -G $DCC_UUID_COL -D"
CMD="bash src/get_missing_analyses.sh $ARGS"
>&2 echo Running: $CMD
eval $CMD

ARGS=" -d $DIS -o $OUTD -b $BAMMAP -s $SYSTEM"
CMD="bash src/get_download_UUID.sh $ARGS"
>&2 echo Running: $CMD
eval $CMD
