# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

# TODO: Performance improvements.  Don't loop over list and add cases.  Rather, make a dictionary of case data
# and then join it all at once.

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
# with datafile a dictionary {'datafile_name', 'aliquot_tag', 'case', 'uuid', 'specimen_name'}.  

# TODO: simplify arguments
def get_datafile_list(catalog, cases, sample_types=[], alignment=None, experimental_strategy=None, data_format=None, data_variety=None, debug=False):
    case_loc = catalog['case'].isin(cases)
    sample_types_loc = catalog['sample_type'].isin(sample_types)

    cat = catalog.rename(columns={'dataset_name': 'datafile_name'})

# https://stackoverflow.com/questions/17071871/how-do-i-select-rows-from-a-dataframe-based-on-column-values
    alignment_loc = (cat['alignment'] == alignment) if alignment is not None else True
    experimental_strategy_loc = (cat['experimental_strategy'] == experimental_strategy) if experimental_strategy is not None else True
    data_format_loc = (cat['data_format'] == data_format) if data_format is not None else True

    data_variety_loc = (cat['data_variety'].str.contains(data_variety)) if data_variety is not None else True
    all_loc = case_loc & sample_types_loc & experimental_strategy_loc & alignment_loc & data_format_loc & data_variety_loc

    # all_loc selects the rows of interest.  Now extract from metadata particular fields to catalog to make processing later easier
    # * aliquot_tag
    cat['aliquot_tag'] = cat['metadata'].apply(lambda j: j['aliquot_tag'])

    return( cat.loc[all_loc, ['datafile_name', 'uuid', 'case', 'aliquot_tag', 'specimen_name']])

def get_simple_dataset_list(catalog, cases, sample_types, alignment, experimental_strategy, data_format, data_varieties, debug):
# if data_varieties is not specified or only one is, the dataset list is just the file_list
    data_variety = data_varieties[0] if data_varieties is not None else None
    file_list = get_datafile_list(catalog, cases, sample_types=sample_types, alignment=alignment, data_variety=data_variety,
                experimental_strategy=experimental_strategy, data_format=data_format, debug=debug)
    return file_list 

# datafile keys: ['datafile_name', 'aliquot_tag', 'case', 'uuid', 'specimen_name']
# if no data_varieties or only one specified, return the datafile list as the dataset list
# dataset_list is a list of tuples, [ (dfA1, dfA2), (dfB1, dfB2), ... ] one tuple per aliquot,
# and with multiple datafiles for composite datasets
def get_compound_dataset_list(catalog, cases, sample_types, alignment, experimental_strategy, data_format, data_varieties, debug):
    # Currently, consider only the case of two data varieties (three data varieties never yet seen; these can be dealt
    # with iteratively though)
    if len(data_varieties) != 2:
        raise ValueError("Only 2 data varieties currently supported")

    # In case of composite datasasets with two data varieties, match datafiles by aliquot.
    # It is an error if any aliquot observed does not have one datafile for each data variety.

    # creating a list of datafiles
    flA = get_datafile_list(catalog, cases, sample_types=sample_types, alignment=alignment, experimental_strategy=experimental_strategy, 
            data_format=data_format, debug=debug, data_variety=data_varieties[0])
    flB = get_datafile_list(catalog, cases, sample_types=sample_types, alignment=alignment, experimental_strategy=experimental_strategy, 
            data_format=data_format, debug=debug, data_variety=data_varieties[1])

    # doing outer join to catch all non-matched aliquots.  https://stackoverflow.com/questions/53645882/pandas-merging-101
    # case should also match
    flM=flA.merge(flB, on=("specimen_name", "aliquot_tag", "case"), how='outer', suffixes=("_A","_B"))

    # expect to have fully populated datasets.  Some sort of problem if catalog file does not provide these
    unmatched_A=flM[['uuid_A']].isnull()    
    unmatched_B=flM[['uuid_B']].isnull()

    # Indicate which datafiles are unmatched, complain and quit
    if unmatched_A.values.any() or unmatched_B.values.any():
        eprint("ERROR: The following datafiles did not have dataset mates of varieties %s based on aliquot_tag" % str(data_varieties))
        eprint(flM.loc[unmatched_A.values, ["aliquot_tag", "datafile_name_B", "uuid_B", "case_B"] ].to_string())
        eprint(flM.loc[unmatched_B.values, ["aliquot_tag", "datafile_name_A", "uuid_A", "case_A"] ].to_string())
        raise ValueError("Unmatched datafile")
        
    datafiles = flM.to_dict("records") 
    l = lambda d: ([ d['datafile_name_A'], d['uuid_A'], d['case'], d['aliquot_tag'], d['specimen_name'] ],  
                   [ d['datafile_name_B'], d['uuid_B'], d['case'], d['aliquot_tag'], d['specimen_name'] ])
    run_list = list( map(l, datafiles) )

    return run_list

