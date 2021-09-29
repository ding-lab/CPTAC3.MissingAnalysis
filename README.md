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
  0. we are given list of cases of interest (-s CASES)
  1. Get all cases of a disease which have been analyzed (analyzed cases)
     -> Writes out OUTD/DIS/analyzed_cases.dat
  2. Find target cases as difference between cases of interest and analyzed cases
     -> Writes out OUTD/DIS/target_cases.dat
  3. Find cases to analyze as target cases which have data available at GDC (analysis cases)
     -> Writes out OUTD/DIS/analysis_cases.dat
  4. Find UUIDs associated with data required for processing of analysis cases (analysis UUID)
     -> Writes out OUTD/DIS/analysis_UUID.dat
  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
     -> Writes out OUTD/DIS/download_UUID.dat

Note that this algorithm will not detect instances where additional data appears for
cases which have already been run e.g., heterogeneity data for a previously processed case.
Rather, it is intended to make sure all cases have been processed at least once





# OLD NOTES from ../20210728.MissingAnalyses
Analysis here aims to determine which pipelines for which diseases
still need to be analyzed.  This work builds on that in 20210520.MissingAnalyses
by considering further diseases and generalizing the scripting analysis
for easier reprodicibility

# Case lists

# Algorithm

From src/get_missing_analyses.sh
Algorithm and outputs
  0. we are given list of cases of interest (-s CASES)
  1. Get all cases of a disease which have been analyzed (analyzed cases)
     -> Writes out OUTD/DIS/analyzed_cases.dat
  2. Find target cases as difference between cases of interest and analyzed cases
     -> Writes out OUTD/DIS/target_cases.dat
  3. Find cases to analyze as target cases which have data available at GDC (analysis cases)
     -> Writes out OUTD/DIS/analysis_cases.dat
  4. Find UUIDs associated with data required for processing of analysis cases (analysis UUID)
     -> Writes out OUTD/DIS/analysis_UUID.dat
  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
     -> Writes out OUTD/DIS/download_UUID.dat

Note that this algorithm will not detect instances where additional data appears for
cases which have already been run e.g., heterogeneity data for a previously processed case.
Rather, it is intended to make sure all cases have been processed at least once

# Results

Note, analyses performed with CPTAC3 Catalog and case files available prior to 7/28/21

## Per pipeline summaries
### Methylation
Methylation cases to run
      89 dat/Methylation/LSCC/analysis_cases.dat
      89 total
Methylation files to download
       0 total

### miRNA-Seq
miRNA-Seq cases to run
      89 dat/miRNA-Seq/LSCC/analysis_cases.dat
      89 total
miRNA-Seq files to download
     166 dat/miRNA-Seq/LSCC/download_UUID.dat
     166 total

### RNA-Seq Expression
RNA-Seq Expression cases to run
       1 dat/RNA-Seq_Expression/GBM/analysis_cases.dat
      89 dat/RNA-Seq_Expression/LSCC/analysis_cases.dat
      90 total
RNA-Seq Expression files to download
       1 dat/RNA-Seq_Expression/GBM/download_UUID.dat
     166 dat/RNA-Seq_Expression/LSCC/download_UUID.dat
     167 total

### RNA-Seq Fusion
RNA-Seq Fusion cases to run
       1 dat/RNA-Seq_Fusion/GBM/analysis_cases.dat
      89 dat/RNA-Seq_Fusion/LSCC/analysis_cases.dat
      90 total
RNA-Seq Fusion files to download
       2 dat/RNA-Seq_Fusion/GBM/download_UUID.dat
     332 dat/RNA-Seq_Fusion/LSCC/download_UUID.dat
     334 total

### RNA-Seq Transcript
RNA-Seq Transcript cases to run
       1 dat/RNA-Seq_Transcript/GBM/analysis_cases.dat
      89 dat/RNA-Seq_Transcript/LSCC/analysis_cases.dat
      90 total
RNA-Seq Transcript files to download
       2 dat/RNA-Seq_Transcript/GBM/download_UUID.dat
     332 dat/RNA-Seq_Transcript/LSCC/download_UUID.dat
     334 total

### WGS SV
WGS SV cases to run
      13 dat/WGS_SV/GBM/analysis_cases.dat
      89 dat/WGS_SV/LSCC/analysis_cases.dat
       1 dat/WGS_SV/UCEC/analysis_cases.dat
     103 total
WGS SV files to download
      22 dat/WGS_SV/GBM/download_UUID.dat
     178 dat/WGS_SV/LSCC/download_UUID.dat
     200 total

### WGS CNV
WGS CNV cases to run
      71 dat/WGS_CNV_Somatic/GBM/analysis_cases.dat
      89 dat/WGS_CNV_Somatic/LSCC/analysis_cases.dat
     108 dat/WGS_CNV_Somatic/LUAD/analysis_cases.dat
       1 dat/WGS_CNV_Somatic/UCEC/analysis_cases.dat
     269 total
