#start by making your conda environment for blast
conda create -n blast python=3.9 
conda activate blast
conda install bioconda::blast
conda install bioconda::seqtk
conda install bioconda::seqkit
conda install bioconda::MEGAHIT
conda install bioconda::vsearch
