DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/RNA-Seq_Expression"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_RNA-Seq_Expression.sh $DIS $OUTD
done

echo Summary
echo RNA-Seq Expression cases to run
wc -l $OUTD/*/analysis_cases.dat
echo RNA-Seq Expression files to download
wc -l $OUTD/*/download_UUID.dat
