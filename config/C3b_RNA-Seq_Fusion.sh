# Pipeline-specific definitions
PIPELINE="RNA-Seq_Fusion"
SYSTEM="storage1"
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="12,14" 
# unix string for identifying datasets of interest.  See src/get_missing_analyses.sh
CATALOG_FILTER="grep \"RNA-Seq\" | grep -v miRNA | grep -v hg38"

SKIP_DAS=0