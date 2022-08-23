# Remove from Run Lists all cases which are listed in Mathangi's stopped cases list.
# for discussion see /Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/20220809.StoppedCases/README.md

STOPPED_CASE_LIST="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/20220809.StoppedCases/stopped_cases_clean.txt"

# This will not need to be done in the future since these cases have now been removed from the CPTAC3.cases.dat file
# and will disappear on next discovery
# Source run lists: Results/compute1-results/results-AML-GBM
# destination run lists: Results/run_list

# Also removing specific case C3L-06368

PIPELINES="\
miRNA-Seq \
Methylation_Array \
RNA-Seq_Expression \
RNA-Seq_Fusion \
RNA-Seq_Transcript \
WGS_CNV_Somatic \
WGS_SV \
WXS_Germline \
WXS_MSI \
WXS_Somatic_Variant_TD \
WXS_Somatic_Variant_SW \
"
IND="Results/compute1-results/results-AML-GBM"
OUTD="Results/run_list"
mkdir -p $OUTD

for PIPELINE in $PIPELINES; do
    >&2 echo Processing oldrun for $PIPELINE
    IN=$IND/${PIPELINE}.run_list.tsv
    OUT=$OUTD/${PIPELINE}.run_list.tsv

    CMD="grep -v -f $STOPPED_CASE_LIST $IN | grep -v C3L-06368 > $OUT"
    >&2 echo Running: $CMD
    eval $CMD

done


