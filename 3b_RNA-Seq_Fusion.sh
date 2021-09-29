DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/RNA-Seq_Fusion"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_RNA-Seq_Fusion.sh $DIS $OUTD
done

echo Summary
echo RNA-Seq Fusion cases to run
wc -l $OUTD/*/analysis_cases.dat
echo RNA-Seq Fusion files to download
wc -l $OUTD/*/download_UUID.dat
