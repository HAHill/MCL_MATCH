!/bin/bash

module load python/3.11.3
module load cnvkit/0.9.9

# Directories
DATA_DIR="rsrch5/scratch/plm/hahill1/files/yliu/aligned"
OUTPUT_DIR="rsrch5/scratch/plm/hahill1/files/yliu/cnvkit"
TARGET_BED="rsrch5/scratch/plm/hahill1/files/support_files/S31285117_hg38/S31285117_Targets.txt"
REFERENCE_FASTA="rsrch5/scratch/plm/hahhill1/files/support_files/Homo_sapiens_assembly38.fasta"

# Sample files
NORMAL_BAMS=(
 "MCH65_SG65.merged.d_r_bam"
 "MCH63_SG63.merged.d_r_bam"
 "MCH66_SG66.merged.d_r_bam" 
 "MCH67_SG67.merged.d_r_bam" 
 "MCH55_SG55.merged.d_r_bam"
 "MCH56_SG56.merged.d_r_bam"
 "MCH62_SG62.merged.d_r_bam"
 "MCH60_SG60.merged.d_r_bam"
 "MCH53_SG53.merged.d_r_bam"
 "1-MCH1_S6G_merged.d_r_bam"
 "1-MCH2_S7G_merged.d.r_bam"
 "1-MCH3_S8G_merged.d.r_bam"
 "1-MCH4_S9G_merged.d.r_bam"
 "1-MCH5_S10G_merged.d.r_bam")

TUMOR_BAM="MCH65_S65.merged.d_r_bam"

# 1. Create a reference from normal samples
cnvkit.py batch "${NORMAL_BAMS[@]/#/$DATA_DIR/}" \
    --normal \
    --targets $TARGET_BED \
    --antitargets $ANTITARGET_BED \
    --fasta $REFERENCE_FASTA \
    --output-reference reference.cnn \
    --output-dir . \
    --processes 4

# 2. Run CNVkit on tumor sample using the reference
cnvkit.py batch "$DATA_DIR/$TUMOR_BAM" \
    --normal reference.cnn \
    --targets $TARGET_BED  \
    --fasta $REFERENCE_FASTA \
    --output-dir . \
    --processes 4

# 3. Visualize CNV profile
cnvkit.py scatter ${TUMOR_BAM%.bam}.cnr -s ${TUMOR_BAM%.bam}.cns -o ${TUMOR_BAM%.bam}_scatter.pdf

# 4. Heatmap (optional for multiple samples)
cnvkit.py heatmap *.cnn -o heatmap.pdf

# 5. Export results to text
cnvkit.py export seg ${TUMOR_BAM%.bam}.cns -o ${TUMOR_BAM%.bam}.seg

echo "CNVkit analysis complete."
