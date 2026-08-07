#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --time=2:00:00
#SBATCH -c 10
#SBATCH --mail-type=END,FAIL
#SBATCH --output=QIIME2_Pathway_ANCOM_BC_%j.slurm

PROJECT_DIR="$(pwd)"
META_DIR="${PROJECT_DIR}/metadata"
OUT_DIR="${PROJECT_DIR}/results"
DENOISE_DIR="${OUT_DIR}/denoise_pyro"
PHYLO_DIR="${DENOISE_DIR}/phylogeny"
TAX_DIR="${DENOISE_DIR}/taxonomy"
PICRUST_DIR="${OUT_DIR}/picrust"


biom convert \
   -i "${PICRUST_DIR}/path_abun_unstrat.tsv" \
   -o "${PICRUST_DIR}/path_abun_unstrat.biom" \
   --table-type="Pathway table" \
   --to-hdf5

qiime tools import \
   --type 'FeatureTable[Frequency]' \
   --input-path "${PICRUST_DIR}/path_abun_unstrat.biom" \
   --output-path "${PICRUST_DIR}/pathway_abundance.qza"


qiime composition ancombc \
   --i-table "${PICRUST_DIR}/pathway_abundance.qza" \
   --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
   --p-formula "diet" \
   --o-differentials "${PICRUST_DIR}/ancombc_pathways_diet.qza"

qiime tools import   --type 'FeatureData[Taxonomy]'   --input-path "${PICRUST_DIR}/pathway_described_taxonomy.tsv"   --output-path "${PICRUST_DIR}/pathway_described_taxonomy.qza"

qiime composition da-barplot   --i-data "${PICRUST_DIR}/ancombc_pathways_diet.qza"   --i-taxonomy "${PICRUST_DIR}/pathway_described_taxonomy.qza"   --o-visualization "${PICRUST_DIR}/ancombc_pathways_described_diet.qzv"


