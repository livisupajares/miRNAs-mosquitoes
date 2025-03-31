#!/usr/bin/env bash

# How many sequences in total
# grep -c "^>" "$1" (input file)

# USAGE = ./split-all-prot-fasta.sh input_file.fasta first_half.fasta second_half.fasta

# Add root folder
UPCH_ROOT="/home/cayetano/livisu/git/miRNAs-mosquitoes/"

# Check if all required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_fasta_file> <output_part1> <output_part2>"
    exit 1
fi

# Define input variables
INPUT_FILE="$1"
PART1="$2"
PART2="$3"

# Concatenate UPCH_ROOT to each variable
INPUT_FILE=${UPCH_ROOT}${INPUT_FILE}
PART1=${UPCH_ROOT}${PART1}
PART2=${UPCH_ROOT}${PART2}

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi

# Pass the output file names as variables to the awk script
awk -v part1="$PART1" -v part2="$PART2" -f split-fasta.awk "$INPUT_FILE"

echo "FASTA file has been split into '$PART1' and '$PART2'."