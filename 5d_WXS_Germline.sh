DISEASES_FN="dat/diseases.dat"
OUTD="dat/WXS_Germline"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_WXS_Germline.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo WXS Germline UUIDs to run
wc -l $OUTD/*/analysis_SN.dat
echo WXS Germline files to download
wc -l $OUTD/*/download_UUID.*.dat
