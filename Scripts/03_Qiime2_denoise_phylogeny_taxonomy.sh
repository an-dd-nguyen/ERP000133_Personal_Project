#!/bin/bash
#SBATCH --mem=100GB
#SBATCH --time=2:00:00
#SBATCH -c 10
#SBATCH --mail-type=END,FAIL
#SBATCH --output=QIIME2_Denoise_Phylogeny_Taxonomy_%j.slurm

set -e

PROJECT_DIR="$(pwd)"
FASTQ_DIR="${PROJECT_DIR}/fastq_files"
META_DIR="${PROJECT_DIR}/metadata"
OUT_DIR="${PROJECT_DIR}/results"

# 2. Denoising with DADA2 (pyrosequencing optimized)
DENOISE_DIR="${OUT_DIR}/denoise_pyro"
mkdir -p "$DENOISE_DIR"

qiime dada2 denoise-pyro \
  --i-demultiplexed-seqs "${OUT_DIR}/single-end-demux.qza" \
  --p-trim-left 17 \
  --p-trunc-len 250 \
  --p-max-ee 5 \
  --p-n-threads ${SLURM_CPUS_PER_TASK} \
  --o-table "${DENOISE_DIR}/table.qza" \
  --o-representative-sequences "${DENOISE_DIR}/rep-seqs.qza" \
  --o-denoising-stats "${DENOISE_DIR}/denoising-stats.qza" \
  --o-base-transition-stats "${DENOISE_DIR}/base-transition-stats.qza"

## Generate ASV table visualization
qiime feature-table summarize \
  --i-table "${DENOISE_DIR}/table.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --o-feature-frequencies "${DENOISE_DIR}/feature-frequencies.qza" \
  --o-sample-frequencies "${DENOISE_DIR}/sample-frequencies.qza" \
  --o-summary "${DENOISE_DIR}/table-summary.qzv"

## Visualization of denoising stats
qiime metadata tabulate \
  --m-input-file "${DENOISE_DIR}/denoising-stats.qza" \
  --o-visualization "${DENOISE_DIR}/denoising-stats.qzv"

# 3. Phylogeny Construction
PHYLO_DIR="${OUT_DIR}/phylogeny"
mkdir -p "$PHYLO_DIR"

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences "${DENOISE_DIR}/rep-seqs.qza" \
  --p-n-threads ${SLURM_CPUS_PER_TASK} \
  --o-alignment "${PHYLO_DIR}/aligned-rep-seqs.qza" \
  --o-masked-alignment "${PHYLO_DIR}/masked-aligned-rep-seqs.qza" \
  --o-tree "${PHYLO_DIR}/unrooted-tree.qza" \
  --o-rooted-tree "${PHYLO_DIR}/rooted-tree.qza"

# 4. Taxonomic Assignment
TAX_DIR="${OUT_DIR}/taxonomy"
mkdir -p "$TAX_DIR"
CLASSIFIER_PATH="${PROJECT_DIR}/QIIME2_DB/silva-138-99-nb-classifier-local.qza"

qiime feature-classifier classify-sklearn \
  --i-reads "${DENOISE_DIR}/rep-seqs.qza" \
  --i-classifier "$CLASSIFIER_PATH" \
  --p-n-jobs ${SLURM_CPUS_PER_TASK} \
  --o-classification "${TAX_DIR}/taxonomy.qza"



qiime metadata tabulate \
  --m-input-file "${TAX_DIR}/taxonomy.qza" \
  --o-visualization "${TAX_DIR}/taxonomy.qzv"

## Create interactive stacked bar plots
qiime taxa barplot \
  --i-table "${DENOISE_DIR}/table.qza" \
  --i-taxonomy "${TAX_DIR}/taxonomy.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --o-visualization "${TAX_DIR}/taxa_bar_plots.qzv"
