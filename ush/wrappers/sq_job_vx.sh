#!/bin/sh
#SBATCH -e /scratch2/BMC/fv3lam/harrold/expt_dirs/FV3_GFS_v15p2_CONUS_25km/log/run_gridvx.log
#SBATCH --account=fv3lam
#SBATCH --qos=batch
#SBATCH --ntasks=1
#SBATCH --time=20
#SBATCH --job-name="run_pointvx"
cd /scratch2/BMC/fv3lam/harrold/expt_dirs/FV3_GFS_v15p2_CONUS_25km
set -x
. /apps/lmod/lmod/init/sh

module purge
module load hpss

module use -a /contrib/anaconda/modulefiles
module load intel/18.0.5.274
module load anaconda/latest
module use -a /contrib/met/modulefiles/
module load met/10.0.0

#./run_pointvx.sh
./run_gridvx.sh
