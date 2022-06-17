
OUTD_DL="dat/downloads"
mkdir -p $OUTD_DL
CATALOG="/Users/mwyczalk/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

function process {
    SYSTEM=$1

    UUID="$OUTD_DL/$SYSTEM.download_UUID.dat"
    CMD="cat dat/*/*/download_UUID.$SYSTEM.dat | sort -u > $UUID  "
    echo Running: $CMD
    eval $CMD
    bash src/summarize_download.sh $UUID $CATALOG

}

process katmai
process MGI
process storage1

