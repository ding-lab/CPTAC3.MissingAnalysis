# Usage: evaluate_RNA-Seq_Fusion.sh DIS OUTD

# Pipeline-specific definitions

# Processing RNA-Seq genomic BAMs on katmai
# Will be looking for genomic (hg38) RNA-Seq data 
DAS="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/DCC_Analysis_Summary/RNA-Seq_Fusion.DCC_analysis_summary.dat"
BAMMAP="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/BamMap/katmai.BamMap.dat"
CATALOG_FILTER="grep \"RNA-Seq\" | grep -v miRNA | grep -v hg38"
CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

#OUTD="dat/RNA-Seq_Fusion"

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

