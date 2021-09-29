DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/RNA-Seq_Transcript"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_RNA-Seq_Transcript.sh $DIS $OUTD
done

echo Summary
echo RNA-Seq Transcript cases to run
wc -l $OUTD/*/analysis_cases.dat
echo RNA-Seq Transcript files to download
wc -l $OUTD/*/download_UUID.dat
