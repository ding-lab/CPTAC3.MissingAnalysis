Analysis here aims to determine which pipelines for which diseases
still need to be analyzed.  This work builds on that in 20210520.MissingAnalyses

Specifically, we are interested in the following diseases and cohorts:
* CCRCC rare diseases
    * cohort = "Non-CCRCC Rare"
* All existing GBM
* All existing PDA

Note, we want to process all existing data for GBM and PDA regardless of
cohort, including heterogeneity data (where previously processed cases may have
additional data)

# Case lists

Case lists are created with the script `0_make_case_list.sh`

# Algorithm 
From src/get_missing_analyses.sh
Algorithm and outputs
  1. we are given list of cases of interest (-s CASES)
  2. Identify all UUIDs associated with cases of interest (UUIDs of interest)
  3. Get all UUIDs which have been analyzed (analyzed UUIDs)
     -> Based on data analysis summary file
     -> tumor/normal pipelines parsed to capture both input UUIDs
     -> Writes out OUTD/DIS/analyzed_UUID.dat
  4. Find analysis UUIDs as difference between UUIDs of interest and analyzed UUIDs
     -> These are the UUIDs which are to be analyzed
     -> Writes out OUTD/DIS/analysis_UUID.dat
  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
     -> Writes out OUTD/DIS/download_UUID.dat


# Results
Summary
Methylation UUIDs to run
     102 dat/Methylation/CCRCC/analysis_SN.dat
      46 dat/Methylation/GBM/analysis_SN.dat
       0 dat/Methylation/PDA/analysis_SN.dat
     148 total
Methylation files to download
     102 dat/Methylation/CCRCC/download_UUID.dat
      46 dat/Methylation/GBM/download_UUID.dat
       0 dat/Methylation/PDA/download_UUID.dat
     148 total
--
Summary
miRNA-Seq cases to run
      56 dat/miRNA-Seq/CCRCC/analysis_SN.dat
     194 dat/miRNA-Seq/GBM/analysis_SN.dat
     204 dat/miRNA-Seq/PDA/analysis_SN.dat
     454 total
miRNA-Seq files to download
      56 dat/miRNA-Seq/CCRCC/download_UUID.dat
     194 dat/miRNA-Seq/GBM/download_UUID.dat
     204 dat/miRNA-Seq/PDA/download_UUID.dat
     454 total
--
Summary
RNA-Seq Expression UUID to run
      56 dat/RNA-Seq_Expression/CCRCC/analysis_SN.dat
       1 dat/RNA-Seq_Expression/GBM/analysis_SN.dat
      22 dat/RNA-Seq_Expression/PDA/analysis_SN.dat
      79 total
RNA-Seq Expression files to download
      56 dat/RNA-Seq_Expression/CCRCC/download_UUID.dat
       1 dat/RNA-Seq_Expression/GBM/download_UUID.dat
      22 dat/RNA-Seq_Expression/PDA/download_UUID.dat
      79 total
--
Summary
RNA-Seq Fusion UUID to run
     112 dat/RNA-Seq_Fusion/CCRCC/analysis_SN.dat
     204 dat/RNA-Seq_Fusion/GBM/analysis_SN.dat
      44 dat/RNA-Seq_Fusion/PDA/analysis_SN.dat
     360 total
RNA-Seq Fusion files to download
     112 dat/RNA-Seq_Fusion/CCRCC/download_UUID.dat
     204 dat/RNA-Seq_Fusion/GBM/download_UUID.dat
      14 dat/RNA-Seq_Fusion/PDA/download_UUID.dat
     330 total
--
Summary
RNA-Seq Transcript UUID to run
     112 dat/RNA-Seq_Transcript/CCRCC/analysis_SN.dat
     202 dat/RNA-Seq_Transcript/GBM/analysis_SN.dat
      44 dat/RNA-Seq_Transcript/PDA/analysis_SN.dat
     358 total
