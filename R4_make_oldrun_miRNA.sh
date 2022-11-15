# Deal with special case of miRNA and make past runs from current catalog
# Generally, miRNA uses unaligned data.  In some cases hg38 data was used,
# and we don't want to rerun.  Aliquot matching like for oldrun will work,
# but the catalog needs to be current to incorporate all data
# Here, creating "current aliquot list" from today's catalog (v2) which will be used
# for such miRNA-Seq filtering.  Note, miRNA-Seq unaligned data will not suffer from v22/36 conversion, I think

#CATALOG_ROOT="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
CATALOG_ROOT="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog"
CATALOG="$CATALOG_ROOT/CPTAC3.Catalog.dat"
OLDRUN_LIST="current_aliquot_list.dat"
OUTD="dat"
mkdir -p $OUTD

PIPELINES="\
miRNA-Seq \
"

PIPELINE_CONFIG_FN="config/pipeline_config.tsv"


function process_oldrun {
    P=$1
    XARGS="$2"
    DAS="$CATALOG_ROOT/DCC_Analysis_Summary/${PIPELINE}.DCC_analysis_summary.dat"
    #DAS="dat/AS_Expression_C3N-01817.dat"

    # making some assumptions about output locations
    # Example run list: dat/results/Methylation_Array/PDA/request_run_list.dat
    OUTFN="dat/results/$PIPELINE/$OLDRUN_LIST"

    CMD="bash src/get_oldrun_list.sh $XARGS -C $CATALOG -o $OUTFN -p $PIPELINE -P $PIPELINE_CONFIG_FN -D $DAS"
    echo Running: $CMD
    eval $CMD
}

for PIPELINE in $PIPELINES; do
    >&2 echo Processing oldrun for $PIPELINE
    process_oldrun $PIPELINE "$@"
done
