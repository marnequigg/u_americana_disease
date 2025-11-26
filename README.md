# American Elm Disease Analysis Pipeline

![graphic of pipeline steps](disease_pipeline.png)
This is a graphic that depicts the pipeline used for this portion of the American Elm Project. This shows that it is part "d", which just means that it was the last step of my project that I actually did. Please reference the other GitHub projects I have to see the other pieces of this project.

## Step 0: Prep for Analysis
### Amplicons
For this, I used a custom amplicon panel that targets regions from American elm (for PopGen analysis) and three common diseases: Dutch elm disease (Ophiostoma novo-ulmi), Elm yellows (Candidatus Phytoplasma ulmi), and Mal Secco (Plenodomus trachiephilus). We will only be using the disease gene regions for this part of the project. Amplicons were amplified with PCR and sequenced.

### Trimming
I trimmed the reads with Trimmomatic. The code for this is available on the other GitHub project for American elm.

### NCBI Nucleotide Database
I used a locally downloaded NCBI Nucleotide Database. I did this to standardize which version of the database is used for the entirety of the project. It is an unbelievably large file, so unless you have extensive storage, I would recommend just using the remote option and running Blastn remotely on NCBI's servers. It took multiple days to download the database.

### Conda
I used a conda to download the necessary programs for this analysis. The script for this is in 00.prep.sh.

## Step 1) Align to Reference
The associated script with this step is 01.align.sh and 01b.execute_alignment.sh. Here, I mapped the reads to both the American elm genome and the disease gene regions. I concatenated them together and aligned the reads with BWA. Trials revealed that a lot of the reads originating from the American elm genome were mapping to the disease genes, so I opted to align to both to mitigate the misalignments. Then the resulting sam file is converted to bam and sorted. Flagstat files are generated for a quality check, then sam files are sorted. The sam files can be deleted, they won't be used again. To run multiple files in parallel, use script 01b to run multiple samples at the same time. If not, just execute script 01 using whatever method is preferred.

## Step 2) Assemble Contigs
Here we run the script 02.assemble_contigs.sh. This subsets the reads originating from the diseases and converts the file to a fastq with samtools. Then, the reads are assembled into longer contigs with MegaHit. Finally, it runs Blastn to identify the origin of the contigs. 

## Step 3) Identify Infections
