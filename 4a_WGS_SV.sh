DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/WGS_SV"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_WGS_SV.sh $DIS $OUTD
done

echo Summary
echo WGS SV cases to run
wc -l $OUTD/*/analysis_cases.dat
echo WGS SV files to download
wc -l $OUTD/*/download_UUID.dat