RNA-Seq Transcript files to download
     112 dat/RNA-Seq_Transcript/CCRCC/download_UUID.dat
     202 dat/RNA-Seq_Transcript/GBM/download_UUID.dat
      14 dat/RNA-Seq_Transcript/PDA/download_UUID.dat
     328 total
--
Summary
WGS SV UUID to run
      75 dat/WGS_SV/CCRCC/analysis_SN.dat
       6 dat/WGS_SV/GBM/analysis_SN.dat
      65 dat/WGS_SV/PDA/analysis_SN.dat
     146 total
WGS SV files to download
      75 dat/WGS_SV/CCRCC/download_UUID.dat
       5 dat/WGS_SV/GBM/download_UUID.dat
       0 dat/WGS_SV/PDA/download_UUID.dat
      80 total
--
Summary
WGS CNV UUID to run
      75 dat/WGS_CNV_Somatic/CCRCC/analysis_SN.dat
     146 dat/WGS_CNV_Somatic/GBM/analysis_SN.dat
      65 dat/WGS_CNV_Somatic/PDA/analysis_SN.dat
     286 total
WGS CNV files to download
      75 dat/WGS_CNV_Somatic/CCRCC/download_UUID.dat
       5 dat/WGS_CNV_Somatic/GBM/download_UUID.dat
       0 dat/WGS_CNV_Somatic/PDA/download_UUID.dat
      80 total
--
Summary
WXS MSI UUIDs to run
      74 dat/WXS_MSI/CCRCC/analysis_SN.dat
      10 dat/WXS_MSI/GBM/analysis_SN.dat
      67 dat/WXS_MSI/PDA/analysis_SN.dat
     151 total
WXS MSI files to download
      74 dat/WXS_MSI/CCRCC/download_UUID.dat
       8 dat/WXS_MSI/GBM/download_UUID.dat
       0 dat/WXS_MSI/PDA/download_UUID.dat
      82 total
--
Summary
WXS Somatic Variant TD UUIDs to run
      74 dat/WXS_Somatic_Variant_TD/CCRCC/analysis_SN.dat
      38 dat/WXS_Somatic_Variant_TD/GBM/analysis_SN.dat
      61 dat/WXS_Somatic_Variant_TD/PDA/analysis_SN.dat
     173 total
WXS Somatic Variant TD files to download
      74 dat/WXS_Somatic_Variant_TD/CCRCC/download_UUID.dat
       8 dat/WXS_Somatic_Variant_TD/GBM/download_UUID.dat
       0 dat/WXS_Somatic_Variant_TD/PDA/download_UUID.dat
      82 total
--
Summary
WXS Somatic Variant SW UUIDs to run
      74 dat/WXS_Somatic_Variant_SW/CCRCC/analysis_SN.dat
     149 dat/WXS_Somatic_Variant_SW/GBM/analysis_SN.dat
     134 dat/WXS_Somatic_Variant_SW/PDA/analysis_SN.dat
     357 total
WXS Somatic Variant SW files to download
      74 dat/WXS_Somatic_Variant_SW/CCRCC/download_UUID.dat
       8 dat/WXS_Somatic_Variant_SW/GBM/download_UUID.dat
       0 dat/WXS_Somatic_Variant_SW/PDA/download_UUID.dat
      82 total
--
Summary
WXS Germline UUIDs to run
      37 dat/WXS_Germline/CCRCC/analysis_SN.dat
      17 dat/WXS_Germline/GBM/analysis_SN.dat
      21 dat/WXS_Germline/PDA/analysis_SN.dat
      75 total
WXS Germline files to download
      37 dat/WXS_Germline/CCRCC/download_UUID.dat
       2 dat/WXS_Germline/GBM/download_UUID.dat
       0 dat/WXS_Germline/PDA/download_UUID.dat
      39 total




## Download summaries

### Katmai
Methylation, miRNA-Seq, RNA-Seq FASTQ for Fusion and Transcript, Genomic BAMs for Expression
```
cat dat/Methylation/*/download_UUID.dat dat/miRNA-Seq/*/download_UUID.dat dat/RNA-Seq_Fusion/*/download_UUID.dat dat/RNA-Seq_Transcript/*/download_UUID.dat dat/RNA-Seq_Expression/*/download_UUID.dat | sort -u > dat/katmai.download_UUID.dat
```

