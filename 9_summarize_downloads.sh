
OUTD_DL="dat/downloads"
mkdir -p $OUTD_DL

# The following pipelines are run on katmai:
# Methylation, miRNA-Seq, RNA-Seq FASTQ for Fusion and Transcript, Genomic BAMs for Expression
CMD="cat  \
dat/Methylation/*/download_UUID.dat \
dat/miRNA-Seq/*/download_UUID.dat \
dat/RNA-Seq_Fusion/*/download_UUID.dat \
dat/RNA-Seq_Transcript/*/download_UUID.dat \
dat/RNA-Seq_Expression/*/download_UUID.dat \
dat/WXS_MSI/*/download_UUID.dat  \
  | sort -u > $OUTD_DL/katmai.download_UUID.dat \
"
echo Running: $CMD
eval $CMD

# All WXS pipelines are run on MGI
CMD="cat  \
dat/WXS_Germline/*/download_UUID.dat  \
dat/WXS_MSI/*/download_UUID.dat  \
dat/WXS_Somatic_Variant_SW/*/download_UUID.dat  \
dat/WXS_Somatic_Variant_TD/*/download_UUID.dat | sort -u > $OUTD_DL/MGI.download_UUID.dat \
"
echo Running: $CMD
eval $CMD

# All WGS pipelines as well as WXS are run on storage1
CMD="cat  \
dat/WGS_CNV_Somatic/*/download_UUID.dat \
dat/WGS_SV/*/download_UUID.dat \
  | sort -u > $OUTD_DL/storage1.download_UUID.dat \
"

echo Running: $CMD
eval $CMD
