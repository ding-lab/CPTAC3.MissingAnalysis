# Remove deprecated aliquots and UUIDs based on blacklists provided by Mathangi
# for CPTAC3 catalog work

PIPELINE_NAME="RNA-Seq_Expression"
DISEASES_FN="dat/diseases.dat"

OUTD="dat"
EXCLUDE_ALQ="dat/results/$PIPELINE_NAME/oldrun_aliquot_list.dat"


while read DIS; do
    >&2 echo Running $DIS 

    # making some assumptions about output locations
    # Example run list: dat/results/Methylation_Array/PDA/request_run_list.dat
    RL="dat/results/$PIPELINE_NAME/$DIS/C_deprecated.run_list.dat"
    OUTFN="dat/results/$PIPELINE_NAME/$DIS/D_oldrun.run_list.dat"

    # Need to call something similar to remove oldrun
    CMD="bash src/remove_deprecated.sh $@ -o $OUTFN -Q $EXCLUDE_ALQ $RL"
    echo Running: $CMD
#    eval $CMD

done <$DISEASES_FN