### MGI
WXS
```
cat dat/WXS_Germline/*/download_UUID.dat dat/WXS_MSI/*/download_UUID.dat dat/WXS_Somatic_Variant_SW/*/download_UUID.dat dat/WXS_Somatic_Variant_TD/*/download_UUID.dat | sort -u > dat/MGI.download_UUID.dat
```

### Storage1
WGS downloaded to storage1
```
cat dat/WGS_CNV_Somatic/*/download_UUID.dat dat/WGS_SV/*/download_UUID.dat | sort -u > dat/storage1.download_UUID.dat
```


# Download problems

22 of the samples to be downloaded were not able to be downloaded, even after a number of retries.  2 were on compute1, 20 were on katmai.  The problematic
cases are listed in dat/download_errors/katmai.UUID.dat and compute1.UUID.dat

C3L-02204.WGS.N.hg38    CCRCC   d1948431-f679-41a0-8720-1a200b755448
C3L-02204.WGS.T.hg38    CCRCC   e3d7e2c5-52cb-4b4c-b678-6c6946bc7acc
C3L-03547.RNA-Seq.R1.T  GBM     7e9e1d40-4dbc-4163-800d-8d742fd5951c
C3L-03547.RNA-Seq.R2.T  GBM     4015c25b-3b30-4de3-b681-791a20da543e
C3L-03554.RNA-Seq.R1.T  GBM     3ecffe17-acc9-4237-87d5-b49163949ae1
C3L-03554.RNA-Seq.R2.T  GBM     da382358-3321-40ea-9631-b0f9586382bd
C3L-03557.RNA-Seq.R1.T  GBM     f757407c-6345-4a7f-b3eb-d1e7062dc6ed
C3L-03557.RNA-Seq.R2.T  GBM     4c4e0d47-d00e-4ab7-a4b5-8144f6cb4a38
C3L-03559.RNA-Seq.R1.T  GBM     b7fe5718-d6a9-4141-a694-92ea00086026
C3L-03559.RNA-Seq.R2.T  GBM     7a894735-c289-4136-aafa-d72edb275143
C3L-03588.RNA-Seq.R1.T  GBM     125972b5-4526-4f1e-b0be-eff967b1ed1e
C3L-03588.RNA-Seq.R2.T  GBM     3e05990f-cdf7-43cc-a667-dd6b824ea2be
C3L-04815.RNA-Seq.R1.T  GBM     98af91ad-d44e-408c-916f-7556d400b63f
C3L-04815.RNA-Seq.R2.T  GBM     949518ac-c6fe-4d94-9aed-e9aa29d99314
C3L-04817.RNA-Seq.R1.T  GBM     e3577dd8-984f-486c-9d9e-ce8d4e8889be
C3L-04817.RNA-Seq.R2.T  GBM     0a870ed5-d914-42cf-879c-b2d81c020910
C3L-04819.RNA-Seq.R1.T  GBM     083859d3-282e-4035-998d-83a4f425f9cf
C3L-04819.RNA-Seq.R2.T  GBM     8e96b951-e574-4ab7-af77-0291721c10f2
C3L-04838.RNA-Seq.R1.T  GBM     73658b9b-94b2-4b47-ac91-89ae815b22ae
C3L-04838.RNA-Seq.R2.T  GBM     52fafe76-c371-49f2-a86c-366d79d9d5c5
C3L-04843.RNA-Seq.R1.T  GBM     b2976a2a-0485-4bcd-8c55-3b7d1a6b0414
C3L-04843.RNA-Seq.R2.T  GBM     97ea2622-ed5e-42d5-b3cf-135be69cd9c3

After discussion with Mathangi and Ana, the GBM ones refer to cases which were stopped for
various reasons.  Looking into the CCRCC
