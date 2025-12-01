# American Elm Disease Analysis Pipeline

![graphic of pipeline steps](disease_pipeline.png)
This is a graphic that depicts the pipeline used for this portion of the American Elm Project. This shows that it is part "d", which just means that it was the last step of my project that I actually did. Please reference the other GitHub projects I have to see the other pieces of this project.

## Step 0: Prep for Analysis
### Amplicons
For this, I used a custom amplicon panel that targets regions from American elm (for PopGen analysis) and three common diseases: Dutch elm disease (Ophiostoma novo-ulmi), Elm yellows (Candidatus Phytoplasma ulmi), and Mal Secco (Plenodomus trachiephilus). We will only be using the disease gene regions for this part of the project. Amplicons were amplified with PCR and sequenced.

### Trimming
I trimmed the reads with Trimmomatic. The code for this is available on the other GitHub page for American elm population genetics.

### NCBI Nucleotide Database
I used a locally downloaded NCBI Nucleotide Database. I did this to standardize which version of the database is used for the entirety of the project. It is an unbelievably large file, so unless you have extensive storage, I would recommend just using the remote option and running Blastn remotely on NCBI's servers. It took multiple days to download the database.
I also had to download the associated taxonomy database. This can map the accession number back to the taxonomy of the organism.

### Conda
I used a conda to download the necessary programs for this analysis. The script for this is in 00.prep.sh.

## Step 1) Align to Reference
The associated script with this step is 01.align.sh and 01b.execute_alignment.sh. Here, I mapped the reads to both the American elm genome and the disease gene regions. I concatenated them together and aligned the reads with BWA. Trials revealed that a lot of the reads originating from the American elm genome were mapping to the disease genes, so I opted to align to both to mitigate the misalignments. Then the resulting sam file is converted to bam and sorted. Flagstat files are generated for a quality check, then sam files are sorted. The sam files can be deleted, they won't be used again. To run multiple files in parallel, use script 01b to run multiple samples at the same time. If not, just execute script 01 using whatever method is preferred.

## Step 2) Assemble Contigs
Here we run the script 02.assemble_contigs.sh. This subsets the reads originating from the diseases and converts the file to a fastq with samtools. Then, the reads are assembled into longer contigs with MegaHit. Finally, it runs Blastn to identify the origin of the contigs. It retains the top 10 hits per contig.

## Step 3) Map Taxonomy
Now it's time to run script 03.map_taxa.sh. You can do this the slow way by inputting the accessions into the online Blast database, but this script is a lot faster. This references the locally downloaded taxonomy database associated with the Blast results. There is code in the script to download this database, but I recommend checking to make sure that link is still active. First, I organize all of my files into their respective folders. Then, it extracts the TaxIDs (which are the Blast accessions) and compares them to the taxonomy database. Finally, it reformats the taxonomy string. 

## Step 4) Identify Infections
Almost done! Now, it is time to run script 04.identify_infections.R. In this script, I had to build a personal R library directory. Then you have two options, you can either open R on whatever server you are using then run it line-by-line, or you can make a nano R script and run it all at once. Either way, first you download the necessary packages. Most of them are available within tidyverse. Then it loops through each file and scans the taxonomy files for the target families and genera. It calculates the number of occurrences of the target family or genera present per individual and outputs a csv file. 

### Final analysis
This is the last step that involves scripts and coding, yay! Here, I have script 05.disease_analysis.Rmd. This is an R markdown file, so you can download this and open it in Rstudio, thaat way you can just press the play button and each code chunk will run. There is code to make a big csv file to import to whatever mapping software (ArcGIS, qGIS, etc.). The csv includes "low", "high", or "uninfected" for each disease, as well as the coinfections. It also includes the coordinates and year the tree was sampled from. There is also code to identify the oldest infection in the dataset per disease, and the number of coinfections.

### Map it!
I used ArcGIS to map the infections across the landscape, but it is possible to use any sort of mapping software.
