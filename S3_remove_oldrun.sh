# Remove deprecated aliquots and UUIDs based on blacklists provided by Mathangi
# for CPTAC3 catalog work

#PIPELINES="\
#WGS_Somatic_Variant_TD \
#"
PIPELINES="\
WGS_CNV_Somatic	\
WGS_SV\
"

DISEASES_FN="dat/diseases.dat"

OUTD="dat"

PWD=$(pwd)

function remove_oldrun {
    P=$1
    XARGS="$2"
    while read DIS; do
        >&2 echo Running $DIS 

        # making some assumptions about output locations
        # Example run list: dat/results/Methylation_Array/PDA/request_run_list.dat
        #RL="dat/results/$P/$DIS/C_deprecated.run_list.dat"
        RL="$PWD/dat/results/$P/$DIS/B_request_run_list.dat"
        OUTFN="$PWD/dat/results/$P/$DIS/D_oldrun.run_list.dat"

        EXCLUDE_ALQ="dat/results/$P/oldrun_aliquot_list.dat"

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


