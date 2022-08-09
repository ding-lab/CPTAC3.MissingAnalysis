#Download to katmai:
# Methylation_Array
# miRNA-Seq             
# RNA-Seq_Fusion        
# RNA-Seq_Transcript    
#
#Download to MGI
# WXS_Germline          
#
#Download to storage1
# RNA-Seq_Expression    
# WGS_CNV               
# WGS_SV                
# WXS_MSI               
# WXS_Somatic_SW        
# WXS_Somatic_TD        

OUTD="Results/downloads"
mkdir -p $OUTD
CATALOGD="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog"

function collect_UUID_requested {
    S=$1    # system
    PIPELINES="$2"
    for P in $PIPELINES; do
        D="Results/compute1-results/results-AML-GBM/${P}.run_list.tsv"
        if [ ! -f $D ]; then
            >&2 echo ERROR: $D does not exist
            exit 1
        fi
        OUTF_TMP="$OUTD/$S.all_UUID_requested.tmp"
        echo Processing $P for $S, reading $D, writing $OUTF_TMP
        cut -f 6,9 $D | grep -v uuid | tr '\t' '\n' | sort -u >> $OUTF_TMP
    done
    OUTF="$OUTD/$S.all_UUID_requested.dat"
    sort -u $OUTF_TMP > $OUTF 
    >&2 echo Final result written to $OUTF
}

# processing Catalog2-style BamMaps, with UUID in column 10
function get_inhouse_UUIDs {
    S=$1

    BM="$CATALOGD/BamMap/$S.BamMap.dat"
    if [ ! -f $BM ]; then
        >&2 echo ERROR: $BM does not exist
        exit 1
    fi
    OUTF="$OUTD/$S.all_UUID_inhouse.dat"

    >&2 echo Getting all UUIDs from $BM, writing to $OUTF
    tail -n +2 $BM | cut -f 10 | sort -u > $OUTF
}

function get_UUIDs_to_download {
    S=$1

    ALL_UUID="$OUTD/$S.all_UUID_inhouse.dat"
    PROCESSABLE_UUID="$OUTD/$S.all_UUID_requested.dat"
    DOWNLOAD_UUID="$OUTD/$S.download_UUID.dat"

    # get the UUIDs which are unique to PROCESSABLE_UUID
    >&2 echo Writing UUIDs to download to $DOWNLOAD_UUID
    comm -13 $ALL_UUID $PROCESSABLE_UUID > $DOWNLOAD_UUID

}

function process_system {
    S=$1    # system
    PIPELINES="$2"

    >&2 echo \*\*\* $S \*\*\*
    collect_UUID_requested $S "$PIPELINES"
    get_inhouse_UUIDs $S
    get_UUIDs_to_download $S

}
    

# Example Catalog2 BamMap: $CATALOGD/BamMap/katmai.BamMap.dat
# Example pipeline processing request file: Results/compute1-results/results-AML-GBM/WGS_SV.run_list.tsv

# for each download system, get all UUIDs from all pipeline processing request for that system
# Then remove from list all UUIDs which already exist on the system

KATMAI_PIPELINES="Methylation_Array miRNA-Seq RNA-Seq_Fusion RNA-Seq_Transcript"
MGI_PIPELINES="WXS_Germline"
STORAGE1_PIPELINES="RNA-Seq_Expression WGS_CNV_Somatic WGS_SV WXS_MSI WXS_Somatic_Variant_SW WXS_Somatic_Variant_TD"

process_system katmai "$KATMAI_PIPELINES"
process_system storage1 "$STORAGE1_PIPELINES"
process_system MGI "$MGI_PIPELINES"

rm -f $OUTD/*.tmp
