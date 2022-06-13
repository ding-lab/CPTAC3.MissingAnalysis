#CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/Catalog3/CPTAC3.Catalog3.tsv"
CATALOG="testdata/C3L-0001x.Catalog3.tsv"
PYTHON="/Users/mwyczalk/miniconda3/bin/python3"

# Looking at harmonized WGS tumor for case C3L-00017 for germline pipeline

ARGS=" \
--catalog $CATALOG \
--alignment harmonized \
--sample_type tumor \
--sample_type2 blood_normal \
--label1 tumor \
--label2 normal \
--pipeline 'Somatic v1.2' \
--experimental_strategy WXS
"
OUTFN="dat/paired.run_list-canonical.dat"
mkdir -p dat

CASES="C3L-00016 C3L-00017"
#CASES="C3L-00017"

CMD="$PYTHON ../src/make_canonical_run_list.py $@ -o $OUTFN $ARGS $CASES"
>&2 echo Running: $CMD
eval $CMD


