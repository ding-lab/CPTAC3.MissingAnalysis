Goal here is to develop ReadListMaker, a python script for parsing 
Catalog3 data to create Run Lists for TinDaisy and other pipelines

This is a significant change to the engine which evaluates run_list

# Issues
This has a hard time with Methylation, where there are two datasets, red and green,
and want to process two data types, tumor and tissue_normal.  
Similar situation occurs for R1, R2 FASTQ files.  See discussion in README.md

# Analysis for 6/15/22

Will focus on these two analyses:
* GBM SV
* PDA MSI


## development notes
### Duplicate FASTQ names

grep FASTQ CPTAC3.Catalog3.tsv| cut -f 1,2 | sort | uniq -c | sort -nr | less
   6 C3N-00148.scRNA-Seq.R2_L003.T      C3N-00148
   6 C3N-00148.scRNA-Seq.R1_L003.T      C3N-00148
   4 C3N-04611.RNA-Seq.T        C3N-04611
   4 C3N-03226.RNA-Seq.T        C3N-03226
   4 C3N-02333.RNA-Seq.T        C3N-02333

Filenames for C3N-00148.scRNA-Seq.R2_L003.T:
	20210623_WUSTL_TWFU-CPT0081580013-XBn1_1_ATGGCTTGTG+GAATGTTGTG_S3_L003_R2_001.fastq.gz
	20210623_WUSTL_TWFU-CPT0081590013-XBn1_1_TTCTCGATGA+TGTCGGGCAC_S4_L003_R2_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081600013-Y1N1Z1_1Bn1_1_CCTGTCAGGG+AGCCCGTAAC_S7_L003_R2_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081600013-Y1N1Z1_1Bn1_1_CCTGTCAGGG+GTTACGGGCT_S4_L003_R2_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081610013-Y1N1Z1_1Bn1_1_CGCTGAAATC+AGGTGTCTGC_S7_L003_R2_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081610013-Y1N1Z1_1Bn1_1_CGCTGAAATC+GCAGACACCT_S5_L003_R2_001.fastq.gz

Filenames for C3N-00148.scRNA-Seq.R1_L003.T
	20210623_WUSTL_TWFU-CPT0081580013-XBn1_1_ATGGCTTGTG+GAATGTTGTG_S3_L003_R1_001.fastq.gz
	20210623_WUSTL_TWFU-CPT0081590013-XBn1_1_TTCTCGATGA+TGTCGGGCAC_S4_L003_R1_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081600013-Y1N1Z1_1Bn1_1_CCTGTCAGGG+AGCCCGTAAC_S7_L003_R1_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081600013-Y1N1Z1_1Bn1_1_CCTGTCAGGG+GTTACGGGCT_S4_L003_R1_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081610013-Y1N1Z1_1Bn1_1_CGCTGAAATC+AGGTGTCTGC_S7_L003_R1_001.fastq.gz
	20210721_WUSTL_TWFU-CPT0081610013-Y1N1Z1_1Bn1_1_CGCTGAAATC+GCAGACACCT_S5_L003_R1_001.fastq.gz

$ grep C3N-04611.RNA-Seq.T CPTAC3.Catalog3.tsv | cut -f 7
	20210723_P2_A1_WB7988-plate2_S1_R1_001.fastq.gz
	20210723_P2_A1_WB7988-plate2_S1_R2_001.fastq.gz
	20210729_P3_H11_WB7988-Plate3_S95_R1_001.fastq.gz
	20210729_P3_H11_WB7988-Plate3_S95_R2_001.fastq.gz
-> This looks like an alternate format for filenames, and we are not capturing
	R1 vs. R2.  This also corresponds to the situations where the metadata is not
	properly captured

These specific samples are badly parsed and the data variety may not be sufficient to identify paired datasets

### Weird endings in analyzed_UUIDs.dat

Looking at `dat/WXS_MSI/analyzed_UUIDs.dat`, some lines end in `^M` which is weird.
Example c01f4ba5-1030-49c0-902d-fec56a504d15
It seems first two correspond to buccal_normal, which is unusual 

# Other test cases
## C3N-01200
This case has five methylation samples

# Errata
## Methylation C3N-04113

This case seems to have multiple datafiles of each variety for the same aliquot:
```
$ grep C3N-04113 CPTAC3.Catalog3.tsv | grep Methyl | grep -v REP_7d56a3b1 | cut -f 1,6,7,13
C3N-04113.MethArray.Green.T	CPT0285620006	204367490093_R03C01_Grn.idat	67d72c45-fa2d-4cad-8582-0f19edbe887f
C3N-04113.MethArray.Green.T	CPT0285620006	204930630109_R07C01_Grn.idat	a6c818e8-81f4-426d-bffa-0955e283e20c
C3N-04113.MethArray.Red.T	CPT0285620006	204367490093_R03C01_Red.idat	fa6fcda1-b93e-4900-92fb-885e8ade614b
C3N-04113.MethArray.Red.T	CPT0285620006	204930630109_R07C01_Red.idat	df28f441-dc30-48e2-9879-7505d6adc086
```
This is unusual, since different datasets typically have different aliquots.  Are there other such instances?
Focus on methylation - no, this is the only one.

