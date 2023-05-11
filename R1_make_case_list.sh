# Project-specific script to create list of cases of interest
# In this case, all AML cases
#   these are written to per-disease files
# Also, create a list of diseases we're processing for later use

CATALOG_ROOT="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3"

ALL_CASES="$CATALOG_ROOT/DLBCL.Cases.tsv"
DISEASES_FN="dat/diseases.dat"
OUTD="dat/cases"
mkdir -p $OUTD

function process {
    DIS=$1

    OUT="$OUTD/$DIS-cases.dat"
    >&2 echo Getting all $DIS, writing to $OUT
    grep $DIS $ALL_CASES | cut -f 1 > $OUT
}

cat << EOF > $DISEASES_FN
DLBCL
EOF

if [ ! -f $ALL_CASES ]; then
    >&2 echo ERROR: $ALL_CASES not found
    exit 1
fi

>&2 echo Written to $DISEASES_FN

while read DIS; do
    >&2 echo Processing $DIS
    process $DIS
done <$DISEASES_FN

