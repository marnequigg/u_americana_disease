#!/bin/bash

# ===================== CONFIGURE THESE =====================
GENE_NAME="PQ351261"
REFERENCE="/data/labs/Fant/Quigg/00.genomes/maskedelm_and_diseases.fa"
MIN_DEPTH=10
THREADS=8
BASE="/data/labs/Fant/Quigg/07d.MalSecco_ITS_phylo"   # avoids repetition
# ===========================================================

# Extract just the gene reference
samtools faidx $REFERENCE "$GENE_NAME" > ${BASE}/00.reference/MalS_ITS_reference.fa

process_sample() {
    bam=$1                                  # full path passed in
    sample=$(basename $bam _sorted.bam)     # clean sample name

    echo "Processing $sample..."

    # Index input BAM
    samtools index $bam

    # Extract reads for gene of interest — consistent _ITS.bam naming throughout
    samtools view -b $bam "$GENE_NAME" > ${BASE}/02.subset_ITS/${sample}_ITS.bam
    samtools index ${BASE}/02.subset_ITS/${sample}_ITS.bam

    # Call variants
    bcftools mpileup -f ${BASE}/00.reference/MalS_ITS_reference.fa \
        ${BASE}/02.subset_ITS/${sample}_ITS.bam | \
    bcftools call -mv -Oz -o ${BASE}/02.subset_ITS/${sample}.vcf.gz
    bcftools index ${BASE}/02.subset_ITS/${sample}.vcf.gz

    # Mask low-depth regions
    samtools depth -a ${BASE}/02.subset_ITS/${sample}_ITS.bam | \
    awk -v d=$MIN_DEPTH '$3 < d {print $1"\t"($2-1)"\t"$2}' > ${BASE}/02.subset_ITS/${sample}_low_depth.bed

    # Generate consensus
    bcftools consensus -f ${BASE}/00.reference/MalS_ITS_reference.fa \
        -m ${BASE}/02.subset_ITS/${sample}_low_depth.bed \
        ${BASE}/02.subset_ITS/${sample}.vcf.gz > ${BASE}/02.subset_ITS/${sample}_consensus.fa

    # Rename FASTA header to sample name
    sed -i "s/>.*/>${sample}/" ${BASE}/02.subset_ITS/${sample}_consensus.fa

    echo "Done: $sample"
}

export -f process_sample
export GENE_NAME MIN_DEPTH BASE

# Run in parallel — pass full paths from the INPUT bam folder
ls ${BASE}/01.sorted_bams/*.bam | parallel -j $THREADS process_sample {}

# Combine all consensus sequences
cat ${BASE}/00.reference/MalS_ITS_reference.fa \
    ${BASE}/02.subset_ITS/*_consensus.fa > all_sequences.fa

# Align
echo "Running MAFFT alignment..."
mafft --auto --thread $THREADS all_sequences.fa > aligned.fa

# Build tree
echo "Running IQ-TREE..."
iqtree2 -s aligned.fa -m TEST -bb 1000 -nt AUTO -o "$GENE_NAME"

echo "Done! Tree file: aligned.fa.treefile"
