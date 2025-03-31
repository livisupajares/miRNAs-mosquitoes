#!/usr/bin/awk -f

BEGIN {
    max_residues = 10000  # Maximum residues per file
    file_count = 1        # Counter for output files
    current_residues = 0  # Residue count for the current file
    output_dir = "/home/cayetano/livisu/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq/output_dir"  # Directory to store output files

    # Create the output directory if it doesn't exist
    system("mkdir -p " output_dir)

    # Initialize the first output file
    output_file = sprintf("%spart%d.fasta", output_dir, file_count)
    print "Creating output file: " output_file > "/dev/stderr"
}

/^>/ {
    # Read the header line
    header = $0

    # Read the sequence lines
    seq = ""
    while (getline > 0 && substr($0, 1, 1) != ">") {
        seq = seq $0
    }

    # Calculate the length of the sequence
    seq_length = length(seq)

    # Check if adding this sequence exceeds the limit
    if (current_residues + seq_length > max_residues) {
        # Start a new file
        file_count++
        output_file = sprintf("part%d.fasta", file_count)
        current_residues = 0
    }

    # Write the sequence to the current file
    print header > output_file
    print seq > output_file

    # Update the residue count for the current file
    current_residues += seq_length

    # If we exited the loop early due to encountering a new header, reprocess it
    if (substr($0, 1, 1) == ">") {
        $0 = $0  # Reprocess the new header line
    }
}