# Create collected files for all analyses 

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


OUTD="dat/summary"
mkdir -p $OUTD

for p in $PIPELINES; do
    cat dat/$p/*/analysis_SN.dat | sort -u > $OUTD/$p.analysis_SN.dat
done


>&2 echo Collected results written to $OUTD/PIPELINE.analysis_SN.dat
