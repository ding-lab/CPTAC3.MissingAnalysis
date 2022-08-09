# Loop over all diseases for a specific pipeline

PIPELINE_NAME="RNA-Seq_Fusion"
DISEASES_FN="dat/diseases.dat"

while read DIS; do
    >&2 echo Running $DIS 

    CMD="bash Sx_run_pipeline.sh $PIPELINE_NAME $DIS $@"
    echo Running: $CMD
    eval $CMD

done <$DISEASES_FN


