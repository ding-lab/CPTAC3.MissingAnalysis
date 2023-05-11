# docker pull amancevice/pandas:latest
BIN="WUDocker/start_docker.sh"

CATALOG_ROOT="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"

IMAGE="amancevice/pandas:latest"
VOLS="$CATALOG_ROOT ."


bash $BIN -r -M compute1 -I $IMAGE $VOLS
