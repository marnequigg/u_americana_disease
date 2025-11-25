cd /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples
conda activate blast

# open a nano
nano assemble_contigs.sh

###copy this in the nano
#!/bin/bash

# Set paths
BAM_DIR="/data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/02.sorted_bams"
BLAST_DB="/home/general/Databases/nt/nt"

# Loop through BAM files
for bam in "$BAM_DIR"/*_sorted.bam; do
  sample=$(basename "$bam" | sed 's/_sorted.bam//')

  echo "🔄 Processing sample: $sample"

  # Step 1: Subset BAM
  samtools view -h "$bam" \
    | awk '$3 !~ /^Chr[0-9][0-9]$/ && $3 !~ /scaffold/ || $1 ~ /^@/' \
    | samtools view -bS - > "${BAM_DIR}/${sample}_subset.bam"

  # Step 2: Convert to FASTQ
  samtools fastq "${BAM_DIR}/${sample}_subset.bam" > "${BAM_DIR}/${sample}_subset.fastq"

  # Step 3: Run MEGAHIT assembly
  megahit -r "${BAM_DIR}/${sample}_subset.fastq" -o "${BAM_DIR}/${sample}_assembly"

  # Step 4: Run BLAST on assembled contigs
  blastn -query "${BAM_DIR}/${sample}_assembly/final.contigs.fa" \
    -db "$BLAST_DB" \
    -out "${BAM_DIR}/${sample}_blast.tsv" \
    -outfmt "6 qseqid sseqid pident length qlen evalue bitscore staxids sscinames" \
    -max_target_seqs 10 \
    -num_threads 30

  echo "✅ Done with $sample"
done
###
#exit the nano

#change permissions
chmod +x assemble_contigs.sh

#run the script
screen -L ./assemble_contigs.sh
