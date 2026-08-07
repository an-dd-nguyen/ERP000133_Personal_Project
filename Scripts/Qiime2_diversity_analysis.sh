#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --time=2:00:00
#SBATCH -c 10
#SBATCH --mail-type=END,FAIL
#SBATCH --output=QIIME2_Diversity_%j.slurm

set -e

PROJECT_DIR="$(pwd)"
FASTQ_DIR="${PROJECT_DIR}/fastq_files"
META_DIR="${PROJECT_DIR}/metadata"
OUT_DIR="${PROJECT_DIR}/results"
DENOISE_DIR="${OUT_DIR}/denoise_pyro"
PHYLO_DIR="${OUT_DIR}/phylogeny"
TAX_DIR="${OUT_DIR}/taxonomy"

## Validate Command-Line Input
SAMPLING_DEPTH=$1

if [ -z "$SAMPLING_DEPTH" ]; then
    echo "Error: No sampling depth provided."
    echo "Usage: sbatch $0 <sampling_depth>"
    echo "Example: sbatch $0 6000"
    exit 1
fi

if ! [[ "$SAMPLING_DEPTH" =~ ^[0-9]+$ ]]; then
    echo "Error: Sampling depth must be a positive integer. Provided: '$SAMPLING_DEPTH'"
    exit 1
fi

## Dynamic output directory based on user input
DIVERSITY_DIR="${OUT_DIR}/diversity_sampling_depth_${SAMPLING_DEPTH}"

echo "=== Running Diversity Metrics at Sampling Depth: ${SAMPLING_DEPTH} ==="
echo "Output directory: ${DIVERSITY_DIR}"

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny "${PHYLO_DIR}/rooted-tree.qza" \
  --i-table "${DENOISE_DIR}/table.qza" \
  --p-sampling-depth ${SAMPLING_DEPTH} \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --output-dir "${DIVERSITY_DIR}"

## Test Shannon diversity
qiime diversity alpha-group-significance \
  --i-alpha-diversity "${DIVERSITY_DIR}/shannon_vector.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --o-visualization "${DIVERSITY_DIR}/shannon_group_significance.qzv"

## Test Faith's Phylogenetic Diversity
qiime diversity alpha-group-significance \
  --i-alpha-diversity "${DIVERSITY_DIR}/faith_pd_vector.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --o-visualization "${DIVERSITY_DIR}/faith_pd_group_significance.qzv"

## Test Unweighted UniFrac distance matrix
qiime diversity beta-group-significance \
  --i-distance-matrix "${DIVERSITY_DIR}/unweighted_unifrac_distance_matrix.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --m-metadata-column diet \
  --o-visualization "${DIVERSITY_DIR}/unweighted_unifrac_group_significance.qzv" \
  --p-pairwise

## Test Weighted UniFrac distance matrix
qiime diversity beta-group-significance \
  --i-distance-matrix "${DIVERSITY_DIR}/weighted_unifrac_distance_matrix.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --m-metadata-column diet \
  --o-visualization "${DIVERSITY_DIR}/weighted_unifrac_group_significance.qzv" \
  --p-pairwise

## Test Bray-Curtis distance matrix
qiime diversity beta-group-significance \
  --i-distance-matrix "${DIVERSITY_DIR}/bray_curtis_distance_matrix.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --m-metadata-column diet \
  --o-visualization "${DIVERSITY_DIR}/bray_curtis_group_significance.qzv" \
  --p-pairwise

## Test ASV diversity
qiime diversity alpha-group-significance \
  --i-alpha-diversity "${DIVERSITY_DIR}/observed_features_vector.qza" \
  --m-metadata-file "${META_DIR}/sample_metadata.tsv" \
  --o-visualization "${DIVERSITY_DIR}/observed-features-group-significance.qzv"


echo "=== Exporting Sequence and Table Data for PICRUSt2 ==="
PICRUST_DIR="${OUT_DIR}/picrust"
mkdir -p "$PICRUST_DIR"

qiime tools export \
  --input-path "${DENOISE_DIR}/rep-seqs.qza" \
  --output-path "${PICRUST_DIR}/exported_seqs"

qiime tools export \
  --input-path "${DENOISE_DIR}/table.qza" \
  --output-path "${PICRUST_DIR}/exported_table"


