
OUTD_DL="dat/downloads"
mkdir -p $OUTD_DL

# The following pipelines are run on katmai:
# Methylation, miRNA-Seq, RNA-Seq FASTQ for Fusion and Transcript, Genomic BAMs for Expression
CMD="cat dat/*/*/download_UUID.katmai.dat | sort -u > $OUTD_DL/katmai.download_UUID.dat  "
echo Running: $CMD
eval $CMD

# All WXS pipelines are run on MGI
CMD="cat dat/*/*/download_UUID.MGI.dat | sort -u > $OUTD_DL/MGI.download_UUID.dat "
echo Running: $CMD
eval $CMD

# All WGS pipelines as well as WXS are run on storage1
CMD="cat dat/*/*/download_UUID.storage1.dat | sort -u > $OUTD_DL/storage1.download_UUID.dat "
echo Running: $CMD
eval $CMD
