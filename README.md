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
├── results # scripts outputs with no fasta files
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
└── sequences # output fasta files
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

#### Step 0: miRBase v23.1 update and DENV-2 literature check

Run from the project root, in this order (all R; Table S1 is only read):

```bash
Rscript scripts/00-mirbase-scrapping/02-compare-mirbase-v22-v23.R    # miRBase v22.1 vs v23.1
Rscript scripts/00-mirbase-scrapping/03-reconcile-s1-v23.R          # Table S1 vs v23.1
Rscript scripts/00-mirbase-scrapping/04-build-aae-mirna-v23.R       # aae-mirna-v23.csv
Rscript scripts/00-mirbase-scrapping/05-literature-vs-v23.R         # paper findings vs v23.1 vs S1
Rscript scripts/00-mirbase-scrapping/06-build-s1-literature-tab.R   # draft S1 rows for what S1 is missing
Rscript scripts/00-mirbase-scrapping/07-build-literature-s1-combined.R  # one table: findings + S1 columns + evidence
```

Inputs, outputs, matching rules and status values are documented in
[`results/00-mirbase-v23/README.md`](results/00-mirbase-v23/README.md).

> ⚠️ Details and flowcharts for how each main step was done is included [here]() or in the `/docs` directory. Some steps have been done manually so we want to include how we did them.

## Data Availability
Processed data are in `/sequences` and `/results` directories.

## Citation
If you use this code or data in your work, please cite (manuscript in progress).

## Contact
For questions about the code or data, open an issue or email: [livisu.pajares.r@upch.pe]
