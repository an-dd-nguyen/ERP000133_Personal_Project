#!/bin/bash
#SBATCH --mem=64GB
#SBATCH -c 10
#SBATCH --time=2:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --output=Picrust_Pathway_Annotation_%j.slurm

set -e

PROJECT_DIR="$(pwd)"
META_DIR="${PROJECT_DIR}/metadata"
OUT_DIR="${PROJECT_DIR}/results"
DENOISE_DIR="${OUT_DIR}/denoise_pyro"
PHYLO_DIR="${DENOISE_DIR}/phylogeny"
TAX_DIR="${DENOISE_DIR}/taxonomy"
PICRUST_DIR="${OUT_DIR}/picrust"

picrust2_pipeline.py \
   -s "${PICRUST_DIR}/exported_seqs/dna-sequences.fasta" \
   -i "${PICRUST_DIR}/exported_table/feature-table.biom" \
   -o "${PICRUST_DIR}/picrust2_out" \
   -p ${SLURM_CPUS_PER_TASK}

gunzip -c "${PICRUST_DIR}/picrust2_out/pathways_out/path_abun_unstrat.tsv.gz" > "${PICRUST_DIR}/path_abun_unstrat.tsv"

add_descriptions.py \
   -i "${PICRUST_DIR}/picrust2_out/pathways_out/path_abun_unstrat.tsv.gz" \
   -m METACYC \
   -o "${PICRUST_DIR}/path_abun_unstrat_described.tsv"

echo -e "Feature ID\tTaxon" > "${PICRUST_DIR}/pathway_described_taxonomy.tsv"

tail -n +2 "${PICRUST_DIR}/path_abun_unstrat_described.tsv" | awk -F'\t' '{print $1"\t"$2}' >> "${PICRUST_DIR}/pathway_described_taxonomy.tsv"

