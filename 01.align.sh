#activate the conda environment
conda activate blast

#index the reference
bwa index /data/labs/Fant/Quigg/genomes/maskedelm_and_diseases.fa

#time to make a new folder for this
cd /data/labs/Fant/Quigg/03c.alignment_diseases+elm
mkdir redo_missing_samples
cd ./redo_missing_samples


#open a nano
nano align_samples.sh

###copy and paste all of this into the nano###
#!/bin/bash

set -uo pipefail
SAMPLE="$1"

# Paths
FASTQ_DIR="/data/labs/Fant/Quigg/batch_3_missing_processing/01.trimmed"
REFERENCE="/data/labs/Fant/Quigg/00.genomes/maskedelm_and_diseases.fa"
ALIGNMENT_DIR="/data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples"
BAM_DIR="$ALIGNMENT_DIR/01.bams"
SORTED_DIR="$ALIGNMENT_DIR/02.sorted_bams"
FLAGSTAT_DIR="$ALIGNMENT_DIR/03.flagstats"
LOGFILE="$ALIGNMENT_DIR/04.align_status.log"

mkdir -p "$BAM_DIR" "$SORTED_DIR" "$FLAGSTAT_DIR"

R1="$FASTQ_DIR/${SAMPLE}_R1_paired.fastq.gz"
R2="$FASTQ_DIR/${SAMPLE}_R2_paired.fastq.gz"
SAM="$ALIGNMENT_DIR/${SAMPLE}.sam"
BAM="$BAM_DIR/${SAMPLE}.bam"
SORTED="$SORTED_DIR/${SAMPLE}_sorted.bam"
NSORT="$ALIGNMENT_DIR/${SAMPLE}_nsort.sam"
FLAGSTAT="$FLAGSTAT_DIR/${SAMPLE}_flagstat.txt"

# Logging functions
log()   { echo -e "[\033[1;36m$SAMPLE\033[0m] $1"; }
status(){ echo -e "${SAMPLE}\t$1\t$2" >> "$LOGFILE"; }

# Input check
[[ ! -f "$R1" || ! -f "$R2" ]] && status "FAILED" "Missing FASTQs" && exit 1

log "Aligning with BWA..."
if ! bwa mem -M -t 4 "$REFERENCE" "$R1" "$R2" > "$SAM"; then
    status "FAILED" "bwa mem error" && exit 2
fi

log "Converting SAM to BAM..."
if ! samtools view -b "$SAM" -o "$BAM"; then
    status "FAILED" "SAM to BAM failed" && exit 3
fi

log "Sorting BAM by coordinate..."
if ! samtools sort -o "$SORTED" "$BAM"; then
    status "FAILED" "BAM sort failed" && exit 4
fi

log "Generating flagstat..."
if ! samtools flagstat "$SORTED" > "$FLAGSTAT"; then
    status "FAILED" "flagstat failed" && exit 5
fi

log "Sorting SAM by read name..."
if ! samtools sort -n "$SAM" -o "$NSORT"; then
    status "FAILED" "name sort failed" && exit 6
fi

log "✅ Sample completed successfully."
status "SUCCESS" "All steps completed"
###copy and paste all of this in the nano###

#update permissions so you can execute it
chmod +x align_samples.sh

#here you have two options: you can either run the script with ./align_samples.sh or you can use the script below to run multiple samples at once

#open a new nano
nano execute_samples.sh

###copy this into the nano###
#!/bin/bash

# Sample list based on paired R1 files
SAMPLE_LIST=$(ls /data/labs/Fant/Quigg/batch_3_missing_processing/01.trimmed/*_R1_paired.fastq.gz | sed 's|.*/||; s/_R1_paired.fastq.gz//' | sort -u)

# Run 5 samples in parallel
echo "$SAMPLE_LIST" | parallel -j 5 ./align_samples.sh

###

#exit
chmod +x execute_samples.sh

cd /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples
mkdir delete
mv *.sam /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/delete
