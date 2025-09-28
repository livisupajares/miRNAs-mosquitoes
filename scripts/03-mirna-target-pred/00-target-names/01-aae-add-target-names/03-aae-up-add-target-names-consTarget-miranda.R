# ~~~~~ ADD TARGET NAMES ~~~~~ #
# This script adds target names to the Aedes aegypti miRNA target prediction
# results from the miRanda algorithm (targets from down-regultared miRNAs during DENV-2 infection that can be found in common with up-regulated Aedes albopictus miRNAs)
# This script also filters the results to find the best mRNA target candidates
# according to a specific criteria (highest score, lowest energy (-20 kcal/mol
# cutoff)

# NOTE: We were supposed to merge VectorBase info into predicted targets by
# transcript id, but for some reason it fails to merge using the same command as
# in Aedes albopictus. So we will use the biomart info instead.

