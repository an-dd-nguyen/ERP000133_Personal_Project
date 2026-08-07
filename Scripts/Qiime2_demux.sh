#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --time=1:00:00
#SBATCH -c 10
#SBATCH --mail-type=END,FAIL
#SBATCH --output=QIIME2_Demux_%j.slurm

set -e

PROJECT_DIR="$(pwd)"
FASTQ_DIR="${PROJECT_DIR}/fastq_files"
META_DIR="${PROJECT_DIR}/metadata"
OUT_DIR="${PROJECT_DIR}/results"

# 1. Import Sequences
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path "${META_DIR}/manifest.tsv" \
  --output-path "${OUT_DIR}/single-end-demux.qza" \
  --input-format SingleEndFastqManifestPhred33V2

qiime demux summarize \
  --i-data "${OUT_DIR}/single-end-demux.qza" \
  --o-visualization "${OUT_DIR}/demux_summary.qzv"
