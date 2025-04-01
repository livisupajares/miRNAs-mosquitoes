#!/usr/bin/awk -f

BEGIN {
    max_residues = 10000  # Maximum residues per file
    file_count = 1        # Counter for output files
    current_residues = 0  # Residue count for the current file
    output_dir = "/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq/output_dir/"  # Directory to store output files
    log_file = "/Users/skinofmyeden/Documents/01-livs/14-programming/git/miRNAs-mosquitoes/sequences/miRNAtarget_prot_seq/debug.log" # Log file for debugging messages

    # Debugging: Print the output directory
    print "Attempting to create output directory: " output_dir > log_file

    # Create the output directory if it doesn't exist
    mkdir_status = system("mkdir -p " output_dir)
    if (mkdir_status != 0) {
        print "Error: Failed to create directory '" output_dir "'" > log_file
        exit 1
    } else {
        print "Output directory created successfully: '" output_dir "'" > log_file
    }

    # Initialize the first output file
    output_file = sprintf("%spart%d.fasta", output_dir, file_count)
    if (output_file == "") {
        print "Error: Failed to initialize output_file. Check output_dir and file_count." > log_file
        exit 1
    }
    print "Creating output file: " output_file > log_file
}

/^>/ {
    # Read the header line
    header = $0

    # Debugging: Print the header being processed
    print "Processing header: " header > log_file

    # Read the sequence lines
    seq = ""
    while (getline > 0) {
        # Skip empty lines
        if ($0 ~ /^$/) {
        continue
        } 
        
        # Stop reading when encountering a new header
        if (substr($0, 1, 1) == ">") {
            # Reprocess the new header line
            unprocessed_header = $0
            break
        }

        # Append the sequence line
        seq = seq $0
    }

    # Calculate the length of the sequence
    seq_length = length(seq)

    # Debugging: Print sequence details
    print "Processing sequence: " header ", residues: " seq_length > log_file

    # Check if adding this sequence exceeds the limit
    if (current_residues + seq_length > max_residues) {
        # Start a new file
        file_count++ # Increment the file counter
        current_residues = 0 # Reset the residue counter
        output_file = sprintf("%spart%d.fasta", output_dir, file_count) # Update output file name
        if (output_file == "") {
            print "Error: Failed to update output_file. Check output_dir and file_count." > log_file
            exit 1
        }
        print "Creating new output file: " output_file > log_file
    }

    # Write the sequence to the current file
    if (output_file == "") {
        print "Error: Attempting to write to an empty output_file." > log_file
        exit 1
    }
    print header > output_file
    print seq > output_file

    # Update the residue count for the current file
    current_residues += seq_length

    # Debugging: Print cumulative residue count for the current file
    print "Current file: " output_file ", cumulative residues: " current_residues > log_file

    # If we exited the loop early due to encountering a new header, reprocess it
    if (substr($0, 1, 1) == ">") {
        $0 = $0  # Reprocess the new header line
    }
}