Analysis here aims to determine which pipelines for which diseases
still need to be analyzed.  This work builds on that in 20210520.MissingAnalyses

This is an evolving project.  All cases for all diseases defined in step 0 are considered.
Future work will involve moving `RUN_LIST` creation from CromwellRunner to here.

Note, we want to process all existing data for GBM and PDA regardless of
cohort, including heterogeneity data (where previously processed cases may have
additional data)

Upon requesting to analysts, this will be "batch_1021"

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
     -> Also writes OUTD/DIS/analysis_SN.dat, with the fields "sample_name, case, disease, UUID"
        
  5. Find UUIDs to download as analysis UUIDs which are not present in BamMap (download UUID)
     -> Writes out OUTD/DIS/download_UUID.dat


# Results

## Download summaries
| Pipeline              | System    | Data type            | Sample type(s)  |
| -----------           | ------    | ---------            | --------------- |
| Methylation           | katmai    | Methylation Array    | Tumor, Normal   |
| miRNA-Seq             | katmai    | miRNA-Seq harmonized | Tumor, Adjacent |
| RNA-Seq_Expression    | katmai    | RNA-Seq harmonized   | Tumor, Adjacent | 
| RNA-Seq_Fusion        | katmai    | RNA-Seq FASTQ        | Tumor, Adjacent | 
| RNA-Seq_Transcript    | katmai    | RNA-Seq FASTQ        | Tumor, Adjacent | 
| WGS_CNV               | storage1  | WGS harmonized       | Tumor + Normal  |
| WGS_SV                | storage1  | WGS harmonized       | Tumor + Normal  |
| WXS_Germline          | MGI       | WXS harmonized       | Tumor           | 
| WXS_MSI               | MGI       | WXS harmonized       | Tumor           |
| WXS_Somatic_SW        | MGI       | WXS harmonized       | Tumor + Normal  |
| WXS_Somatic_TD        | storage1  | WXS harmonized       | Tumor + Normal  |

Note: Sample type "tumor, normal" indicates that these two sample types are processed individually
(separate run for tumor and normal).  Sample type "tumor + normal" indicates a somatic pipeline,
where both tumor and normal are inputs for one run.

### Katmai

### MGI

### Storage1

