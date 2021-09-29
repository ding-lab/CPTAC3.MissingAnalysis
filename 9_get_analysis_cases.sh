# this used to be in ./dat

PIPELINES="
Methylation \
RNA-Seq_Expression \
RNA-Seq_Fusion \
RNA-Seq_Transcript \
WGS_CNV_Somatic \
WGS_SV \
WXS_Germline \
WXS_MSI \
WXS_Somatic_Variant_SW \
WXS_Somatic_Variant_TD \
miRNA-Seq "



for p in $PIPELINES; do
    cat $p/*/analysis_cases.dat | sort -u > $p.analysis_cases.dat
done

