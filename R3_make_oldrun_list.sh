# Make a list of aliquots associated with past analyses.
# This was originally meant to deal with gencode 22 / 36 transition, where
# we wish to exclude from analysis datafile pairs which were already
# processed as gencode 22.  This is done by matching aliquots
# Currently using it to make association between submitted and harmonized datasets
#
# Runs once per pipeline
# 
# Starting with per-pipeline DCC analysis summary file,
#  * Extract UUID or UUID pair for that run
#  * Based on GraphQL CPTAC3 catalog, convert UUIDs to aliquots
#    * this catalog is that used around the time of analysis

# Write file dat/result/PIPELINE/oldrun_aliquot_list.dat

CATALOG_ROOT="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3"
GQL_CATALOG="$CATALOG_ROOT/DLBCL.Catalog3.tsv"
#CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/synapse_files/dat/DLBCL.GDC_REST.20230409-AWG.hdWGS.tsv"

OUTD="dat"
mkdir -p $OUTD

PWD=$(pwd)

#PIPELINES="\
#WGS_Somatic_Variant_TD \
#"

PIPELINES="\
WGS_CNV_Somatic	\
WGS_SV\
"

PIPELINE_CONFIG_FN="$PWD/config/pipeline_config.tsv"


function process_oldrun {
    P=$1
    XARGS="$2"
    DAS="$PWD/AnalysisSummaryLinks/${PIPELINE}.AnalysisSummary.dat"

    # making some assumptions about output locations
    # Example run list: dat/results/Methylation_Array/PDA/request_run_list.dat
    OLDRUN_LIST="oldrun_aliquot_list.dat"
    OUTFN="dat/results/$PIPELINE/$OLDRUN_LIST"

    CMD="bash src/get_oldrun_list.sh $XARGS -C $GQL_CATALOG -o $OUTFN -p $PIPELINE -P $PIPELINE_CONFIG_FN -D $DAS"
    echo Running: $CMD
    eval $CMD
}

for PIPELINE in $PIPELINES; do
    >&2 echo Processing oldrun for $PIPELINE
    process_oldrun $PIPELINE "$@"
done
