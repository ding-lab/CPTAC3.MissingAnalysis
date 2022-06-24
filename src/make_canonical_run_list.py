# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

import json
import argparse, sys, os, itertools
import pandas as pd

# https://stackoverflow.com/questions/5574702/how-to-print-to-stderr-in-python
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def read_catalog(catalog_fn):
    catalog = pd.read_csv(catalog_fn, sep="\t", keep_default_na=False)
    # at some point, expand metadata into something convenient
    catalog['metadata'] = catalog.apply(lambda row: json.loads(row['metadata']), axis=1)
    return catalog

# There may be more than one datafile in a dataset for composite datasets (e.g. FASTQ R1 and R2)
# Note a mismatch in nomenclature: in Catalog3, each row is called a "dataset" (hence "dataset_name")
#   this corresponds to one file on disk, i.e., a datafile.
#   In run list work, a dataset can consist of multiple datafiles.  An example would be a FASTQ dataset consisting
#   of R1 and R2 datafiles.  Note that the specimen (aliquot) of all files in dataset is the same

# Return a list of datafiles, 
# with datafile a dictionary {'datafile_name', 'aliquot_tag', 'case', 'uuid'}.  

# TODO: simplify arguments
def get_datafile_list(catalog, cases, sample_types=[], alignment=None, experimental_strategy=None, data_format=None, data_variety=None, debug=False):
    case_loc = catalog['case'].isin(cases)
    sample_types_loc = catalog['sample_type'].isin(sample_types)

    cat = catalog.rename(columns={'dataset_name': 'datafile_name'})

    if debug:
        eprint("alignment = " + str(alignment))
        eprint("experimental_strategy = " + str(experimental_strategy))
        eprint("data_format = " + str(data_format))
        eprint("data_variety = " + str(data_variety))

# https://stackoverflow.com/questions/17071871/how-do-i-select-rows-from-a-dataframe-based-on-column-values
    alignment_loc = (cat['alignment'] == alignment) if alignment is not None else True
    experimental_strategy_loc = (cat['experimental_strategy'] == experimental_strategy) if experimental_strategy is not None else True
    data_format_loc = (cat['data_format'] == data_format) if data_format is not None else True
    data_variety_loc = (cat['data_variety'] == data_variety) if data_variety is not None else True
    all_loc = case_loc & sample_types_loc & experimental_strategy_loc & alignment_loc & data_format_loc & data_variety_loc

    # all_loc selects the rows of interest.  Now extract from metadata particular fields to catalog to make processing later easier
    # * aliquot_tag
    cat['aliquot_tag'] = cat['metadata'].apply(lambda j: j['aliquot_tag'])

    return( cat.loc[all_loc, ['datafile_name', 'uuid', 'case', 'aliquot_tag']])

