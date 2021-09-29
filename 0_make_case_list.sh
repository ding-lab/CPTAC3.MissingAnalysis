# Project-specific script to create list of cases of interest
# In this case, we want rare CCRCC and all GBM and PDA cases
#   these are written to per-disease files
# Also, create a list of diseases we're processing for later use


ALL_CASES="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat"
DISEASES_FN="dat/diseases.dat"
OUTD="dat"
mkdir -p dat

>&2 echo Getting Rare CCRCC cases
grep CCRCC $ALL_CASES | grep Rare | cut -f 1 > $OUTD/CCRCC.dat

>&2 echo Getting all GBM cases
grep GBM $ALL_CASES | cut -f 1 > $OUTD/GBM.dat

>&2 echo Getting all PDA cases
grep PDA $ALL_CASES | cut -f 1 > $OUTD/PDA.dat

cat << EOF > $DISEASES_FN
CCRCC
GBM
PDA
EOF

>&2 echo Written to $DISEASES_FN
