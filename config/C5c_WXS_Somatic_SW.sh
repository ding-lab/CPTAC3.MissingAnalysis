# Pipeline-specific definitions
PIPELINE="WXS_Somatic_Variant_SW"
SYSTEM="MGI"
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="12,14"
# unix string for identifying datasets of interest.  See src/get_missing_analyses.sh
CATALOG_FILTER="grep WXS | grep hg38 | grep -v tissue_normal"

SKIP_DAS=0

