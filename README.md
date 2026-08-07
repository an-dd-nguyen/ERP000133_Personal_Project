# ERP000133_Personal_Project
Packages/Software:
Miniconda3/22.11.1-1
QIIME2-2026.7
PICRUSt2-2.4.1

QIIME2 and PICRUSt2 were installed as conda environments. The installation process strictly followed guides from https://library.qiime2.org/quickstart/qiime2 and https://huttenhower.sph.harvard.edu/picrust/. The scripts was ran on CWRU HPC. For ease of execution, respective conda environments were load first, then the jobs were submitted.

Order of execution
- First, italiantable.csv was converted into the tab-delimited italiantable.txt format. Then, from the starting terminal, create a directory (e.g., Test_Directory). Create a metadata subdirectory in the Test_Directory, and transfer italiantable.txt into the metadata subdirectory.
- Run 01_setup_and_download.sh, which creates the necessary structure for Test_Directory, downloads relevant fastq files, preparing for QIIME2 by creating relevant manifest and metadata files, and creating the silva-138-99-nb-classifier-local.qza for downstream taxonomic classification.
- Activate the QIIME2 environment and run 02_Qiime2_demux.sh and inspect demux-summary.qzv to decide parameters for DADA denoising.
- Run 03-Qiime2_denoise_phylogeny.sh to denoise data, construct a phylogenetic tree files, and assign taxonomic classifications for reads in samples.
- Run 04_Qiime2_diversity_analysis.sh for diversity analysis. Output includes statistical analyses on alpha and beta diversity between two cohorts (hardcoded as diet in this case).
- Run 05_Qiime2_ANCOM_BC.sh for taxonomic differential abundance analysis. Hardcoded for phylum and genus level in this case.
- Activate the PICRUSt2 environment and run 06_Picrusts_Pathway_Annotation.sh to prepare for pathway differential analysis.
- Activate the QIIME2 environment and run 07_Qiime2_Pathway_ANCOM_BC.sh for pathway differential analysis. 
