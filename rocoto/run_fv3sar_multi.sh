#!/bin/bash -l
set +x
. /usrx/local/prod/lmod/lmod/init/sh
set -x

module load impi/18.0.1
module load lsf/10.1

module use /gpfs/dell3/usrx/local/dev/emc_rocoto/modulefiles/
module load ruby/2.5.1 rocoto/1.2.4

doms="hi pr"


dir="/gpfs/dell2/emc/modeling/noscrub/${USER}/fv3sar_workflow_mybranch/rocoto"

for dom in $doms
do
rocotorun -v 10 -w ${dir}/drive_fv3sar_${dom}.xml -d ${dir}/drive_fv3sar_${dom}.db
sleep 60
done
