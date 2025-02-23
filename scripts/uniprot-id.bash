#!/bin/bash

# Define the root folder where your input files are located
root_folder_miranda=" /Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/results/panther/aae-miranda-pantherdb/uniprots-aae-miranda"

root_folder_ts="/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/results/panther/aae-targetspy-pantherdb/uniprots-aae-targetspy"

# Loop through all .txt files in the root folder
for input_file in "$root_folder_ts"/*.txt; do
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
