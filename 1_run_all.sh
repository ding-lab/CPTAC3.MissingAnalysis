# This is pretty rough and includes a lot of crap output but can be cleaned up quickly
OUT="./run_all.out"

bash R1_Methylation.sh > $OUT
bash R2_miRNA-Seq.sh >> $OUT
bash R3a_RNA-Seq_Expression.sh >> $OUT
bash R3b_RNA-Seq_Fusion.sh >> $OUT
bash R3c_RNA-Seq_Transcript.sh >> $OUT
bash R4a_WGS_SV.sh >> $OUT
bash R4b_WGS_CNV.sh >> $OUT
bash R5a_WXS_MSI.sh >> $OUT
bash R5b_WXS_Somatic_TD.sh >> $OUT
bash R5c_WXS_Somatic_SW.sh >> $OUT
bash R5d_WXS_Germline.sh >> $OUT

echo Written to $OUT
