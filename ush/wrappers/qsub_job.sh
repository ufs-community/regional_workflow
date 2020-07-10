#!/bin/sh
#PBS -A P48503002
#PBS -q regular
#PBS -l select=1:mpiprocs=24:ncpus=24
#PBS -l walltime=00:20:00
#PBS -N make_orog
#PBS -j oe -o /glade/scratch/carson/ufs/expt_dirs/standalone-test/log/make_orog.log
cd /glade/scratch/carson/ufs/expt_dirs/standalone-test
set -x
./run_make_orog.sh
