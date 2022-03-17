DISEASES_FN="dat/diseases.dat"
OUTD="dat/miRNA-Seq"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_miRNA-Seq.sh $DIS $OUTD IGNORE_PAST_RUNS
done <$DISEASES_FN

echo Summary
echo miRNA-Seq cases to run
wc -l $OUTD/*/analysis_SN.dat
echo miRNA-Seq files to download
wc -l $OUTD/*/download_UUID.*.dat
