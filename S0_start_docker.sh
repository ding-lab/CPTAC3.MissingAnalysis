# docker pull amancevice/pandas:latest
BIN="WUDocker/start_docker.sh"

CATALOG_ROOT="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"

IMAGE="amancevice/pandas:latest"
VOLS="$CATALOG_ROOT"


bash $BIN -r -M compute1 -I $IMAGE $VOLS
