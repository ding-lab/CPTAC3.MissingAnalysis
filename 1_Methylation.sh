DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/Methylation"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_Methylation.sh $DIS $OUTD
done

echo Summary
echo Methylation cases to run
wc -l $OUTD/*/analysis_cases.dat
echo Methylation files to download
wc -l $OUTD/*/download_UUID.dat
