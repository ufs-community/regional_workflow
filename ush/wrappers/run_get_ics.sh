#!/bin/sh
#PBS -A P48503002
#PBS -q regular
#PBS -l select=1:mpiprocs=1:ncpus=1
#PBS -l walltime=00:10:00
#PBS -N get_ics
#PBS -j oe -o /glade/scratch/carson/ufs/expt_dirs/standalone-test/log/get_ics.log
export GLOBAL_VAR_DEFNS_FP='/glade/scratch/carson/ufs/expt_dirs/standalone-test/var_defns.sh'
set -x
source ${GLOBAL_VAR_DEFNS_FP}
export EXTRN_MDL_NAME="FV3GFS"
export ICS_OR_LBCS="ICS"
export CDATE="2019090118"
export CYCLE_DIR="/glade/scratch/carson/ufs/expt_dirs/standalone-test"
/glade/scratch/carson/ufs/ufs-srweather-app/regional_workflow/jobs/JREGIONAL_GET_EXTRN_MDL_FILES
