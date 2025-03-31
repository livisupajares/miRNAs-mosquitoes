#!/usr/bin/env bash

# How many sequences in total
# grep -c "^>" "$1" (input file)

# USAGE = ./split-all-prot-fasta.sh input_file.fasta

# Check if all required arguments are provided. In this case, -ne should be 1.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_fasta_file>"
    exit 1
fi

# Define input variables
INPUT_FILE="$1"

# Debugging: Print the received argument
echo "Received input file: $INPUT_FILE"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi

# Call the awk script to split the FASTA file
echo "Processing input file: $INPUT_FILE"
awk -f split-fasta-by-residues.awk "$INPUT_FILE"

# Check if output files were created
if [ -d "output_dir" ]; then
    echo "FASTA file has been split into parts with <= 10,000 residues per file."
    echo "All output files are saved in the 'output_files/' directory."
    ls -l output_files/
else
    echo "Error: Output directory 'output_files/' was not created."
    exit 1
fi