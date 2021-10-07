# Create collected files for all analyses and downloads per system

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

OUTDD="dat/summary/downloads"
mkdir -p $OUTDD

for p in $PIPELINES; do
    cat dat/$p/*/analysis_SN.dat | sort -u > $OUTD/$p.analysis_SN.dat
done



# The following pipelines are run on katmai:
# Methylation, miRNA-Seq, RNA-Seq FASTQ for Fusion and Transcript, Genomic BAMs for Expression
```
cat dat/Methylation/*/download_UUID.dat dat/miRNA-Seq/*/download_UUID.dat dat/RNA-Seq_Fusion/*/download_UUID.dat dat/RNA-Seq_Transcript/*/download_UUID.dat dat/RNA-Seq_Expression/*/download_UUID.dat | sort -u > $OUTDD/katmai.download_UUID.dat
```

# All WXS pipelines are run on MGI
```
cat dat/WXS_Germline/*/download_UUID.dat dat/WXS_MSI/*/download_UUID.dat dat/WXS_Somatic_Variant_SW/*/download_UUID.dat dat/WXS_Somatic_Variant_TD/*/download_UUID.dat | sort -u > $OUTDD/MGI.download_UUID.dat
```

# UPDATE: MSI requested to be moved to katmai also
```
cat dat/WXS_MSI/*/download_UUID.dat | sort -u > $OUTDD/katmai.download_UUID.batch2.dat
```

# All WGS pipelines are run on storage1
```
cat dat/WGS_CNV_Somatic/*/download_UUID.dat dat/WGS_SV/*/download_UUID.dat | sort -u > $OUTDD/storage1.download_UUID.dat
```



