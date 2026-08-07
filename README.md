# ERP000133_Personal_Project
Packages/Software:
Miniconda3/22.11.1-1 \
QIIME2-2026.7 \
PICRUSt2-2.4.1 \
R version 4.4.0 \
tidyverse 2.0.0

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





Customized R code for phylum composition/PCoA:
- Download the phylum composition csv files
- df = read_csv("../Downloads/level-2.csv")
- long_df = df |> pivot_longer(!c(index, race, gender, age, antibiotic, birth_delivery, disease_status), names_to = "Phylum", values_to = "Count")
- ggplot(long_df, aes(x = index, y = Count, fill = Phylum)) + theme_bw(base_size = 12) +
    geom_bar(stat = "identity", position = "fill") +
    facet_wrap(~ disease_status, scales = "free_x", strip.position = "bottom") +
    # expand = c(0, 0) removes the 5% padding top and bottom
    scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
    theme_minimal() +
    labs(
        title = "Microbiome Phylum Composition per Sample by Diet",
        x = NULL,
        y = "Relative Abundance (%)",
        fill = "Phylum"
    ) +
    theme(
        axis.text.x = element_blank(),     
        axis.ticks.x = element_blank(),    
        panel.spacing = unit(0.5, "lines"),
        strip.placement = "outside",       
        strip.text = element_text(size = 11, face = "bold"),
        # Optional: Removes grey panel grid lines that might extend into empty space
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
    )

  - Generate ordination file by QIIME2: qiime tools export --input-path weighted_unifrac_pcoa_results.qza --output-path weighted_unifrac_depth5988_pcoa (and another version for depth 9000)
  - df = read_tsv("../Downloads/ordination_9000.txt", skip = 9, col_names = F)
  - df = df[-c(25, 26), ]
  - colnames(df)[1:3] = c("sample-id", "PCo1", "PCo2")
  - metadata = read_tsv("../Downloads/sample_metadata.tsv") (Download the metadata file generated in the QIIME2 pipeline and load it into R session)
  - df = inner_join(df, metadata |> select(c(`sample-id`, diet)))
  - ggplot(df, aes(x = PCo1, y = PCo2, color = diet)) + geom_point() + theme_bw(base_size = 12) + labs(title = "Weighted Unifrac PCoA Visualization") + theme(legend.title = element_blank())
