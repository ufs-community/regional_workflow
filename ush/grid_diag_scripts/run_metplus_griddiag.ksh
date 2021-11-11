#!/bin/ksh
#SBATCH --account=fv3lam
#SBATCH --qos=batch
#SBATCH --partition=hera
#SBATCH --nodes=1-1
#SBATCH --tasks-per-node=24
#SBATCH -t 08:00:00
#SBATCH --job-name=metplus_griddiag
#SBATCH -o run_metplus_griddiag.log
#SBATCH --comment=04c8cc92f991c4c6df2d1ac414839d6c

# Set up environment on Hera 
module purge
module use -a /contrib/anaconda/modulefiles
module load intel/18.0.5.274
module load anaconda/latest
module use -a /contrib/met/modulefiles/
module load met/10.0.0
module use /contrib/METplus/modulefiles
module load metplus/4.0.0

# Set paths
MET_INSTALL_DIR=/contrib/met/10.0.0
MET_BIN_EXEC=bin
MET_CONFIG=/scratch2/BMC/fv3lam/RRFS_baseline/ufs-srweather-app/regional_workflow/ush/templates/parm/met
METPLUS_PATH=/contrib/METplus/METplus-4.0.0
METPLUS_CONF=/scratch2/BMC/fv3lam/RRFS_baseline/ufs-srweather-app/regional_workflow/ush/templates/parm/metplus

INPUT_BASE=/scratch2/BMC/fv3lam/RRFS_baseline
OUTPUT_BASE=/scratch2/BMC/fv3lam/RRFS_baseline/expt_dirs/RRFS_baseline_summer/GridDiag

export MET_INSTALL_DIR
export MET_BIN_EXEC
export METPLUS_PATH
export METPLUS_CONF
export MET_CONFIG

export INPUT_BASE
export OUTPUT_BASE
export OBS_DIR

# Set dates/times to process
INIT_BEG=2019041500 #2019041500
INIT_END=2019053000 #2019053000
INIT_INC=259200 #in seconds (3 days)

FHR_FIRST=12 #00
FHR_LAST=36 #36
FHR_INC=1 #hourly

export INIT_BEG
export INIT_END
export INIT_INC
export FHR_FIRST
export FHR_LAST
export FHR_INC

MODEL=FV3_RRFS_v1alpha_3km_summer
NET=rrfs
export MODEL
export NET

export SEASON=summer

echo "Go to OUTPUT_BASE:${OUTPUT_BASE}"
cd ${OUTPUT_BASE}

${METPLUS_PATH}/ush/master_metplus.py \
  -c ${METPLUS_CONF}/common.conf \
  -c ${METPLUS_CONF}/GridDiag_REFC.conf
