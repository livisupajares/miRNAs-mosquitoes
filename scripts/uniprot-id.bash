#!/bin/bash

# ~~~~~~ TXT PARSER FOR PANTHER DB ~~~~~~ #
# This program parses all .txt files with UniprotKB IDs from a specific folder. 
# It removes their quotation marks, commas and puts one ID per line.
# TODO: Refactor this file into a better cli where it lets you pick which root
# folder you want to work with. Might use the gum package for eye candy.

# Define the root folder where your input files are located
root_folder_miranda_aae="/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/results/uniprots-aae-miranda"

root_folder_ts_aae="/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/results/panther/uniprots-aae-targetspy"

root_folder_miranda_aal="/home/cayetano/livisu/git/miRNAs-mosquitoes/results/uniprots-aal-miranda"
root_folder_ts_aal="/home/cayetano/livisu/git/miRNAs-mosquitoes/results/uniprots-aal-targetspy"

# Loop through all .txt files in the root folder
for input_file in "$root_folder_ts_aal"/*.txt; do
    # Generate the output file name by appending "_output" to the input file name
    output_file="${input_file%.txt}_output.txt"

    # Check if the input file exists
    if [ ! -f "$input_file" ]; then
        echo "Input file $input_file does not exist. Skipping..."
        continue
    fi

    # Transform the file
    echo "Processing $input_file -> $output_file"
    sed 's/"//g' "$input_file" | tr ',' '\n' > "$output_file"

    echo "Transformation complete for $input_file. Output saved to $output_file"
done

echo "All files processed."
