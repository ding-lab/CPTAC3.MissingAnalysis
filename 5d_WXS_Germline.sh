DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/WXS_Germline"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_WXS_Germline.sh $DIS $OUTD
done

echo Summary
echo WXS Germline cases to run
wc -l $OUTD/*/analysis_cases.dat
echo WXS Germline files to download
wc -l $OUTD/*/download_UUID.dat
