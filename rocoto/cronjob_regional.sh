#!/bin/sh -l

set -x

cd /gpfs/dell2/emc/modeling/noscrub/${USER}/save/regional_clean/rocoto

rocotorun -v 10 -w fv3sar_testdummy_2019071700.xml -d fv3sar_testdummy_2019071700.db

echo 'job done'

