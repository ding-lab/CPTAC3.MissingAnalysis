Using new catalog format:

     1  dataset_name
     2  case
     3  sample_type
     4  data_format
     5  experimental_strategy
     6  preservation_method
     7  aliquot
     8  file_name
     9  file_size
    10  id
    11  md5sum

# Run A

Summary: this is incorrect because not focusing on high depth WGS - multiple tumors / normals because low depth data incorporated

                                                                 run_name run_metadata   datafile1_name               datafile1_aliquot                        datafile1_uuid   datafile2_name              datafile2_aliquot                        datafile2_uuid
0                                                               CTSP-ACXZ    CTSP-ACXZ  CTSP-ACXZ.WGS.T  CTSP-ACXZ-TTP1-A-1-1-D-A89Z-36  b595f91a-816f-4957-a50b-06c80593b56b  CTSP-ACXZ.WGS.N  CTSP-ACXZ-NB1-A-1-0-D-A89Z-36  62a54f2b-d6f3-4461-b6b2-995699117414
1  CTSP-ACY0.CTSP-ACY0-TTP1-A-1-1-D-A791-36.CTSP-ACY0-NB1-A-1-0-D-A791-36    CTSP-ACY0  CTSP-ACY0.WGS.T  CTSP-ACY0-TTP1-A-1-1-D-A791-36  dcff1114-7ec3-4944-ace6-58cd6c133042  CTSP-ACY0.WGS.N  CTSP-ACY0-NB1-A-1-0-D-A791-36  0e4322dc-bccf-481b-906a-e7ed5c3ce56a
2  CTSP-ACY0.CTSP-ACY0-TTP1-A-1-1-D-A791-36.CTSP-ACY0-NB1-A-1-0-D-A889-36    CTSP-ACY0  CTSP-ACY0.WGS.T  CTSP-ACY0-TTP1-A-1-1-D-A791-36  dcff1114-7ec3-4944-ace6-58cd6c133042  CTSP-ACY0.WGS.N  CTSP-ACY0-NB1-A-1-0-D-A889-36  62d37937-d950-4efd-83b5-fca0512b2ac2
3  CTSP-ACY0.CTSP-ACY0-TTP1-A-1-1-D-A889-36.CTSP-ACY0-NB1-A-1-0-D-A791-36    CTSP-ACY0  CTSP-ACY0.WGS.T  CTSP-ACY0-TTP1-A-1-1-D-A889-36  539d8c4c-f9d8-4f94-afba-dcd4696eebdc  CTSP-ACY0.WGS.N  CTSP-ACY0-NB1-A-1-0-D-A791-36  0e4322dc-bccf-481b-906a-e7ed5c3ce56a
4  CTSP-ACY0.CTSP-ACY0-TTP1-A-1-1-D-A889-36.CTSP-ACY0-NB1-A-1-0-D-A889-36    CTSP-ACY0  CTSP-ACY0.WGS.T  CTSP-ACY0-TTP1-A-1-1-D-A889-36  539d8c4c-f9d8-4f94-afba-dcd4696eebdc  CTSP-ACY0.WGS.N  CTSP-ACY0-NB1-A-1-0-D-A889-36  62d37937-d950-4efd-83b5-fca0512b2ac2
Writing run_list to dat/results/WGS_Somatic_Variant_TD/DLBCL/A_canonical_run_list.dat

Note that the GraphQL catalog has two entries for WGS data, one harmonized and one submitted, each with different UUIDs, though otherwise they look identical:
[m.wyczalkowski@compute1-client-1 Catalog3]$ examine_row DLBCL.Catalog3.tsv 63
     1  dataset_name    CTSP-ACY2.WGS.T
     2  case    CTSP-ACY2
     3  disease DLBCL
     4  experimental_strategy   WGS
     5  sample_type tumor
     6  specimen_name   CTSP-ACY2-TTP1-A-1-1-D-A889-36
     7  filename    CTSP-ACY2-TTP1-A-1-1-D-A889-36.WholeGenome.RP-1329.bam
     8  filesize    363842063206
     9  data_format BAM
    10  data_variety
    11  alignment   submitted_aligned
    12  project DLBCL
    13  uuid    8f5c9695-f16b-4f88-8a69-74f1f9824c0e
    14  md5 8e56fc4b6b44a553f37221b122c0017f
    15  metadata    {"aliquot_tag": "ALQ_49207eea", "gdc_sample_type": "Primary Tumor", "state": "submitted", "preservation_method": "Frozen"}
