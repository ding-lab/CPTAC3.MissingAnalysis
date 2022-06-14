#CATALOG: Path to catalog3 file. Required 
#OUTD: Output directory.  Required.  May be per-disease
#CASES_FN: Path to file listing cases of interest.  Required
#PIPELINE_NAME: canonical name of pipeline we are evaluating.  Required
#PIPELINE_CONFIG_FN: configuration file with per-pipeline definitions.  Required
#DAS: Path to data analysis summary file.  If not defined, request run list is canonical run list

PIPELINE_NAME="RNA-Seq_Expression"
CATALOG="testing/testdata/C3L-0001x.Catalog3.tsv"
OUTD="dat/$PIPELINE_NAME"
CASES_FN="config/cases.dat"
PIPELINE_CONFIG_FN="config/pipeline_config.dat"
DAS="testing/testdata/unpaired.DCC_analysis_summary.dat"

# -C CATALOG: Path to catalog3 file. Required 
# -o OUTD: Output directory.  Required.  May be per-disease
# -s CASES_FN: Path to file listing cases of interest.  Required
# -p PIPELINE_NAME: canonical name of pipeline we're evaluating.  Required
# -P PIPELINE_CONFIG_FN: configuration file with per-pipeline definitions.  Required
# -D DAS: Path to data analysis summary file.  If not defined, request run list is canonical run list

# skipping -D for now
CMD="bash src/get_request_run_list.sh -C $CATALOG -o $OUTD -s $CASES_FN -p $PIPELINE_NAME -P $PIPELINE_CONFIG_FN -D $DAS"
echo Running: $CMD
eval $CMD

