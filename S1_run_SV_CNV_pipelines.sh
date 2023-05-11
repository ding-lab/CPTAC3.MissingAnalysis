# Evaluate canonical and requested run lists for all pipelines and diseases
# Writes
# dat/results/PIPELINE/DISEASE/A_canonical_run_list.dat
# dat/results/PIPELINE/DISEASE/B_request_run_list.dat

PIPELINES="\
WGS_CNV_Somatic	\
WGS_SV\
"
#WXS_Somatic_Variant_TD \

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
