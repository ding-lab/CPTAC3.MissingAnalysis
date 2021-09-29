DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/WXS_Somatic_Variant_SW"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_WXS_Somatic_SW.sh $DIS $OUTD
done

echo Summary
echo WXS Somatic Variant SW cases to run
wc -l $OUTD/*/analysis_cases.dat
echo WXS Somatic Variant SW files to download
wc -l $OUTD/*/download_UUID.dat