WGS CNV files to download
      22 dat/WGS_CNV_Somatic/GBM/download_UUID.dat
     178 dat/WGS_CNV_Somatic/LSCC/download_UUID.dat
     200 total

### WXS MSI
WXS MSI cases to run
      12 dat/WXS_MSI/GBM/analysis_cases.dat
      89 dat/WXS_MSI/LSCC/analysis_cases.dat
     101 total
WXS MSI files to download
      22 dat/WXS_MSI/GBM/download_UUID.dat
      22 total

### WXS Somatic Variant TD
WXS Somatic Variant TD cases to run
       1 dat/WXS_Somatic_Variant_TD/CCRCC/analysis_cases.dat
      12 dat/WXS_Somatic_Variant_TD/GBM/analysis_cases.dat
       1 dat/WXS_Somatic_Variant_TD/LUAD/analysis_cases.dat
      14 total
WXS Somatic Variant TD files to download
      22 dat/WXS_Somatic_Variant_TD/GBM/download_UUID.dat
      22 total

### WXS Somatic Variant SW
WXS Somatic Variant SW cases to run
     222 dat/WXS_Somatic_Variant_SW/CCRCC/analysis_cases.dat
     112 dat/WXS_Somatic_Variant_SW/GBM/analysis_cases.dat
     111 dat/WXS_Somatic_Variant_SW/HNSCC/analysis_cases.dat
      89 dat/WXS_Somatic_Variant_SW/LSCC/analysis_cases.dat
       2 dat/WXS_Somatic_Variant_SW/LUAD/analysis_cases.dat
     536 total
WXS Somatic Variant SW files to download
      23 dat/WXS_Somatic_Variant_SW/GBM/download_UUID.dat
       2 dat/WXS_Somatic_Variant_SW/HNSCC/download_UUID.dat
      25 total

### WXS Germline
WXS Germline cases to run
     112 dat/WXS_Germline/CCRCC/analysis_cases.dat
      12 dat/WXS_Germline/GBM/analysis_cases.dat
       1 dat/WXS_Germline/HNSCC/analysis_cases.dat
      89 dat/WXS_Germline/LSCC/analysis_cases.dat
       1 dat/WXS_Germline/LUAD/analysis_cases.dat
     138 dat/WXS_Germline/UCEC/analysis_cases.dat
     353 total
WXS Germline files to download
      22 dat/WXS_Germline/GBM/download_UUID.dat
      81 dat/WXS_Germline/LSCC/download_UUID.dat
     103 total

## Download summaries

Update: Bobo request Genomic BAMs be downloaded to katmai in the future

### Katmai
Methylation, miRNA-Seq, RNA-Seq FASTQ for Fusion and Transcript
NOTE: in future, RNA-Seq Genomic BAMs to katmai
```
cat dat/Methylation/*/download_UUID.dat dat/miRNA-Seq/*/download_UUID.dat dat/RNA-Seq_Fusion/*/download_UUID.dat dat/RNA-Seq_Transcript/*/download_UUID.dat | sort -u > dat/katmai.download_UUID.dat
```

### MGI
WXS, RNA-Seq Genomic (for Expression)
NOTE: in future, RNA-Seq Genomic BAMs to katmai
```
cat dat/WXS_Germline/*/download_UUID.dat dat/WXS_MSI/*/download_UUID.dat dat/WXS_Somatic_Variant_SW/*/download_UUID.dat dat/WXS_Somatic_Variant_TD/*/download_UUID.dat dat/RNA-Seq_Expression/*/download_UUID.dat | sort -u > dat/MGI.download_UUID.dat
```

### Storage1
WGS downloaded to storage1
```
cat dat/WGS_CNV_Somatic/*/download_UUID.dat dat/WGS_SV/*/download_UUID.dat | sort -u > dat/storage1.download_UUID.dat
```

### Summary
```
$ wc -l dat/*download_UUID.dat
     273 dat/MGI.download_UUID.dat
     500 dat/katmai.download_UUID.dat
     200 dat/storage1.download_UUID.dat
```

## Processing Requests
Generated with dat/1_get_analysis_cases.sh

Case counts:
      89 Methylation.analysis_cases.dat
      89 miRNA-Seq.analysis_cases.dat
      90 RNA-Seq_Expression.analysis_cases.dat
      90 RNA-Seq_Fusion.analysis_cases.dat
      90 RNA-Seq_Transcript.analysis_cases.dat
     269 WGS_CNV_Somatic.analysis_cases.dat
     103 WGS_SV.analysis_cases.dat
     353 WXS_Germline.analysis_cases.dat
     101 WXS_MSI.analysis_cases.dat
     536 WXS_Somatic_Variant_SW.analysis_cases.dat
      14 WXS_Somatic_Variant_TD.analysis_cases.dat


# TODO

For future versions of this analysis, exclude any UUIDs which have "deprecated" label
