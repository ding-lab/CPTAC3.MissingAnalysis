# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

import argparse, sys, os, itertools
import pandas as pd

# https://stackoverflow.com/questions/5574702/how-to-print-to-stderr-in-python
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def read_catalog(catalog_fn):
    catalog = pd.read_csv(catalog_fn, sep="\t")
    # at some point, expand metadata into something convenient
    catalog['metadata'] = catalog.apply(lambda row: json.loads(row['metadata']), axis=1)
    return catalog

# datafile columns: ['datafile_name', 'uuid', 'case', 'disease', 'aliquot_tag']
def get_datafile_list(catalog, cases, sample_types, alignment, experimental_strategy, data_format, data_variety):
    case_loc = catalog['case'].isin(cases)
    sample_types_loc = catalog['sample_type'].isin(sample_types)

#    eprint("alignment = " + str(alignment))
#    eprint("experimental_strategy = " + str(experimental_strategy))
#    eprint("data_format = " + str(data_format))
#    eprint("data_variety = " + str(data_variety))

# https://stackoverflow.com/questions/17071871/how-do-i-select-rows-from-a-dataframe-based-on-column-values
    alignment_loc = (catalog['alignment'] == alignment) if alignment is not None else True
    experimental_strategy_loc = (catalog['experimental_strategy'] == experimental_strategy) if experimental_strategy is not None else True
    data_format_loc = (catalog['data_format'] == data_format) if data_format is not None else True
    data_variety_loc = (catalog['data_variety'] == data_variety) if data_variety is not None else True
    all_loc = case_loc & sample_types_loc & experimental_strategy_loc & alignment_loc & data_format_loc & data_variety_loc

    # all_loc selects the rows of interest.  Now extract from metadata particular fields to catalog to make processing later easier
    # * aliquot_tag
    catalog['aliquot_tag'] = catalog['metadata'].apply(lambda j: j['aliquot_tag'])

    return( catalog.loc[all_loc, ['datafile_name', 'uuid', 'case', 'disease', 'aliquot_tag']])

# run_name is the case name with aliquot tags appended for any datafiles with multiplicity > 1
def get_run_name(case, aliquot1_tag, multiples_ds1, aliquot2_tag = None, multiples_ds2 = None):
    # ds columns: ['datafile_name', 'uuid', 'case', 'disease', 'aliquot_tag']])
    run_name = case
    if multiples_ds1 > 1:
        run_name = run_name + '.' + aliquot1_tag
    if aliquot2_tag is not None:
        if multiples_ds2 > 1:
            run_name = run_name + '.' + aliquot2_tag
    return run_name
    
    
# Run list for paired run has the following columns:
# * run_name
# * run_data - json with fields: case, disease, target pipeline, multiples_ds1, multiples_ds2
#   NOTE: this is not implemmented, and currently this field has value of "case"
# * datafile1_name
# * datafile1_uuid
# * datafile2_name
# * datafile2_uuid
# this works only for one case right now
# example rows of dlm
# ['C3L-00017.WXS.T.hg38', '4e2c5edf-8162-46f2-bb3e-11de6846c0e3', 'C3L-00017', 'PDA', 'ALQ_be7244ce']
def get_paired_run_list(dl1, dl2, pipeline_data):
    multiples_ds1 = dl1.shape[0]
    multiples_ds2 = dl2.shape[0]

# https://stackoverflow.com/questions/45672342/create-a-dataframe-of-permutations-in-pandas-from-list
    dlm=list(itertools.product(dl1.values.tolist(), dl2.values.tolist()))

    run_list = pd.DataFrame(columns=["run_name", "run_metadata", "datafile1_name", "datafile1_uuid", "datafile2_name", "datafile2_uuid"])
    for d in dlm:
        #run_name = get_run_name(d[0]['case'], d[0]['aliquot_tag'], multiples_ds1, d[1]['aliquot_tag'], multiples_ds2)
        ds1 = d[0]
        ds2 = d[1]

        run_name = get_run_name(ds1[2], ds1[4], multiples_ds1, ds2[4], multiples_ds2)
        # note that run_metadata currently has value of case.  This needs to be updated
        row={"run_name": run_name, "run_metadata": ds1[2], "datafile1_name": ds1[0], "datafile1_uuid": ds1[1], "datafile2_name": ds2[0], "datafile2_uuid":  ds2[1]}

        run_list = run_list.append(row, ignore_index=True)