# datafile keys: ['datafile_name', 'aliquot_tag', 'case', 'uuid']
# if no data_varieties or only one specified, return the datafile list as the dataset list
# dataset_list is a list of tuples, [ (dfA1, dfA2), (dfB1, dfB2), ... ] one tuple per aliquot,
# and with multiple datafiles for composite datasets
def get_dataset_list(catalog, cases, sample_types, alignment, experimental_strategy, data_format, data_varieties, debug):

    # if data_varieties is not specified or only one is, the dataset list is just the file_list
    if data_varieties is None or len(data_varieties) == 1:
        file_list = get_datafile_list(catalog, cases, sample_types=sample_types, alignment=alignment, 
                    experimental_strategy=experimental_strategy, data_format=data_format, debug=debug)
        return file_list # make sure this is a list...
        
    # Currently, consider only the case of two data varieties (three data varieties never yet seen; these can be dealt
    # with iteratively though)
    if len(data_varieties) > 2:
        raise ValueError("Only maximum 2 data varieties currently supported")

    # In case of composite datasasets with two data varieties, match datafiles by aliquot.
    # It is an error if any aliquot observed does not have one datafile for each data variety.

    # creating a list of datafiles
    flA = get_datafile_list(catalog, cases, sample_types=sample_types, alignment=alignment, experimental_strategy=experimental_strategy, 
            data_format=data_format, debug=debug, data_variety=data_varieties[0])
    flB = get_datafile_list(catalog, cases, sample_types=sample_types, alignment=alignment, experimental_strategy=experimental_strategy, 
            data_format=data_format, debug=debug, data_variety=data_varieties[1])

    # doing outer join to catch all non-matched aliquots.  https://stackoverflow.com/questions/53645882/pandas-merging-101
    # case should also match
    flM=flA.merge(flB, on=("aliquot_tag", "case"), how='outer', suffixes=("_A","_B"))

    # expect to have fully populated datasets.  Some sort of problem if catalog file does not provide these
    unmatched_A=flM[['uuid_A']].isnull()    
    unmatched_B=flM[['uuid_B']].isnull()

    # Indicate which datafiles are unmatched, complain and quit
    if unmatched_A.values.any() or unmatched_B.values.any():
        eprint("ERROR: The following datafiles did not have dataset mates of varieties %s based on aliquot_tag" % str(data_varieties))
        eprint(flM.loc[unmatched_A.values, ["aliquot_tag", "dataset_name_B", "uuid_B", "case_B"] ].to_string())
        eprint(flM.loc[unmatched_B.values, ["aliquot_tag", "dataset_name_A", "uuid_A", "case_A"] ].to_string())
        raise ValueError("Unmatched datafile")
        
    # options: {‘dict’, ‘list’, ‘series’, ‘split’, ‘records’, ‘index’}
    datafiles = flM.to_dict("records") 
    # this returns a list of dictionaries, e.g., {'datafile_name_A': 'C3N-01200.DUP_6b3a9db.MethArray.Red.T', 'uuid_A': 'b76ec06c-d83c-4147-9651-07b7ac4500ae', 'case': 'C3N-01200', 'aliquot_tag': 'DUP_6b3a9db', 'datafile_name_B': 'C3N-01200.DUP_6b3a9db.MethArray.Green.T', 'uuid_B': 'd258d649-b531-429f-a9aa-407f445dcf13'}
    # want to return (['datafile_name_A', 'aliquot_tag', 'case', 'uuid_A'], ['datafile_name_A', 'aliquot_tag', 'case', 'uuid_A']), (...)

    
    l = lambda d: ([ d['datafile_name_A'], d['aliquot_tag'], d['case'], d['uuid_A'] ],  [ d['datafile_name_B'], d['aliquot_tag'], d['case'], d['uuid_B'] ])
    run_list = list( map(l, datafiles) )

    return run_list
        



# run_name is the case name with aliquot tags appended for any datasets with multiplicity > 1
def get_run_name(case, aliquot1_tag, multiples_ds1, run_suffix = None, aliquot2_tag = None, multiples_ds2 = None):
    # ds columns: ['dataset_name', 'uuid', 'case', 'aliquot_tag']])
    run_name = case
    if run_suffix is not None:
        run_name = run_name + '.' + run_suffix
    if multiples_ds1 > 1:
        run_name = run_name + '.' + aliquot1_tag
    if aliquot2_tag is not None:
        if multiples_ds2 > 1:
            run_name = run_name + '.' + aliquot2_tag
    return run_name
    
# Update: dl1 and dl2 are lists of tuples
# At this point no paired workflows use composite datasets; an example of this situation would be a tumor/normal
#   workflow which requires two datafiles (e.g R1 and R2) per dataset
# as such, it is OK to assume dl1 and dl2 are single-valued tuples 
    
# Run list for paired run has the following columns:
# * run_name
# * run_data - json with fields: case, target pipeline, multiples_ds1, multiples_ds2
#   NOTE: this is not implemmented, and currently this field has value of "case"
# * dataset1_name
# * dataset1_uuid
# * dataset2_name
# * dataset2_uuid
# this works only for one case right now
# example rows of dlm
# ['C3L-00017.WXS.T.hg38', '4e2c5edf-8162-46f2-bb3e-11de6846c0e3', 'C3L-00017', 'PDA', 'ALQ_be7244ce']
def get_paired_run_list(dl1, dl2, pipeline_info):
    multiples_ds1 = dl1.shape[0]
    multiples_ds2 = dl2.shape[0]

    suffix = pipeline_info['run_suffix'] if 'run_suffix' in pipeline_info else None
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
# * run_metadata - json with fields: case, target pipeline, is_paired, multiples_ds1, label1
# * dataset_name
# * dataset_uuid
# It is generated from data_list and has the same number of rows
# pipeline data: dictionary of pipeline-associated variables which are appended to run_metadata
#   * is_paired (if true, run_list has 2 input datasets, otherwise it has one)
#   * target_pipeline - optional
#   * label1 - common name for dataset1, e.g. "tumor" (and label2 would be "normal")

