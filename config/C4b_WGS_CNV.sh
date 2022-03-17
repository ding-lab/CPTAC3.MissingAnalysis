# Pipeline-specific definitions
PIPELINE="WGS_CNV_Somatic"
SYSTEM="storage1"
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="12,14"
# unix string for identifying datasets of interest.  See src/get_missing_analyses.sh
CATALOG_FILTER="grep WGS | grep hg38 | grep -v tissue_normal"  # We don't care about tissue normal, only blood normal

SKIP_DAS=0

