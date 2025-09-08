#!/bin/bash
# ====================================================
# clean-fasta-headers.sh
# Preprocess mosquito fasta proteomes for OrthoFinder
# - Keeps ALL entries (including UniParc IDs that start with UPI)
# - Standarizes headers to: >Species|GeneID
# - Generates mapping tables for Cytoscape
# - Runs OrthoFinder (optional)
#
# Usage: bash clean-fasta-headers.sh
# Requirements: seqkit, sed, orthofinder (optional)

# ~~~~~ CONFIGURATION ~~~~~~~
