DISEASES_FN="dat/diseases.dat"
OUTD="dat/RNA-Seq_Transcript"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_RNA-Seq_Transcript.sh $DIS $OUTD IGNORE_PAST_RUNS
done <$DISEASES_FN

echo Summary
echo RNA-Seq Transcript UUID to run
wc -l $OUTD/*/analysis_SN.dat
echo RNA-Seq Transcript files to download
wc -l $OUTD/*/download_UUID.*.dat
