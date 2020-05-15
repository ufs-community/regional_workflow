#!/bin/sh -l
set -x
module load rocoto/1.3.1
export HOMEfv3=/work/noaa/fv3-cam/jaravequ/regional_workflow
cd ${HOMEfv3}/rocoto
rocotorun -v 10 -w fv3sartest_2020012300.xml -d fv3sartest_2020012300.db
echo 'job done'

