# Obtain canonical and request run lists for a specific pipeline for all diseases
# This sets up general output directory structure

PIPELINE_NAME=$1
DIS=$2

CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/Catalog3/CPTAC3.Catalog3.tsv"
PIPELINE_CONFIG_FN="config/pipeline_config.tsv"
DAS="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/DCC_Analysis_Summary/$PIPELINE_NAME.DCC_analysis_summary.dat"

CASES_FN="dat/cases/$DIS.dat"
OUTD="dat/results/$PIPELINE_NAME/$DIS"
mkdir -p $OUTD

# -C CATALOG: Path to catalog3 file. Required 
# -o OUTD: Output directory.  Required.  May be per-disease
# -s CASES_FN: Path to file listing cases of interest.  Required
# -p PIPELINE_NAME: canonical name of pipeline we're evaluating.  Required
# -P PIPELINE_CONFIG_FN: configuration file with per-pipeline definitions.  Required
# -D DAS: Path to data analysis summary file.  If not defined, request run list is canonical run list

CMD="bash src/get_request_run_list.sh -C $CATALOG -o $OUTD -s $CASES_FN -p $PIPELINE_NAME -P $PIPELINE_CONFIG_FN -D $DAS"
echo Running: $CMD
eval $CMD




