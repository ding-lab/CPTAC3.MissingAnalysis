DISEASES_FN="dat/diseases.dat"
OUTD="dat/WGS_SV"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_WGS_SV.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo WGS SV UUID to run
wc -l $OUTD/*/analysis_SN.dat
echo WGS SV files to download
wc -l $OUTD/*/download_UUID.*.dat
