# Pipeline-specific definitions
PIPELINE="miRNA-Seq"
SYSTEM="katmai"
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="14"
# unix string for identifying datasets of interest.  See src/get_missing_analyses.sh
CATALOG_FILTER="grep \"miRNA-Seq\" | grep hg38"

SKIP_DAS=0
