# miRNAs and their targets in Mosquitoes during DENV-2 infection: Data Wrangling & Analysis Pipeline

This repository contains code that supports a data pipeline for a research project investigating the target prediction of miRNAs up-regulated during DENV-2 infection in *Aedes aegypti* (aae) and *Aedes albopictus* (aal) species of vector mosquitoes.

> This is not a standalone software package — it's a collection of analysis scripts developed during the course of research.

---

## Project Overview
- **Objective**: ...
- **Key questions**: ...
- **Data sources**: 
  - miRBase: for some *Aedes aegypti* miRNA sequences.
  - VectorBase: for *Aedes albopictus* 3'UTR mRNA sequences and names.
  - Ensembl Metazoa: for *Aedes aegypti* 3'UTR mRNA sequences and names.

---
## Repository Structure

```bash
.
├── databases # Databases used in the project
│   ├── 00-mirbase-scrapping
│   ├── 01-isolating-mature-sequences
│   │   ├── aae-mirna.csv # database curation from data mining
│   │   └── aal-mirna.csv # database curation from data mining
│   ├── 02-target-prediction
│   └── 03-enrichment
├── environment.yml
├── miRNAs-mosquitoes.Rproj
├── README.md # You are here! ツ
├── renv
├── renv.lock
├── requirements.txt
├── results # Results of the analysis (no fasta files)
│   ├── 00-isolating-mature-sequences # .csv files from isolating mature sequences from main database
│   ├── 01-target-prediction
│   └── 02-enrichment
├── scripts
│   ├── 00-mirbase-scrapping
│   ├── 01-isolating-mature-sequences
│   ├── 02-similarities-mirna-aedes
│   ├── 03-mirna-target-pred
│   ├── 04-enrichment
│   ├── functions.R
└── sequences # Fasta files used in the project
    ├── 01-isolating-mature-sequences
    ├── 02-similarities-mirna-aedes
    ├── 03-target-prediction
    └── 04-enrichment
```

## Usage

### Prerequisites
> 💻 This repo has been tested on: MacOS Sequoia 15.5 (M1), and Ubuntu 22.04 LTS (x86-64).

- Python 3.13.2+ and R 4.5.1+
- Tools: `mamba`, `miRanda`, etc.
- Recommended: Use Conda/Mamba with miniforge3 to manage environments

### Setup

```bash
# Clone the repo
git clone https://github.com/livisupajares/miRNAs-mosquitoes.git
cd miRNAs-mosquitoes

# Create environment (if provided)
mamba env create -f environment.yml
```
### Running the Pipeline
The workflow follows these main steps: 

> ⚠️ Details and flowcharts for how each main step was done is included [here]() or in the `/docs` directory. Some steps have been done manually so we want to include how we did them.

## Data Availability
Processed data are in `/sequences` and `/results` directories.

## Citation
If you use this code or data in your work, please cite (manuscript in progress).

## Contact
For questions about the code or data, open an issue or email: [livisu.pajares.r@upch.pe]
