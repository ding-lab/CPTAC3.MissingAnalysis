DISEASES_FN="dat/diseases.dat"
OUTD="dat/WXS_MSI"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_WXS_MSI.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo WXS MSI UUIDs to run
wc -l $OUTD/*/analysis_SN.dat
echo WXS MSI files to download
wc -l $OUTD/*/download_UUID.dat
