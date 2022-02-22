DISEASES_FN="dat/diseases.dat"
OUTD="dat/RNA-Seq_Expression"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_RNA-Seq_Expression.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo RNA-Seq Expression UUID to run
wc -l $OUTD/*/analysis_SN.dat
echo RNA-Seq Expression files to download
wc -l $OUTD/*/download_UUID.*.dat
