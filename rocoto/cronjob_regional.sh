#!/bin/sh -l

set -x

cd /gpfs/dell2/emc/modeling/noscrub/${USER}/regional_workflow/rocoto

rocotorun -v 10 -w fv3sar_2019071700.xml -d fv3sar_2019071700.db

echo 'job done'

