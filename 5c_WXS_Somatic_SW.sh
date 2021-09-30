DISEASES_FN="dat/diseases.dat"
OUTD="dat/WXS_Somatic_Variant_SW"

while read DIS; do
    echo Running $DIS
    bash src/evaluate_WXS_Somatic_SW.sh $DIS $OUTD
done <$DISEASES_FN

echo Summary
echo WXS Somatic Variant SW UUIDs to run
wc -l $OUTD/*/analysis_SN.dat
echo WXS Somatic Variant SW files to download
wc -l $OUTD/*/download_UUID.dat
