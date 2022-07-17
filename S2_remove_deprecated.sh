# Remove deprecated aliquots and UUIDs based on blacklists provided by Mathangi
# for CPTAC3 catalog work
# Here, loop over all pipelines and diseases to update run_list there

DISEASES_FN="dat/diseases.dat"
INPUT_FN="B_request_run_list.dat"
OUTPUT_FN="C_deprecated.run_list.dat"

# deprecated_uuid and _aliquot created by R2_make_deprecated_list.sh

OUTD="dat"
EXCLUDE_UUID="$OUTD/deprecated_uuid.dat"
EXCLUDE_ALQ="$OUTD/deprecated_aliquot.dat"

PIPELINES="\
RNA-Seq_Expression \
"
#miRNA-Seq \
#Methylation_Array \
#RNA-Seq_Expression \
#RNA-Seq_Fusion \
#RNA-Seq_Transcript \
#WGS_CNV_Somatic \
#WGS_SV \
#WXS_Germline \
#WXS_MSI \
#WXS_Somatic_Variant_TD \
#WXS_Somatic_Variant_SW \
#"

function remove_deprecated {
    P=$1
    XARGS="$2"
    while read DIS; do
        >&2 echo Running $DIS 

        # making some assumptions about output locations
        # Example run list: dat/results/Methylation_Array/PDA/request_run_list.dat
        RL="dat/results/$P/$DIS/$INPUT_FN"
        OUTFN="dat/results/$P/$DIS/$OUTPUT_FN"

        CMD="bash src/remove_deprecated.sh $XARGS -o $OUTFN -Q $EXCLUDE_ALQ -U $EXCLUDE_UUID $RL"
        echo Running: $CMD
        eval $CMD

    done <$DISEASES_FN
}

for PIPELINE in $PIPELINES; do
    >&2 echo Processing deprecated for $PIPELINE
    remove_deprecated $PIPELINE "$@"
done



