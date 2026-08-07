#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --time=2:00:00
#SBATCH -c 10
#SBATCH --mail-type=END,FAIL
#SBATCH --output=QIIME2_ANCOM_BC_%j.slurm

set -e

PROJECT_DIR="$(pwd)"
FASTQ_DIR="${PROJECT_DIR}/fastq_files"
META_DIR="${PROJECT_DIR}/metadata"
OUT_DIR="${PROJECT_DIR}/results"
DENOISE_DIR="${OUT_DIR}/denoise_pyro"
PHYLO_DIR="${OUT_DIR}/phylogeny"
TAX_DIR="${OUT_DIR}/taxonomy"
ANCOMBC_DIR="${OUT_DIR}/ANCOMBC"

mkdir -p ${ANCOMBC_DIR}
## Collapse feature table to Genus level (Level 6)
qiime taxa collapse \
  --i-table "${DENOISE_DIR}/table.qza" \
  --i-taxonomy "${TAX_DIR}/taxonomy.qza" \
  --p-level 6 \
  --o-collapsed-table "${DENOISE_DIR}/table_genus.qza"

## ANCOM-BC Genus Level
qiime composition ancombc \
  --i-table "${DENOISE_DIR}/table_genus.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --p-formula "diet" \
  --o-differentials "${ANCOMBC_DIR}/ancombc_diet_genus.qza"

qiime composition da-barplot \
  --i-data "${ANCOMBC_DIR}/ancombc_diet_genus.qza" \
  --o-visualization "${ANCOMBC_DIR}/ancombc_diet_genus.qzv"

## Collapse feature table to Phylum level (Level 2)
qiime taxa collapse \
  --i-table "${DENOISE_DIR}/table.qza" \
  --i-taxonomy "${TAX_DIR}/taxonomy.qza" \
  --p-level 2 \
  --o-collapsed-table "${DENOISE_DIR}/table_phylum.qza"

## ANCOM-BC Phylum Level
qiime composition ancombc \
  --i-table "${DENOISE_DIR}/table_phylum.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --p-formula "diet" \
  --o-differentials "${ANCOMBC_DIR}/ancombc_diet_phylum.qza"

qiime composition da-barplot \
  --i-data "${ANCOMBC_DIR}/ancombc_diet_phylum.qza" \
  --o-visualization "${ANCOMBC_DIR}/ancombc_diet_phylum.qzv"
