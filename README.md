Analysis here aims to determine which pipelines for which diseases
still need to be analyzed.  

This is an evolving project.  All cases for all diseases defined in step 0 are considered.
Future work will involve moving `RUN_LIST` creation from CromwellRunner to here.

Additional work is needed to resolve Ensembl v22 vs. v36 RNA-Seq data issues.  Harmonized
data silently replaced v22 with v36, with changes to UUID.  Past analyses not caught

## Versions

v2 - run_list based, developed June 2022
v1 - UUID-based, used through May 2022

Documentation below partly for v1 still.  v2 is a significant change and incorpates python scripts
for core processing 

# Case lists

Case lists are created with the script `0_make_case_list.sh`

# Algorithm v1
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
| Methylation_Array     | katmai    | Methylation Array    | Tumor, Normal   |   no (but has Red, Green) |
| miRNA-Seq             | katmai    | miRNA-Seq harmonized | Tumor, Adjacent |   no     |
| RNA-Seq_Expression    | storage1  | RNA-Seq harmonized   | Tumor, Adjacent |   no     |
| RNA-Seq_Fusion        | katmai (2)| RNA-Seq FASTQ        | Tumor, Adjacent |   no     |
| RNA-Seq_Transcript    | katmai (1)| RNA-Seq FASTQ        | Tumor, Adjacent |   no     |
| WGS_CNV_Somatic       | storage1  | WGS harmonized       | Tumor + Normal  |   yes    |
| WGS_SV                | storage1  | WGS harmonized       | Tumor + Normal  |   yes    |
| WXS_Germline          | MGI       | WXS harmonized       | Tumor           |   no     |
| WXS_MSI               | storage1  | WXS harmonized       | Tumor + Normal  |   yes    |
| WXS_Somatic_Variant_SW| storage1  | WXS harmonized       | Tumor + Normal  |   yes    |
| WXS_Somatic_Variant_TD| storage1  | WXS harmonized       | Tumor + Normal  |   yes    |

Note: Sample type "tumor, normal" indicates that these two sample types are processed individually
(separate run for tumor and normal).  Sample type "tumor + normal" indicates a paired tumor/normal pipeline,
where both tumor and normal are inputs for one run. This is also indicated by the pairedTN column

Notes
1. Currently only katmai, but possibly moving to storage1
2. Can run on either storage1 or katmai

## Pipeline configutation 
Pipeline configuration file has the following columns; it is TSV with a header and uses '.' to indicate empty / inapplicable fields

* pipeline: pipeline name
* alignment: Alignment of datasets, e.g., 'harmonized'
* experimental_strategy: Experimental strategy of datasets, e.g., 'WGS'
* data_format: Data format of datasets, e.g., 'BAM'
* data_variety: Data variety of dataset, e.g., 'genomic'
* data_variety2: Data variety of dataset 2, if different
* sample_type: Comma-separated list of sample types for sample1
* sample_type2: Comma-separated list of sample types for sample2.  Implies paired workflow
* label1: Label used for this dataset, e.g., 'tumor'
* label2: Label used for this dataset, e.g., 'normal'
* uuid_col: columns in analysis summary files have the UUIDs (e.g., '12' or '12,14')
* is_paired: 1 if two input datasets (e.g., germline) and 0 if one dataset
* suffix: arbitrary string added to run name (like X in case.X.ALQ_1234).  None if '.'

### Example:
```
pipeline: RNA-Seq_Expression
alignment: harmonized
experimental_strategy: RNA-Seq
data_format: BAM
data_variety: genomic
data_variety2: .
sample_type: tumor,tissue_normal
sample_type2: .
label1: sample
label2: .
uuid_col: 12
```

## Paired workflows:
* Methylation - Red, Green
* Various somatic - tumor, normal
* FASTQ - R1, R2 with the various lane values we observe.  Note we want these paired
	R1_L001, R2_L001
	...
	R1_L008, R2_L008

### Methylation, Fusion, and Transcript
Fusion and transcript are problematic when making pairs, since we want R1 and R2 of tumor, adjacent normal, metastasis,
and all the other ones, and want them as pairs
This is similar to issue we had with Methylation

In both cases, we want sample2 to be of the same type as sample1, even though they could be tumor or normal or whatever.
In that sense it is different than a tumor/normal pairing, which is one file per dataset
The key differnce is that for tumor/normal each dataset is from different sample, whereas for red/green and R1/R2 
each dataset is from the same sample.

# Exclude lists

UUIDs to download were generated by T2 script.  A number of UUIDs were not able to be downloaded.
Some of these were associated with case C3L-06368, which is a known problematic case.

Some of the download issues stem from the fact that we used Catalog3 for creating these lists, whereas 
the newer v2 catalog version did not have these.  Other samples were excluded for various reasons but (apparently)
not annotated

UUIDs which were not able to be downloaded are here: dat/post_download_exclude_list
the run lists will be modified to exclude any runs which have any of the UUIDs on the exclude list
(TODO)

# Stopped cases

Remove from Run Lists all cases which are listed in Mathangi's stopped cases list.
for discussion see /Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/20220809.StoppedCases/README.md

STOPPED_CASE_LIST="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/20220809.StoppedCases/stopped_cases_clean.txt"

This will not need to be done in the future since these cases have now been removed from the CPTAC3.cases.dat file
and will disappear on next discovery

