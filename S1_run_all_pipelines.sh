# Evaluate canonical and requested run lists for all pipelines and diseases
# Writes
# dat/results/PIPELINE/DISEASE/A_canonical_run_list.dat
# dat/results/PIPELINE/DISEASE/B_request_run_list.dat

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

DISEASES_FN="dat/diseases.dat"

function process_pipeline {
    P=$1
    XARGS="$2"
    while read DIS; do
        >&2 echo Running $DIS 

        CMD="bash Sx_run_pipeline.sh $P $DIS $XARGS"
        echo Running: $CMD
        eval $CMD

    done <$DISEASES_FN
}

for PIPELINE in $PIPELINES; do
    >&2 echo Processing oldrun for $PIPELINE
    process_pipeline $PIPELINE "$@"
done