def get_single_run_list(dl, pipeline_info):
#    run_list is catalog.loc[all_loc, ['dataset_name', 'uuid', 'case', 'aliquot_tag']]
    dl = dl.rename(columns={'uuid': 'dataset_uuid'})
    multiples_ds1 = dl.shape[0]
#    suffix = pipeline_info['run_suffix']

    #dl['run_name'] = dl.apply(lambda row: get_run_name(row, multiples_ds1), axis=1 )
    dl['run_name'] = dl.apply(lambda row: get_run_name(row['case'], row['aliquot_tag'], multiples_ds1), axis=1 )

    # run_metadata is not implemented.
    # for now, run_metadata is simply the case name

    # create json string based on run_metadata and pipeline_info information
    #dl['run_metadata'] = dl.apply(lambda row: json.dumps(run_metadata.update(pipeline_info)), axis=1 )
    dl = dl.rename(columns={'case': 'run_metadata'})

    return dl[['run_name', 'run_metadata', 'dataset_name', 'dataset_uuid']].reset_index(drop=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate run list for cases of interest from Catalog3 file for single and paired runs ")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-C", "--catalog", dest="catalog_fn", help="Catalog file name", required=True)
    parser.add_argument("-o", "--output", dest="outfn", default="stdout", help="Output file name.  Appends to file if it exists.  Default writes to stdout")
    parser.add_argument("-a", "--alignment", help="Alignment of datasets, e.g., 'harmonized'")
    parser.add_argument("-e", "--experimental_strategy", help="Experimental strategy of datasets, e.g., 'WGS'")
    parser.add_argument("-f", "--data_format", help="Data format of datasets, e.g., 'BAM'")
    parser.add_argument("-v", "--data_variety", help="Data variety of dataset, e.g., 'genomic'.  Multiple values (e.g. 'R1,R2') imply compound dataset consisting of several datafiles")
    parser.add_argument("-t", "--sample_type", required=True, help="Comma-separated list of sample types for sample1")
    parser.add_argument("-T", "--sample_type2", help="Comma-separated list of sample types for sample2.  Implies paired workflow")
    parser.add_argument("-R", "--run_suffix", help="Additional string to be added to run_name following case name")
    parser.add_argument('cases', nargs='+', help="Cases to be evaluated")

    args = parser.parse_args()

    catalog = read_catalog(args.catalog_fn)

    # Paired workflows read two datasets
    sample_types = args.sample_type.split(',')
    is_paired_workflow = args.sample_type2 is not None
    if is_paired_workflow:
        sample_types2 = args.sample_type2.split(',')
        data_variety2 = args.data_variety2 if args.data_variety2 is not None else args.data_variety

    # composite datasets have 2 or more datafiles (e.g. (R1, R2) or (Red, Green))
    # Data variety with multiple comma-separated values implies composite dataset
    data_varieties=args.data_variety.split(',')

    # pipeline data: dictionary of pipeline-associated variables which are appended to run_data
    #   * is_paired (if true, run_list has 2 input datasets, otherwise it has one)
    #   * target_pipeline - optional
    #   * label1 - common name for dataset1, e.g. "tumor" (and label2 would be "normal")
    pipeline_info = {'is_paired': is_paired_workflow}
    if args.run_suffix:
        pipeline_info.update({'run_suffix': args.run_suffix})

    # it is easier for a pandas newbie to iterate over all cases rather than process the list whole
    # get_dataset_list works OK with a list of cases
    run_list = None
    for case in args.cases:
        dataset_list1 = get_dataset_list(catalog, [case], sample_types, args.alignment, args.experimental_strategy, args.data_format, data_varieties, args.debug)

        if is_paired_workflow:
            dataset_list2 = get_dataset_list(catalog, [case], sample_types2, args.alignment, args.experimental_strategy, args.data_format, data_variety2, args.debug)
            rl = get_paired_run_list(dataset_list1, dataset_list2, pipeline_info)
        else:
            rl = get_single_run_list(dataset_list1, pipeline_info)

        run_list = run_list.append(rl) if run_list is not None else rl


    # Finish early
    assert False
    write_header = True
    if args.outfn == "stdout":
        o = sys.stdout
    else:
        # Check if output file exists.  If it does, append to it
        if os.path.isfile(args.outfn):
            print("Appending run_list to " + args.outfn)
            o = open(args.outfn, "a")
            write_header = False
        else:             
            print("Writing run_list to " + args.outfn)
            o = open(args.outfn, "w")

    run_list.to_csv(o, sep="\t", index=False, header=write_header)

