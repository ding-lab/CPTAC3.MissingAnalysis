DISEASES="CCRCC GBM HNSCC LSCC LUAD UCEC"
OUTD="dat/miRNA-Seq"

for DIS in $DISEASES ; do 
    echo Running $DIS
    bash src/evaluate_miRNA-Seq.sh $DIS $OUTD
done

echo Summary
echo miRNA-Seq cases to run
wc -l $OUTD/*/analysis_cases.dat
echo miRNA-Seq files to download
wc -l $OUTD/*/download_UUID.dat
