DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/WXS_MSI"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_WXS_MSI.sh $DIS $OUTD
done

echo Summary
echo WXS MSI cases to run
wc -l $OUTD/*/analysis_cases.dat
echo WXS MSI files to download
wc -l $OUTD/*/download_UUID.dat
