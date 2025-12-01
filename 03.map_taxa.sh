#download the taxonomy database (check to make sure this is the updated link, I did this in September 2025)
wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
tar -xvzf taxdump.tar.gz

#organize the files into their own folders
mkdir 04.subset_bams
mv /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/02.sorted_bams/*_subset.bam /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/04.subset_bams
mkdir 05.fastq
mv /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/02.sorted_bams/*.fastq /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/05.fastq
mkdir 06.assembly
mv /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/02.sorted_bams/*_assembly /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/06.assembly
mkdir 07.blast_results
mv /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/02.sorted_bams/*.tsv /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/07.blast_results

###make a nano
nano map_tax.sh

###
#!/bin/bash

# Set working directory and taxdump location
BLAST_DIR="/data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/07.blast_results"
TAXDUMP_DIR="/data/labs/Fant/Quigg/03c.alignment_diseases+elm/taxdump"
LOG_FILE="${BLAST_DIR}/taxonomy_mapping.log"

# Start log
echo "🌿 Starting full taxonomy mapping: $(date)" > "$LOG_FILE"

# Loop through BLAST output files
for blast_file in "$BLAST_DIR"/*_blast.tsv; do
  sample=$(basename "$blast_file" | sed 's/_blast.tsv//')
  echo "🔍 Processing $sample" | tee -a "$LOG_FILE"

  # Step 1: Extract unique TaxIDs
  taxid_file="${BLAST_DIR}/${sample}_taxids.txt"
  cut -f8 "$blast_file" | sort | uniq > "$taxid_file"
  if [ $? -ne 0 ]; then
    echo "❌ Error extracting TaxIDs from $blast_file" | tee -a "$LOG_FILE"
    continue
  fi

  # Step 2: Map TaxIDs to full lineage
  lineage_file="${BLAST_DIR}/${sample}_lineage.txt"
  taxonkit lineage --data-dir "$TAXDUMP_DIR" < "$taxid_file" > "$lineage_file"
  if [ $? -ne 0 ]; then
    echo "❌ TaxonKit lineage failed for $sample" | tee -a "$LOG_FILE"
    continue
  fi

  # Step 3: Reformat lineage into structured taxonomy
  taxonomy_file="${BLAST_DIR}/${sample}_taxonomy_full.txt"
  taxonkit reformat "$lineage_file" -f "{k};{p};{c};{o};{f};{g};{s}" > "$taxonomy_file"
  if [ $? -ne 0 ]; then
    echo "❌ TaxonKit reformat failed for $sample" | tee -a "$LOG_FILE"
    continue
  fi

  echo "✅ Finished $sample" | tee -a "$LOG_FILE"
done

echo "🎉 Full taxonomy mapping complete: $(date)" >> "$LOG_FILE"
### exit nano

#change permissions
chmod +x map_tax.sh

#run the script!
screen -L ./map_tax.sh
