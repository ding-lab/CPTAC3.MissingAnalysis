DISEASES_FN="dat/diseases.dat"
OUTD="dat/RNA-Seq_Expression"


# From src/evaluate_RNA-Seq_Expression.sh

## Usage: evaluate_RNA-Seq_Expression.sh DIS OUTD IGNORE_DAS
#
## If any value is specified for IGNORE_DAS, will ignore previous analyses
#
## Pipeline-specific definitions
## here, specify which columns in DCC analysis summary files have the UUIDs
#DCC_UUID_COL="12" 
#SYSTEM="storage1"
#
## Processing RNA-Seq genomic BAMs on katmai
## Will be looking for genomic (hg38) RNA-Seq data 
#DAS="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/DCC_Analysis_Summary/RNA-Seq_Expression.DCC_analysis_summary.dat"
#BAMMAP="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/BamMap/${SYSTEM}.BamMap.dat"
#CATALOG_FILTER="grep \"RNA-Seq\" | grep -v miRNA | grep genomic"
#CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"
#
#
#DIS=$1
#OUTD=$2
#IGNORE_DAS=$3

# TODO: the above describes the arguments to src/evaluate_analysis_status.sh

while read DIS; do
    echo Running $DIS
    bash src/evaluate_RNA-Seq_Expression.sh $DIS $OUTD IGNORE_PAST_RUNS
done <$DISEASES_FN

echo Summary
echo RNA-Seq Expression UUID to run
wc -l $OUTD/*/analysis_SN.dat
echo RNA-Seq Expression files to download
wc -l $OUTD/*/download_UUID.*.dat
