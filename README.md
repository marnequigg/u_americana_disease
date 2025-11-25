# American Elm Disease Analysis Pipeline

![graphic of pipeline steps](disease_pipeline.png)
This is a graphic that depicts the pipeline used for this portion of the American Elm Project. This shows that it is part "d", which just means that it was the last step of my project that I actually did. Please reference the other GitHub projects I have to see the other pieces of this project.

## Step 0: Prep for Analysis
### Amplicons
For this, I used a custom amplicon panel that targets regions from American elm (for PopGen analysis) and three common diseases: Dutch elm disease (Ophiostoma novo-ulmi), Elm yellows (Candidatus Phytoplasma ulmi), and Mal Secco (Plenodomus trachiephilus). We will only be using the disease gene regions for this part of the project. Amplicons were amplified with PCR and sequenced.

### Trimming
I trimmed the reads with Trimmomatic. The code for this is available on the other GitHub project for American elm.
