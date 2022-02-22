DISEASES_FN="dat/diseases.dat"
OUTD="dat/RNA-Seq_Fusion"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_RNA-Seq_Fusion.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo RNA-Seq Fusion UUID to run
wc -l $OUTD/*/analysis_SN.dat
echo RNA-Seq Fusion files to download
wc -l $OUTD/*/download_UUID.*.dat
