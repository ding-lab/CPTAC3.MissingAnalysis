DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/WGS_CNV_Somatic"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_WGS_CNV.sh $DIS $OUTD
done

echo Summary
echo WGS CNV cases to run
wc -l $OUTD/*/analysis_cases.dat
echo WGS CNV files to download
wc -l $OUTD/*/download_UUID.dat
