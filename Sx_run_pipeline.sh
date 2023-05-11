# Obtain canonical and request run lists for a specific pipeline for all diseases
# This sets up general output directory structure

PIPELINE_NAME=$1
DIS=$2

shift 2
XARGS="$@"

# This is general purpose catalog of all datasets
#CATALOG_ROOT="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3"
#CATALOG="$CATALOG_ROOT/DLBCL.GDC_REST.20230409-AWG.tsv"

# This is for high depth WGS catalog to create all run pairs
CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/config/DLBCL.GDC_REST.20230409-AWG.hdWGS.tsv"

PIPELINE_CONFIG_FN="config/pipeline_config.tsv"

# custom / ad hoc analysis summary
#DAS="$CATALOG_ROOT/DCC_Analysis_Summary/$PIPELINE_NAME.DCC_analysis_summary.dat"
DAS="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/AnalysisSummaryLinks/$PIPELINE_NAME.AnalysisSummary.dat"


DAS_ARG="-D $DAS"

# Add aliquot info to all output
ARGS="-q"

CASES_FN="dat/cases/${DIS}-cases.dat"
#CASES_FN="dat/cases/test-cases.dat"
OUTD="dat/results/$PIPELINE_NAME/$DIS"
mkdir -p $OUTD

# -C CATALOG: Path to catalog3 file. Required 
# -o OUTD: Output directory.  Required.  May be per-disease
# -s CASES_FN: Path to file listing cases of interest.  Required
# -p PIPELINE_NAME: canonical name of pipeline we're evaluating.  Required
# -P PIPELINE_CONFIG_FN: configuration file with per-pipeline definitions.  Required
# -D DAS: Path to data analysis summary file.  If not defined, request run list is canonical run list

CMD="bash src/get_request_run_list.sh $ARGS -C $CATALOG -o $OUTD -s $CASES_FN -p $PIPELINE_NAME -P $PIPELINE_CONFIG_FN $DAS_ARG $XARGS"
echo Running: $CMD
eval $CMD




