#open a new nano
nano execute_samples.sh

###copy this into the nano###
#!/bin/bash

# Sample list based on paired R1 files
SAMPLE_LIST=$(ls /data/labs/Fant/Quigg/batch_3_missing_processing/01.trimmed/*_R1_paired.fastq.gz | sed 's|.*/||; s/_R1_paired.fastq.gz//' | sort -u)

# Run 5 samples in parallel
echo "$SAMPLE_LIST" | parallel -j 5 ./align_samples.sh

###

#exit the nano

#change permissions
chmod +x execute_samples.sh

cd /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples
mkdir delete
mv *.sam /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/delete
