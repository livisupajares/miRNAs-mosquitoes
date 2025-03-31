#!/usr/bin/awk -f

BEGIN {
    # Add counter
    seq_count = 0
    
    # Variable for progress bar
    total_seqs = 0

    # Count the total number of sequences in the file
    while ((getline line < ARGV[1]) > 0) {
        if (line ~ /^>/) {
            total_seqs++
        }
    }
    close(ARGV[1])
}

/^>/ {
    seq_count++

    # Print progress bar
    progress = int((seq_count / total_seqs) * 100)
    printf "\rProcessing: %d%% [%-50s]", progress, substr("##################################################", 1, progress / 2)
    fflush()
}

{
    if (seq_count <= 773) { # grep -c "^>" "$1" (input file) --> sequences divided in half
        print >> part1 # part1 defined in bash scrupt
    } else {
        print >> part2 # part2 defined in bash script
    }
}

# Finalize the progress bar
END {
    printf "\rProcessing: 100%% [%-50s]\n", "##################################################"
}