# Loop over all diseases for a specific pipeline

PIPELINE_NAME="WGS_SV"
DISEASES_FN="dat/diseases.dat"

while read DIS; do
    >&2 echo Running $DIS 

    CMD="bash Sx_run_pipeline.sh $PIPELINE_NAME $DIS $@"
    echo Running: $CMD
    eval $CMD

done <$DISEASES_FN



