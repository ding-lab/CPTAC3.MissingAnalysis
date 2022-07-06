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


# dataset columns: ['dataset_name', 'uuid', 'case', 'disease', 'aliquot_tag']
def get_dataset_list(catalog, cases, sample_types, alignment, experimental_strategy, data_format, data_variety):
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

    return( catalog.loc[all_loc, ['dataset_name', 'uuid', 'case', 'disease', 'aliquot_tag']])

# run_name is the case name with aliquot tags appended for any datasets with multiplicity > 1
def get_run_name(case, aliquot1_tag, multiples_ds1, aliquot2_tag = None, multiples_ds2 = None):
    # ds columns: ['dataset_name', 'uuid', 'case', 'disease', 'aliquot_tag']])
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
# * dataset1_name
# * dataset1_uuid
# * dataset2_name
# * dataset2_uuid
# this works only for one case right now
# example rows of dlm
# ['C3L-00017.WXS.T.hg38', '4e2c5edf-8162-46f2-bb3e-11de6846c0e3', 'C3L-00017', 'PDA', 'ALQ_be7244ce']
def get_paired_run_list(dl1, dl2, pipeline_data):
    multiples_ds1 = dl1.shape[0]
    multiples_ds2 = dl2.shape[0]

# https://stackoverflow.com/questions/45672342/create-a-dataframe-of-permutations-in-pandas-from-list
    dlm=list(itertools.product(dl1.values.tolist(), dl2.values.tolist()))

    run_list = pd.DataFrame(columns=["run_name", "run_metadata", "dataset1_name", "dataset1_uuid", "dataset2_name", "dataset2_uuid"])
    for d in dlm:
        #run_name = get_run_name(d[0]['case'], d[0]['aliquot_tag'], multiples_ds1, d[1]['aliquot_tag'], multiples_ds2)
        ds1 = d[0]
        ds2 = d[1]

        run_name = get_run_name(ds1[2], ds1[4], multiples_ds1, ds2[4], multiples_ds2)
        # note that run_metadata currently has value of case.  This needs to be updated
        row={"run_name": run_name, "run_metadata": ds1[2], "dataset1_name": ds1[0], "dataset1_uuid": ds1[1], "dataset2_name": ds2[0], "dataset2_uuid":  ds2[1]}

        run_list = run_list.append(row, ignore_index=True)
#    dl['run_name'] = dl.apply(lambda row: get_run_name(row[0]['case'], row[0]['aliquot_tag'], multiples_ds1, row[1]['aliquot_tag'], multiples_ds2), axis=1 )

    return run_list[['run_name', 'run_metadata', 'dataset1_name', 'dataset1_uuid', 'dataset2_name', 'dataset2_uuid']].reset_index(drop=True)


# Run list for single run has the following columns:
# * run_name
# * run_metadata - json with fields: case, disease, target pipeline, is_paired, multiples_ds1, label1
# * dataset_name
# * dataset_uuid
# It is generated from data_list and has the same number of rows
# pipeline data: dictionary of pipeline-associated variables which are appended to run_metadata
#   * is_paired (if true, run_list has 2 input datasets, otherwise it has one)
#   * target_pipeline - optional
#   * label1 - common name for dataset1, e.g. "tumor" (and label2 would be "normal")

# NOTE: currently, run_metadata is not functional
def get_single_run_list(dl, pipeline_data):
#    run_list is catalog.loc[all_loc, ['dataset_name', 'uuid', 'case', 'disease', 'aliquot_tag']]
    dl = dl.rename(columns={'uuid': 'dataset_uuid'})
    multiples_ds1 = dl.shape[0]

    #dl['run_name'] = dl.apply(lambda row: get_run_name(row, multiples_ds1), axis=1 )
    dl['run_name'] = dl.apply(lambda row: get_run_name(row['case'], row['aliquot_tag'], multiples_ds1), axis=1 )

    # run_metadata is not implemented.
    # for now, run_metadata is simply the case name

    # create json string based on run_metadata and pipeline_data information
    #dl['run_metadata'] = dl.apply(lambda row: json.dumps(run_metadata.update(pipeline_data)), axis=1 )
    dl = dl.rename(columns={'case': 'run_metadata'})

    return dl[['run_name', 'run_metadata', 'dataset_name', 'dataset_uuid']].reset_index(drop=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate run list for cases of interest from Catalog3 file for single and paired runs ")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-o", "--output", dest="outfn", default="stdout", help="Output file name.  Default writes to stdout")
    parser.add_argument("-U", "--uuid_fn", help="List of uuids or tab-separated uuid pairs already processed.  Requires a header line")
    parser.add_argument('in_run_list', help="Input run list")

    args = parser.parse_args()

    # get list of uuids1 and optionally uuids2 to exclude
    # TODO: catch this error and handle it gracefully:
    #    pandas.errors.EmptyDataError: No columns to parse from file
    try:
        uuid_df = pd.read_csv(args.uuid_fn, sep="\t").drop_duplicates()
    except pd.errors.EmptyDataError:
        eprint("ERROR: " + args.uuid_fn + " is empty")
        sys.exit(1)
#
    if len(uuid_df.columns) == 1:
        is_paired = False
        uuids = uuid_df.iloc[:,0].tolist()
    elif len(uuid_df.columns) == 2:
        is_paired = True
        uuids = []
        for index, row in uuid_df.iterrows():
            uuids.append( (row[0], row[1]))
    else:
        raise ValueError('Unexpedted number of columns in '+ uuid_fn)

    # get run_list object
    run_list = pd.read_csv(args.in_run_list, sep="\t")
    new_run_list = pd.DataFrame(columns=run_list.columns)

    for index, row in run_list.iterrows():
        retain=True
        if not is_paired:
            if row.iloc[3] in uuids:
                retain=False
        else:
            if (row.iloc[3], row.iloc[5]) in uuids:
                retain=False

        if args.debug:
            if retain:
                eprint("\nRETAIN : \n" + str(row))
            else:
                eprint("\nEXCLUDE: \n" + str(row))
        if retain:
            #new_run_list = new_run_list.append(row)
            new_run_run_list = pd.concat([new_run_list, pd.DataFrame.from_records([row])], ignore_index=True)

    if args.outfn == "stdout":
        o = sys.stdout
    else:
        eprint("Writing catalog to " + args.outfn)
        o = open(args.outfn, "w")

    new_run_list.to_csv(o, sep="\t", index=False)