#    dl['run_name'] = dl.apply(lambda row: get_run_name(row[0]['case'], row[0]['aliquot_tag'], multiples_ds1, row[1]['aliquot_tag'], multiples_ds2), axis=1 )

    return run_list[['run_name', 'run_metadata', 'datafile1_name', 'datafile1_uuid', 'datafile2_name', 'datafile2_uuid']].reset_index(drop=True)


# Run list for single run has the following columns:
# * run_name
# * run_metadata - json with fields: case, disease, target pipeline, is_paired, multiples_ds1, label1
# * datafile_name
# * datafile_uuid
# It is generated from data_list and has the same number of rows
# pipeline data: dictionary of pipeline-associated variables which are appended to run_metadata
#   * is_paired (if true, run_list has 2 input datafiles, otherwise it has one)
#   * target_pipeline - optional
#   * label1 - common name for datafile1, e.g. "tumor" (and label2 would be "normal")

# NOTE: currently, run_metadata is not functional
def get_single_run_list(dl, pipeline_data):
#    run_list is catalog.loc[all_loc, ['datafile_name', 'uuid', 'case', 'disease', 'aliquot_tag']]
    dl = dl.rename(columns={'uuid': 'datafile_uuid'})
    multiples_ds1 = dl.shape[0]

    #dl['run_name'] = dl.apply(lambda row: get_run_name(row, multiples_ds1), axis=1 )
    dl['run_name'] = dl.apply(lambda row: get_run_name(row['case'], row['aliquot_tag'], multiples_ds1), axis=1 )

    # run_metadata is not implemented.
    # for now, run_metadata is simply the case name

    # create json string based on run_metadata and pipeline_data information
    #dl['run_metadata'] = dl.apply(lambda row: json.dumps(run_metadata.update(pipeline_data)), axis=1 )
    dl = dl.rename(columns={'case': 'run_metadata'})

    return dl[['run_name', 'run_metadata', 'datafile_name', 'datafile_uuid']].reset_index(drop=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate run list for cases of interest from Catalog3 file for single and paired runs ")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-o", "--output", dest="outfn", default="stdout", help="Output file name.  Default writes to stdout")
    parser.add_argument("-X", "--exclude_fn", help="List of datafiles or datafile pairs (TSV) to exclude. May list aliquots or UUIDs. Headers like ['datafile_uuid'] or ['datafile1_aliquot', 'datafile2_aliquot'] required")
    parser.add_argument('runlist_fn', help="Input run list")

    args = parser.parse_args()
    # run list columns:
    # * run_name
    # * case   (in future, may be metadata)
    # If one datafile,   (is_paired_runlist = false)
        # * datafile_name
        # * datafile_aliquot - this is optional. (has_aliquot_runlist = True)
        # * datafile_uuid
    # If two datafiles,  (is_paired_runlist = true)
        # * datafile1_name
        # * datafile1_aliquot - this is optional
        # * datafile1_uuid
        # * datafile2_name
        # * datafile2_aliquot - present iff datafile1_aliquot present
        # * datafile2_uuid

    # exclude_list columns
    # * ["datafile_uuid"]
    #   * is_paired_exclude = False, has_aliquot_exclude = False
    # * ["datafile1_uuid", "datafile2_uuid"]
    #   * is_paired_exclude = True, has_aliquot_exclude = False
    # * ["datafile_aliquot"]
    #   * is_paired_exclude = False, has_aliquot_exclude = True
    # * ["datafile1_aliquot", "datafile2_aliquot"]
    #   * is_paired_exclude = True, has_aliquot_exclude = True

    try:
        exclude_df = pd.read_csv(args.exclude_fn, sep="\t").drop_duplicates()
        exclude_cols = list(exclude_df.columns.values)
    except pd.errors.EmptyDataError:
        raise ValueError("ERROR: " + args.exclude_fn + " is empty")

    if args.debug:
        print("DEBUG: exclude_cols: " + str(exclude_cols))

    if 'datafile_uuid' in exclude_cols:
        is_paired_exclude = False
        has_aliquot_exclude = False
    elif 'datafile_aliquot' in exclude_cols:
        is_paired_exclude = False
        has_aliquot_exclude = True
    # https://stackoverflow.com/questions/6159313/how-to-test-the-membership-of-multiple-values-in-a-list
    #elif all( c in ['datafile1_uuid', 'datafile2_uuid'] for c in exclude_cols):
    elif all( c in exclude_cols for c in ['datafile1_uuid', 'datafile2_uuid']):
        is_paired_exclude = True
        has_aliquot_exclude = False
    elif all( c in exclude_cols for c in ['datafile1_aliquot', 'datafile2_aliquot']):
        is_paired_exclude = True
        has_aliquot_exclude = True
    else:
        raise ValueError("ERROR: Unexpected columns in " + args.exclude_fn + ":\n"+str(exclude_cols))

    # now read in run list
    try:
        run_list = pd.read_csv(args.runlist_fn, sep="\t")
        runlist_cols = list(run_list.columns.values)
    except pd.errors.EmptyDataError:
        raise ValueError("ERROR: " + args.runlist_fn + " is empty")
    if 'datafile_name' in runlist_cols:
        is_paired_runlist = False
        has_aliquot_runlist = False
    #elif all (c in ['datafile1_name', 'datafile2_name'] for c in runlist_cols):
    elif all (c in runlist_cols for c in ['datafile1_uuid', 'datafile2_uuid']):
        is_paired_runlist = True
        has_aliquot_runlist = False
    if 'datafile_aliquot' in runlist_cols:
        is_paired_runlist = False
        has_aliquot_runlist = True
    #elif all (c in ['datafile1_aliquot', 'datafile2_aliquot'] for c in runlist_cols):
    elif all (c in runlist_cols for c in ['datafile1_aliquot', 'datafile2_aliquot']):
        is_paired_runlist = True
        has_aliquot_runlist = True
    else:
        raise ValueError("ERROR: Unexpected columns in " + args.runlist_fn + ":\n"+str(runlist_cols))

    if args.debug:
        print("DEBUG: is_paired_exclude = " + str(is_paired_exclude) + ", has_aliquot_exclude = " + str(has_aliquot_exclude))
        print("DEBUG: is_paired_runlist = " + str(is_paired_runlist) + ", has_aliquot_runlist = " + str(has_aliquot_runlist))
        

    # Sanity checks:
    # * if has_aliquot_exclude, require that has_aliquot_runlist
    # * error if is_paired_exclude but run list is not paired
    if has_aliquot_exclude and not has_aliquot_runlist:
        raise ValueError("ERROR: aliquots listed in " + args.exclude_fn + " but not in " + args.runlist_fn)
    if is_paired_exclude and not is_paired_runlist:
        raise ValueError("ERROR: Exclude file " + args.exclude_fn + " is paired but " + args.runlist_fn + " is not paired")
    
    # https://stackoverflow.com/questions/9758450/pandas-convert-dataframe-to-array-of-tuples
    # there has to be a nicer way to do this...
    if has_aliquot_exclude:     
        if not is_paired_exclude:
            exclude_list = list(exclude_df['datafile_aliquot'].values)
        else:
            exclude_list = list(exclude_df[['datafile1_aliquot', 'datafile2_aliquot']].itertuples(index=False, name=None))
    else:
        if not is_paired_exclude:
            exclude_list = list(exclude_df['datafile_uuid'].values)
        else:
            exclude_list = list(exclude_df[['datafile1_uuid', 'datafile2_uuid']].itertuples(index=False, name=None))

    new_run_list = pd.DataFrame(columns=runlist_cols)

    # Loop through list of runs and identify those to retain
    for index, run in run_list.iterrows():
        retain=True

        # ds is either string or tuple (is_paired_runlist), is the relevant run identifiers to match to exclude list
        if has_aliquot_exclude:     # if exclude list has aliquots, we compare runlist aliquots
            if not is_paired_runlist:
                ds = run['datafile_aliquot']
            else:
                ds = (run['datafile1_aliquot'], run['datafile2_aliquot'])
        else:
            if not is_paired_runlist:
                ds = run['datafile_uuid']
            else:
                ds = (run['datafile1_uuid'], run['datafile2_uuid'])
            
        # Generally, reject a run if ID matches something in exclude_list
        # The exception is if run list is paired and exclude list is not, in which case
        #   exclude run if any of its IDs match 
        if is_paired_runlist and not is_paired_exclude:
            if ds[0] in exclude_list or ds[1] in exclude_list:
                retain=False
        else:
            if ds in exclude_list:
                retain=False

        if args.debug:
            if retain:
                eprint("\nRETAIN : \n" + str(run))
            else:
                eprint("\nEXCLUDE: \n" + str(run))
        if retain:
            #new_run_list = new_run_list.append(run)
            new_run_list = pd.concat([new_run_list, pd.DataFrame.from_records([run])], ignore_index=True)

    if args.outfn == "stdout":
        o = sys.stdout
    else:
        eprint("Writing catalog to " + args.outfn)
        o = open(args.outfn, "w")

    new_run_list.to_csv(o, sep="\t", index=False)

