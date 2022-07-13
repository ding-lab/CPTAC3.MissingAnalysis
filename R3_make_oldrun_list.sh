# Make a list of aliquots associated with past analyses.
# This is meant to deal with gencode 22 / 36 transition, where
# we wish to exclude from analysis datafile pairs which were already
# processed as gencode 22.  This is done by matching aliquots
# 
# Starting with per-pipeline DCC analysis summary file,
#  * Extract UUID or UUID pair for that run
#  * Based on old CPTAC3 v2 catalog, convert UUIDs to aliquots
#    * this catalog is that used around the time of analysis

# Write file dat/result/PIPELINE/oldrun_aliquot_list.dat

CATALOG="config/CPTAC3.Catalog-f7b28ac.dat"
OUTD="dat"
mkdir -p $OUTD

PIPELINE="RNA-Seq_Expression"
PIPELINE_CONFIG_FN="config/pipeline_config.tsv"

CATALOG_ROOT="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
DAS="$CATALOG_ROOT/DCC_Analysis_Summary/${PIPELINE}.DCC_analysis_summary.dat"
#DAS="dat/AS_Expression_C3N-01817.dat"

# making some assumptions about output locations
# Example run list: dat/results/Methylation_Array/PDA/request_run_list.dat
OUTFN="dat/results/$PIPELINE/oldrun_aliquot_list.dat"

CMD="bash src/get_oldrun_list.sh $@ -C $CATALOG -o $OUTFN -p $PIPELINE -P $PIPELINE_CONFIG_FN -D $DAS"
echo Running: $CMD
eval $CMD





