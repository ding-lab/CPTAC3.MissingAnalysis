Analysis here aims to determine which pipelines for which diseases
still need to be analyzed.  

This is an evolving project.  All cases for all diseases defined in step 0 are considered.
Future work will involve moving `RUN_LIST` creation from CromwellRunner to here.

Additional work is needed to resolve Ensembl v22 vs. v36 RNA-Seq data issues.  Harmonized
data silently replaced v22 with v36, with changes to UUID.  Past analyses not caught

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
| Pipeline              | System    | Data type            | Sample type(s)  | pairedTN |
| -----------           | ------    | ---------            | --------------- | -------- |
| Methylation           | katmai    | Methylation Array    | Tumor, Normal   |   no     |
| miRNA-Seq             | katmai    | miRNA-Seq harmonized | Tumor, Adjacent |   no     |
| RNA-Seq_Expression    | storage1  | RNA-Seq harmonized   | Tumor, Adjacent |   no     |
| RNA-Seq_Fusion        | storage1  | RNA-Seq FASTQ        | Tumor, Adjacent |   no     |
| RNA-Seq_Transcript    | (1)       | RNA-Seq FASTQ        | Tumor, Adjacent |   no     |
| WGS_CNV               | storage1  | WGS harmonized       | Tumor + Normal  |   yes    |
| WGS_SV                | storage1  | WGS harmonized       | Tumor + Normal  |   yes    |
| WXS_Germline          | MGI       | WXS harmonized       | Tumor           |   no     |
| WXS_MSI               | storage1  | WXS harmonized       | Tumor + Normal  |   yes    |
| WXS_Somatic_SW        | storage1  | WXS harmonized       | Tumor + Normal  |   yes    |
| WXS_Somatic_TD        | storage1  | WXS harmonized       | Tumor + Normal  |   yes    |

Note: Sample type "tumor, normal" indicates that these two sample types are processed individually
(separate run for tumor and normal).  Sample type "tumor + normal" indicates a paired tumor/normal pipeline,
where both tumor and normal are inputs for one run. This is also indicated by the pairedTN column

Notes
1. Currently only katmai, but possibly moving to storage1

# Usage

Note that usage can be quite variable depending on the criteria involved.  Below
is an example

```
1. edit and run `0_make_case_list.sh`
2. 1_run_all.sh
3. 2_collect_tasks.sh
4. 3_summarize_downloads.sh
```
