DISEASES_FN="dat/diseases.dat"
OUTD="dat/WGS_CNV_Somatic"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_WGS_CNV.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo WGS CNV UUID to run
wc -l $OUTD/*/analysis_SN.dat
echo WGS CNV files to download
wc -l $OUTD/*/download_UUID.*.dat