[m.wyczalkowski@compute1-client-1 Catalog3]$ examine_row DLBCL.Catalog3.tsv 65
     1  dataset_name    CTSP-ACY2.WGS.T.hg38
     2  case    CTSP-ACY2
     3  disease DLBCL
     4  experimental_strategy   WGS
     5  sample_type tumor
     6  specimen_name   CTSP-ACY2-TTP1-A-1-1-D-A889-36
     7  filename    CTSP-ACY2-TTP1-A-1-1-D-A889-36.WholeGenome.RP-1329.bam
     8  filesize    363842063206
     9  data_format BAM
    10  data_variety
    11  alignment   harmonized
    12  project DLBCL
    13  uuid    c9a1448f-c8f4-4772-a77a-bca98aeafbb3
    14  md5 8e56fc4b6b44a553f37221b122c0017f
    15  metadata    {"aliquot_tag": "ALQ_49207eea", "gdc_sample_type": "Primary Tumor", "state": "submitted", "preservation_method": "Frozen"}

The problem is that the GDC API has the harmonized UUIDs, whereas the past analysis has the submitted aligned reads UUID
These should probably be matched by aliquot rather than UUID

Note that these have the same MD5sum.  Altogether, 401 datasets have a repeated md5sums, which suggests that this could be used to map UUIDs

Another approach is to filter by aliquots, which is initiated in get_oldrun_list.sh.  This will return a list of aliquots, possibly paired, 
corresponding to given UUIDs
-> this is what we end up doing below

## High Depth WGS

* bam_metrics.csv: Lists all of the WGS deep coverage BAMs (including the unpaired)
* dlbcl_deep_cov_dna_wgs_pairs.csv: Lists only paired files
* rna_bam_metrics.csv: Lists available information for just the RNAseq cases
* cnv_pairs_no_dup_ffpe.csv: Lists the copy number pairs

As described in synapse_files/README.md, we will perform a run pair analysis based on high depth WGS data, as described in bam_metrics.csv
This will involve replacing catalog file with a "hdWGS" catalog version which contains only rows which correspond to files in bam_metrics.csv

For this, dat directory used for processing of all WGS data moved to dat-A

Note that using 229 case list: dat/cases/DLBCL-cases.dat

We perform run analysis with Primary Tumor, Slides, and FFPE Scrolls as tumor specimen types.  This generates
    dat/results/WGS_Somatic_Variant_TD/DLBCL/A_canonical_run_list.dat
with 219 runs, the same number as listed in file dlbcl_deep_cov_dna_wgs_pairs.csv from Synapse of the expected pairs to run.

Note that dat/results/WGS_Somatic_Variant_TD/DLBCL/B_request_run_list.dat has the same number of runs as A, since the UUIDs dont match (submitted vs. harmonized UUIDs)

Running S3 then removes runs based on aliquot pairs.  This results in the run list,
    /home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/dat/results/WGS_Somatic_Variant_TD/DLBCL/D_oldrun.run_list.dat
which contains 64 runs to perform.  This is understood as the final run list for WGS data.

# WES

Jays analysis summary file did not include tumor and normal UUIDs, which are required for this workflow.  A corrected analysis summary
file is generated in this directory: ../wxs_analysis_summary, and the output is copied to AnalysisSummaryLinks/analysis_summary_corrected.dat

Note that this file already has aliquot names.

Results: /home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/dat/results/WXS_Somatic_Variant_TD/DLBCL/B_request_run_list.dat
This has 10 runs which need to be performed

# Final results

Final run lists:
    /cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/results/WGS_Somatic_Variant_TD.run_list.tsv
    /cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/results/WXS_Somatic_Variant_TD.run_list.tsv

All UUIDs requested for download:

/home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/Results/downloads/storage1.all_UUID_requested.dat

# SV
Past runs: /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/SomaticSV/16.GDAN_DLBCL-135/dat/analysis_summary.stored.dat
    Copied to AnalysisSummaryLinks/SV.analysis_summary.dat
Note, using DLBCL.GDC_REST.20230409-AWG.hdWGS.tsv, and updating it in step Sx

Final run list: /home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/dat/results/WGS_SV/DLBCL/D_oldrun.run_list.dat


# CNV
past runs: /home/m.wyczalkowski/Projects/CromwellRunner/SomaticCNV/09.DLBCL_catalog3/dat/analysis_summary.stored.dat
Note, using DLBCL.GDC_REST.20230409-AWG.hdWGS.tsv, and updating it in step Sx

Final run list: /home/m.wyczalkowski/Projects/GDAN/Work/20230404.DLBCL_212/CPTAC3.MissingAnalysis/dat/results/WGS_CNV_Somatic/DLBCL/D_oldrun.run_list.dat


