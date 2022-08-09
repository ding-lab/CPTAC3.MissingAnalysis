# Ad hoc filtering for miRNA-Seq.  See R4_make_oldrun_miRNA.sh
# for details

PIPELINES="\
miRNA-Seq \
"

DISEASES_FN="dat/diseases.dat"

OUTD="dat"


function remove_oldrun {
    P=$1
    XARGS="$2"
    while read DIS; do
        >&2 echo Running $DIS 

        # making some assumptions about output locations
        # Example run list: dat/results/Methylation_Array/PDA/request_run_list.dat
        RL="dat/results/$P/$DIS/D_oldrun.run_list.dat"
        OUTFN="dat/results/$P/$DIS/E_oldrun_miRNA.run_list.dat"

        EXCLUDE_ALQ="dat/results/$P/current_aliquot_list.dat"

        # Need to call something similar to remove oldrun
        CMD="bash src/remove_deprecated.sh $XARGS -o $OUTFN -Q $EXCLUDE_ALQ $RL"
        echo Running: $CMD
        eval $CMD
    done <$DISEASES_FN
}

for PIPELINE in $PIPELINES; do
    >&2 echo Processing oldrun for $PIPELINE
    remove_oldrun $PIPELINE "$@"
done


