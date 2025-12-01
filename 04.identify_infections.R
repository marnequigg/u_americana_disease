#make personal library directory
mkdir -p ~/R/x86_64-pc-linux-gnu-library/4.1.2

cd /data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples

#open R
R 

#or open a nano script
nano count_diseases.R

#set library directory
.libPaths("~/R/x86_64-pc-linux-gnu-library/4.1.2")

install.packages("tidyverse")
library(tidyverse)
install.packages("purrr")
library(purrr)
install.packages("stringr")
library(stringr)
install.packages("readr")
library(readr)
install.packages("tidyr")
library(tidyr)
install.packages("dplyr")
library(dplyr)

# Define target families
target_families_genus <- c("Ophiostomataceae", "Ophiostoma", "ulmi", "Acholeplasmataceae", "Phytoplasma", "Leptosphaeriaceae", "Plenodomus")

# Function to process one file
process_taxonomy_file_genus <- function(file_path) {
  sample_id <- str_remove(basename(file_path), "_taxonomy_full.txt")
  
  # Read file line-by-line as raw text
  lines <- read_lines(file_path)
  
  # Count occurrences of each family
  counts <- map_int(target_families_genus, function(fam) {
    sum(str_detect(lines, fixed(fam)))
  })
  
  # Return as tibble
  tibble(Sample = sample_id, !!!set_names(counts, target_families_genus))
}

# Directory containing taxonomy files
taxonomy_dir <- "/data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples/07.blast_results"
all_files <- list.files(taxonomy_dir, pattern = "_taxonomy_full.txt", full.names = TRUE)

# Process all files
summary_df <- map_dfr(all_files, process_taxonomy_file_genus)

# Save to CSV
setwd("/data/labs/Fant/Quigg/03c.alignment_diseases+elm/redo_missing_samples")
write_csv(summary_df, "disease_counts_by_individual.csv")

#exit nano 
chmod +x count_diseases.R
screen -L Rscript count_diseases.R
