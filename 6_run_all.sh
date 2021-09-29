# This is pretty rough and includes a lot of crap output but can be cleaned up quickly
OUT="./run_all.out"

bash 1_Methylation.sh > $OUT
bash 2_miRNA-Seq.sh >> $OUT
bash 3a_RNA-Seq_Expression.sh >> $OUT
bash 3b_RNA-Seq_Fusion.sh >> $OUT
bash 3c_RNA-Seq_Transcript.sh >> $OUT
bash 4a_WGS_SV.sh >> $OUT
bash 4b_WGS_CNV.sh >> $OUT
bash 5a_WXS_MSI.sh >> $OUT
bash 5b_WXS_Somatic_TD.sh >> $OUT
bash 5c_WXS_Somatic_SW.sh >> $OUT
bash 5d_WXS_Germline.sh >> $OUT

echo Written to $OUT