# run_name is the case name with aliquot tags appended for any datasets with multiplicity > 1
def get_run_name(case, aliquot1_tag, multiples_ds1, suffix = None, aliquot2_tag = None, multiples_ds2 = None):
    # ds columns: ['dataset_name', 'uuid', 'case', 'aliquot_tag', 'specimen_name']])
    run_name = case
    if suffix is not None:
        run_name = run_name + '.' + suffix
    if multiples_ds1 > 1:
        run_name = run_name + '.' + aliquot1_tag
    if aliquot2_tag is not None:
        if multiples_ds2 > 1:
            run_name = run_name + '.' + aliquot2_tag
    return run_name
    
# dl1, dl2 are a list of datasets, and datasets are tuples of datafiles.
# Currently no paired workflows use composite datasets, so assume dl1 and dl2 are single-valued tuples, but this could
# be extended for the situation of e.g. a tumor/normal workflow with compound datasets (e.g. R1 and R2)

# Here, multiple datasets in ds1 and ds2 result in all-against-all pairing in run set.
# for instance, if ds1 consists of datasets T1,T2,T3 and ds2 of N1 and N2, run set would incorporate ( (T1, N1), (T1, N2), (T2, N1), (T2, N2), (T3, N1), (T3, N2) )
    
def get_paired_runset(ds1, ds2):
# https://stackoverflow.com/questions/45672342/create-a-dataframe-of-permutations-in-pandas-from-list
    rs=list(itertools.product(ds1.values.tolist(), ds2.values.tolist()))
    return rs

# Two column run list has the following columns:
# * run_name
# * case - will be json with fields: case, target pipeline, multiples_ds1, multiples_ds2
#       NOTE: this is not implemmented, and currently this field has value of "case"
# * datafile1_name
# * [datafile1_aliquot]
# * datafile1_uuid
# * datafile2_name
# * [datafile2_aliquot]
# * datafile2_uuid

# this works only for one case at a time right now
# n1, n2 is multiples_ds1, multiples_ds2
def get_two_column_run_list(rs, pipeline_info, n1, n2, suffix=None, write_aliquot=False):
    if write_aliquot:
        header_list=['run_name', 'run_metadata', 'datafile1_name', "datafile1_aliquot", 'datafile1_uuid', 'datafile2_name', "datafile2_aliquot", 'datafile2_uuid']
    else:
        header_list=['run_name', 'run_metadata', 'datafile1_name', 'datafile1_uuid', 'datafile2_name', 'datafile2_uuid']
    run_list = pd.DataFrame(columns=header_list)
    for r in rs:
        # Note that get_one_column version does not iterate over rs, and this probably doesn't ahve to either
        rs1 = r[0]  # columns: name, uuid, case, aliquot_tag, aliquot.  Really should be a dictionary
        rs2 = r[1]

#        n1 = pipeline_info['multiples_ds1'] if 'multiples_ds1' in pipeline_info.keys() else 1
#        n2 = pipeline_info['multiples_ds2'] if 'multiples_ds2' in pipeline_info.keys() else 1

        run_name = get_run_name(rs1[2], rs1[3], n1, suffix = suffix, aliquot2_tag = rs2[3], multiples_ds2 = n2)
        # note that run_metadata currently has value of case.  This needs to be updated
        if write_aliquot:
            row={"run_name": run_name, "run_metadata": rs1[2], "datafile1_name": rs1[0], "datafile1_aliquot": rs1[4], "datafile1_uuid": rs1[1], 
                "datafile2_name": rs2[0], "datafile2_aliquot": rs2[4], "datafile2_uuid":  rs2[1]}
        else:
            row={"run_name": run_name, "run_metadata": rs1[2], "datafile1_name": rs1[0], "datafile1_uuid": rs1[1], "datafile2_name": rs2[0], "datafile2_uuid":  rs2[1]}

        # run_list = run_list.append(row, ignore_index=True)
        run_list = pd.concat([run_list, pd.DataFrame.from_records([row])], ignore_index=True)

    return run_list[header_list].reset_index(drop=True)

# Run list for single run has the following columns:
# * run_name
# * case    (may be metadata in future) (target pipeline, is_paired, multiples_ds1, label1 currently not implemented)
# * datafile_name
# * [datafile_aliquot]
# * datafile_uuid

# It is generated from data_list and has the same number of rows
# pipeline data: dictionary of pipeline-associated variables which are appended to run_metadata
#   * is_paired (if true, run_list has 2 input datasets, otherwise it has one)
#   * target_pipeline - optional
#   * label1 - common name for dataset1, e.g. "tumor" (and label2 would be "normal")

def get_single_column_run_list(rs, pipeline_info, n1, suffix=None, write_aliquot=False):
#    run_list is catalog.loc[all_loc, ['dataset_name', 'uuid', 'case', 'aliquot_tag', 'specimen_name']]
    rs = rs.rename(columns={'uuid': 'datafile_uuid'})
#    n1 = pipeline_info['multiples_ds1'] if 'multiples_ds1' in pipeline_info.keys() else 1

    rs['run_name'] = rs.apply(lambda row: get_run_name(row['case'], row['aliquot_tag'], n1, suffix=suffix), axis=1 )

    # run_metadata is not implemented.
    # for now, run_metadata is simply the case name
    # TODO: create json string based on run_metadata and pipeline_info information
