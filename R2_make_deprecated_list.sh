# Make list of aliquots and UUIDs which are to be excluded from analyses because they have 
# been marked as deprecated in CPTAC3-specific datasets

# Work associated with the above list is typically on Shiso and can be obtained by looking at 
# git history of the above file.

# Write two files, deprecated_aliquot.dat and deprecated_uuid.dat

CATALOG_ROOT="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog"
DAT="$CATALOG_ROOT/SampleRename.dat"
OUTD="dat"
mkdir -p $OUTD
OUT_UUID="$OUTD/deprecated_uuid.dat"
OUT_ALQ="$OUTD/deprecated_aliquot.dat"

# Assume aliquot names like CPT0116860009 (starting with CPT)
# UUID names like 3d100197-9e71-45bd-962a-b12bef470313
echo "datafile_aliquot" > $OUT_ALQ
grep "\.deprecated" $DAT | cut -f 1 | grep "^CPT" | sort -u >> $OUT_ALQ

echo "datafile_uuid" > $OUT_UUID
grep "\.deprecated" $DAT | cut -f 1 | grep -v "^CPT" | sort -u >> $OUT_UUID

>&2 echo Written to $OUT_UUID and $OUT_ALQ
