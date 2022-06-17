# Methylation: count only Green files (so no double count)
P=Methylation_Array
echo $P:
DAT="dat/summary/${P}.analysis_SN.dat"
grep Green $DAT | cut -f 3 | sort | uniq -c 
grep Green $DAT | cut -f 3 | sort | wc -l

function process_typical {
P=$1
DAT="dat/summary/${P}.analysis_SN.dat"
echo $P : $DAT
cut -f 3 $DAT | sort | uniq -c 
cut -f 3 $DAT | sort | wc -l
}

#RNA-Seq_Expression.analysis_SN.dat
#RNA-Seq_Fusion.analysis_SN.dat
#RNA-Seq_Transcript.analysis_SN.dat
#WGS_CNV_Somatic.analysis_SN.dat
#WGS_SV.analysis_SN.dat
#WXS_Germline.analysis_SN.dat
#WXS_MSI.analysis_SN.dat
#WXS_Somatic_Variant_SW.analysis_SN.dat
#WXS_Somatic_Variant_TD.analysis_SN.dat
#miRNA-Seq.analysis_SN.dat

process_typical RNA-Seq_Expression
process_typical RNA-Seq_Fusion
process_typical RNA-Seq_Transcript
process_typical WGS_CNV_Somatic
process_typical WGS_SV
process_typical WXS_Germline
process_typical WXS_MSI
process_typical WXS_Somatic_Variant_SW
process_typical WXS_Somatic_Variant_TD
process_typical miRNA-Seq