#    rs['run_metadata'] = rs.apply(lambda row: json.dumps(...), axis=1 )
    rs = rs.rename(columns={'case': 'run_metadata', 'specimen_name': 'datafile_aliquot'})

    if write_aliquot:
        header_list = ['run_name', 'run_metadata', 'datafile_name', 'datafile_aliquot', 'datafile_uuid']
    else:
        header_list = ['run_name', 'run_metadata', 'datafile_name', 'datafile_uuid']
    return rs[header_list].reset_index(drop=True)

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
    parser.add_argument("-s", "--suffix", help="Additional string to be added to run_name following case name")
    parser.add_argument("-q", "--aliquot", action="store_true", help="Add specimen_name field (often named aliquot) to output run_list")
    parser.add_argument('cases', nargs='+', help="Cases to be evaluated")

    args = parser.parse_args()

    catalog = read_catalog(args.catalog_fn)

    # There are three types of workflows we consider:
    # * unpaired with simple dataset  (one datafile in run list)
    # * paired with simple dataset    (two datafiles in run list)
    # * unpaired with compound dataset (two datafiles in run list)
    # where a simple dataset has one datafile and a compound dataset has two datafiles (e.g. R1 and R2)
    # The second two cases are important to distinguish:
    #  * compound datasets have multiple data varieties (e.g. "-v R1,R2")
    #  * paired workflows have two sample types defined (e.g. "-t tumor -T tissue_normal")


    # Paired workflows read two datasets
    sample_types = args.sample_type.split(',')
    is_paired_workflow = args.sample_type2 is not None
    if is_paired_workflow:
        sample_types2 = args.sample_type2.split(',')

    # composite datasets have 2 or more datafiles (e.g. (R1, R2) or (Red, Green))
    # Data variety with multiple comma-separated values implies composite dataset
    compound_dataset=False
    data_varieties = args.data_variety.split(',') if args.data_variety is not None else None
    if data_varieties is not None and len(data_varieties) > 1:
        compound_dataset=True
#        pipeline_info.update({'compound_dataset': len(data_varieties)})

    # pipeline data: dictionary of pipeline-associated variables which are appended to run_data
    #   * is_paired (if true, run_list has 2 input datasets, otherwise it has one)
    pipeline_info = {'is_paired': is_paired_workflow}
    if args.suffix:
        pipeline_info.update({'suffix': args.suffix})

    # it is easier for a pandas newbie to iterate over all cases rather than process the list whole
    # get_dataset_list works OK with a list of cases
    run_list = []   # this will be a list of dataframes
    for case in args.cases:
        if args.debug:
            eprint("Processing " + case)

        if not compound_dataset:
            dataset_list1 = get_simple_dataset_list(catalog, [case], sample_types, args.alignment, args.experimental_strategy, args.data_format, data_varieties, args.debug)
        else:
            dataset_list1 = get_compound_dataset_list(catalog, [case], sample_types, args.alignment, args.experimental_strategy, args.data_format, data_varieties, args.debug)
        if args.debug:
            eprint("dataset_list1")
            eprint(dataset_list1)
        multiples_ds1 = len(dataset_list1)
#        if len(dataset_list1) > 1:
#            pipeline_info.update({'multiples_ds1': len(dataset_list1)})  # for instance, multiple tumor samples
#        elif len(dataset_list1) == 0:

        if multiples_ds1 == 0:
            if args.debug:
                eprint("dataset_list1 is empty")
            continue

        if is_paired_workflow:
            if compound_dataset:
                raise ValueError("Compound datasets with paired workflows unsupported")
            dataset_list2 = get_simple_dataset_list(catalog, [case], sample_types2, args.alignment, args.experimental_strategy, args.data_format, data_varieties, args.debug)
            if (args.debug):
                eprint("dataset_list2")
                eprint(dataset_list2)
            runset_list = get_paired_runset(dataset_list1, dataset_list2)

            multiples_ds2 = len(dataset_list2)
            if multiples_ds2 == 0:
                if args.debug:
                    eprint("dataset_list2 is empty")
                continue
#            if (len(dataset_list2) > 1):
#                pipeline_info.update({'multiples_ds2': len(dataset_list2)})  # for instance, multiple tumor samples

            two_column_runlist = True
        else:
            runset_list = dataset_list1
            multiples_ds2 = 1   # there is no ds2
            if compound_dataset:
                two_column_runlist = True
            else:
                two_column_runlist = False
        if (args.debug):
            eprint("runset_list")
            eprint(runset_list)

        if two_column_runlist:
            rl = get_two_column_run_list(runset_list, pipeline_info, multiples_ds1, multiples_ds2, suffix=args.suffix, write_aliquot=args.aliquot)
        else:
            rl = get_single_column_run_list(runset_list, pipeline_info, multiples_ds1, suffix=args.suffix, write_aliquot=args.aliquot)

        run_list.append(rl) 

    if run_list:    # run_list is not empty
        run_list_df = pd.concat(run_list, ignore_index=True)
    else:
        run_list_df = pd.DataFrame()

    if (args.debug):
        eprint("run_list_df")
        eprint(run_list_df.to_string())

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

    run_list_df.to_csv(o, sep="\t", index=False, header=write_header)

