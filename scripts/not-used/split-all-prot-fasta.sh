#!/usr/bin/env bash

# TODO: Ask for help in forums
# Script to split FASTA files and join sequence lines that are wrapped across multiple lines
# How many sequences in total
# grep -c "^>" "$1" (input file)
# Check number of residues
# grep -v '>' aae-1.fasta | wc -c

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

# Extract the base name of the input file
BASE_NAME=$(basename "$INPUT_FILE" .fasta)

# Construct the path for the cleaned file
CLEAN_FILE="/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq/${BASE_NAME}_clean.fasta" # Save clean file into a variable

# Preprocess the input file: remove empty lines and join wrapped sequence lines
echo "Preprocessing input file: removing empty lines and joining sequence lines ..."
awk '/^>/{if (NR > 1) print ""; print; next} {printf "%s", $0} END {print ""}' "$INPUT_FILE" > "$CLEAN_FILE"

# Ensure the clean file exists
if [ ! -f "$CLEAN_FILE" ]; then
    echo "Error: File '$CLEAN_FILE' not found."
    exit 1
fi

echo "Clean file created: $CLEAN_FILE"

# Call the AWK script to split the FASTA file
echo "Processing cleaned file with AWK splitting script..."
awk -f split-fasta-by-residues.awk "$CLEAN_FILE"

# Define the output directory used by the awk script
OUTPUT_DIR="/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq/output_dir/"

# Check if output files were created
if [ -d "$OUTPUT_DIR" ]; then
    echo "FASTA file has been split into parts with <= 10,000 residues per file."
    echo "All output files are saved in the '$OUTPUT_DIR' directory."
    echo "Output files:"
    ls -l "${OUTPUT_DIR}"part*.fasta
else
    echo "Error: Output directory '$OUTPUT_DIR' was not created."
    exit 1
fi

# Verify that all the sequences have been processed
grep -c "^>" "${OUTPUT_DIR}"part*.fasta | awk -F: '{sum += $2} END {print "Total sequences:", sum}'