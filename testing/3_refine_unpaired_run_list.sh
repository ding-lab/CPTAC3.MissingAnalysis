#CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/Catalog3/CPTAC3.Catalog3.tsv"
#CATALOG="testdata/C3L-0001x.Catalog3.tsv"
PYTHON="/Users/mwyczalk/miniconda3/bin/python3"

# Fake DCC_analysis_summary data
DCC_AS="testdata/unpaired.DCC_analysis_summary.dat"

RUN_LIST="dat/unpaired.run_list-canonical.dat"
OUTFN="dat/unpaired.run_list-request.dat"

#    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
#    parser.add_argument("-o", "--output", dest="outfn", default="stdout", help="Output file name.  Default writes to stdout")
#    parser.add_argument("-U", "--uuid_fn", help="List of uuids or tab-separated uuid pairs already processed")
#    parser.add_argument('in_run_list', help="Input run list")

CMD="$PYTHON ../src/refine_run_list.py $@ -U <(cut -f 12 $DCC_AS) -o $OUTFN $RUN_LIST "
>&2 echo Running: $CMD
eval $CMD


