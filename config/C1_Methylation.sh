# Pipeline-specific definitions
PIPELINE="Methylation_Array"
SYSTEM="katmai"
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="12,14"
# unix string for identifying datasets of interest.  See src/get_missing_analyses.sh
CATALOG_FILTER="grep Methylation"

SKIP_DAS=0

