# Pipeline-specific definitions
PIPELINE="WXS_Germline"
SYSTEM="MGI"
# here, specify which columns in DCC analysis summary files have the UUIDs
DCC_UUID_COL="12"
# unix string for identifying datasets of interest.  See src/get_missing_analyses.sh
CATALOG_FILTER="grep WXS | grep hg38 | grep normal | grep -v tissue_normal "    # normal will work for AML as well

SKIP_DAS=0

