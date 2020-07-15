#!/bin/sh
#SBATCH -e /scratch1/BMC/gmtb/Laurie.Carson/expt_dirs/test_wrappers/log/run_make_sfc_climo.log
#SBATCH --account=gmtb
#SBATCH --qos=batch
#SBATCH --ntasks=24
#SBATCH --time=20
#SBATCH --job-name="run_make_sfc_climo"
cd /scratch1/BMC/gmtb/Laurie.Carson/expt_dirs/test_wrappers
set -x
. /apps/lmod/lmod/init/sh

module purge
module load hpss

module load intel/18.0.5.274
module load impi/2018.0.4
module load netcdf/4.7.0
# use this version for make_ics and make_lbcs - for now
#module load netcdf/4.6.1
module load hdf5/1.10.5
module load wgrib2


module use -a /contrib/miniconda3/modulefiles
module load miniconda3
conda activate regional_workflow

./run_make_sfc_climo.sh
