#!/bin/bash
set -e

# Base directory setup
BASE_DIR="$(pwd)/Test1/InterviewProject"
mkdir -p "${BASE_DIR}/fastq_files" "${BASE_DIR}/metadata" "${BASE_DIR}/results" "${BASE_DIR}/QIIME2_DB"

cd "${BASE_DIR}/fastq_files"

# Download SRA FASTQ files
SRA_ACCESSIONS=(
  ERR011073 ERR011086 ERR011070 ERR011076 ERR011067 ERR011063 ERR011077 ERR011060 
  ERR011083 ERR011080 ERR011072 ERR011082 ERR011058 ERR011062 ERR011068 ERR011065 
  ERR011075 ERR011085 ERR011081 ERR011078 ERR011084 ERR011079 ERR011066 ERR011069 
  ERR011064 ERR011074 ERR011059 ERR011071 ERR011061
)

for acc in "${SRA_ACCESSIONS[@]}"; do
    wget -nc "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR011/${acc}/${acc}.fastq.gz"
done

# Generate dynamic manifest file with relative/absolute paths
MANIFEST="${BASE_DIR}/metadata/manifest.tsv"
printf "sample-id\tabsolute-filepath\tdirection\n" > "$MANIFEST"
for f in "${BASE_DIR}/fastq_files"/*.fastq.gz; do
    sample=$(basename "$f" .fastq.gz)
    printf "%s\t%s\tforward\n" "$sample" "$f" >> "$MANIFEST"
done

# Train Naive Bayes SILVA Classifier
cd "${BASE_DIR}/QIIME2_DB"
wget -nc "https://data.qiime2.org/2024.2/common/silva-138-99-seqs.qza"
wget -nc "https://data.qiime2.org/2024.2/common/silva-138-99-tax.qza"

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva-138-99-seqs.qza \
  --i-reference-taxonomy silva-138-99-tax.qza \
  --o-classifier silva-138-99-nb-classifier-local.qza

# Process Metadata
cd "${BASE_DIR}/metadata"
if [ -f "italiantable.txt" ]; then
    awk -F'\t' '{print $1,$6,$9,$10,$11,$12,$13,$16}' OFS='\t' italiantable.txt | \
    awk 'BEGIN{print "sample-id\trace\tgender\tage\tantibiotic_regimen\tbirth_delivery\tdisease_stage\tdiet"} 1' > sample_metadata.tsv
    sed -i 's/vegeterian diet (derived from sorghum, millet, black eyed pea)/vegetarian diet/g' sample_metadata.tsv
    sed -i 's/"//g' sample_metadata.tsv
fi
