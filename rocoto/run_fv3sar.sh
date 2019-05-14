#!/bin/bash -l
set +x
. /usrx/local/prod/lmod/lmod/init/sh
set -x

module load impi/18.0.1
module load lsf/10.1

module use /gpfs/dell3/usrx/local/dev/emc_rocoto/modulefiles/
module load ruby/2.5.1 rocoto/1.2.4

rocotorun -v 10 -w /gpfs/dell2/emc/modeling/noscrub/${USER}/fv3cam_workflow/rocoto/drive_fv3sar.xml -d /gpfs/dell2/emc/modeling/noscrub/${USER}/fv3cam_workflow/rocoto/drive_fv3sar.db
