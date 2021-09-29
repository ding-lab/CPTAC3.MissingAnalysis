DISEASES_FN="dat/diseases.dat"
OUTD="dat/Methylation"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_Methylation.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo Methylation UUIDs to run
wc -l $OUTD/*/analysis_SN.dat
echo Methylation files to download
wc -l $OUTD/*/download_UUID.dat
