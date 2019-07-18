#! /bin/sh --login
set -x -u -e
date
. ${HOMEfv3}/rocoto/machine-setup.sh
export MACHINE=${target}
exec "$@"
