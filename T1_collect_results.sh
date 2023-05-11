# Collect results for all diseases per pipeline into file which can be imported into a spreadsheet
# For all pipelines except miRNA, final run list in dat/results/PIPELINE/DISEASE/D_oldrun.run_list.dat
# For miRNA, final run list in dat/results/miRNA-Seq/DISEASE/E_oldrun_miRNA.run_list.dat
# For each pipeline, loop over all diseases and write out results/PIPELINE.run_list.dat
# Add a leading column named "disease".  Also changing "run_metadata" to "case" for ease of interpretation

PIPELINES_B="\
WXS_Somatic_Variant_TD \
"
PIPELINES_D="\
WGS_Somatic_Variant_TD \
"

BFN="B_request_run_list.dat"
DFN="D_oldrun.run_list.dat"

DISEASES_FN="dat/diseases.dat"

OUTD="results"
DATD="dat"
mkdir -p $OUTD


function collect_results {
    P=$1
    XFN=$2  # data file name, e.g., D_oldrun.run_list.dat

    FT=1    # first time flag, for headers
    OUTFN="results/${P}.run_list.tsv"
    while read DIS; do
        INFN="$DATD/results/$P/$DIS/$XFN"
        if [ ! -e $INFN ]; then
            >&2 echo ERROR: $INFN does not exist
            exit 1
        fi

        if [ $FT == 1 ]; then
            head -n1 $INFN | sed 's/^/disease\t/' | sed 's/run_metadata/case/' > $OUTFN
            FT=0
        fi
        tail -n +2 $INFN | sed "s/^/$DIS\t/" >> $OUTFN

    done <$DISEASES_FN
    >&2 echo Written to $OUTFN
}

for PIPELINE in $PIPELINES_B; do
    >&2 echo Collecting results for $PIPELINE \($BFN\)
    collect_results $PIPELINE $BFN
done

for PIPELINE in $PIPELINES_D; do
    >&2 echo Collecting results for $PIPELINE \($DFN\)
    collect_results $PIPELINE $DFN
done

