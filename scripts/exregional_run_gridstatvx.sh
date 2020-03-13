#!/bin/sh -l
set -x

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that runs the post-processor (UPP) on
the output files corresponding to a specified forecast hour.
========================================================================"

#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( "cycle_dir" "postprd_dir" "fhr_dir" "fhr" )
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Load modules.
#
#-----------------------------------------------------------------------
#

print_info_msg "$VERBOSE" "Starting grid-stat verification"

case $MACHINE in


"WCOSS_C" | "WCOSS" )
#  { save_shell_opts; set +x; } > /dev/null 2>&1
  module purge
  . $MODULESHOME/init/ksh
  module load PrgEnv-intel ESMF-intel-haswell/3_1_0rp5 cfp-intel-sandybridge iobuf craype-hugepages2M craype-haswell
#  module load cfp-intel-sandybridge/1.1.0
  module use /gpfs/hps/nco/ops/nwprod/modulefiles
  module load prod_envir
#  module load prod_util
  module load prod_util/1.0.23
  module load grib_util/1.0.3
  module load crtm-intel/2.2.5
  module list
#  { restore_shell_opts; } > /dev/null 2>&1

# Specify computational resources.
  export NODES=8
  export ntasks=96
  export ptile=12
  export threads=1
  export MP_LABELIO=yes
  export OMP_NUM_THREADS=$threads

  APRUN="aprun -j 1 -n${ntasks} -N${ptile} -d${threads} -cc depth"
  ;;


"THEIA")
  { save_shell_opts; set +x; } > /dev/null 2>&1
  module purge
  module load intel
  module load impi
  module load netcdf
  module load contrib wrap-mpi
  { restore_shell_opts; } > /dev/null 2>&1
  np=${SLURM_NTASKS}
  APRUN="mpirun -np ${np}"
  ;;


"HERA")
#  export NDATE=/scratch3/NCEPDEV/nwprod/lib/prod_util/v1.1.0/exec/ndate
  APRUN="srun"
  ;;


"JET")
  { save_shell_opts; set +x; } > /dev/null 2>&1
  module purge
  . /apps/lmod/lmod/init/sh
  module load newdefaults
  module load intel/15.0.3.187
  module load impi/5.1.1.109
  module load szip
  module load hdf5
  module load netcdf4/4.2.1.1

  set libdir /mnt/lfs3/projects/hfv3gfs/gwv/ljtjet/lib

  export NCEPLIBS=/mnt/lfs3/projects/hfv3gfs/gwv/ljtjet/lib

  module use /mnt/lfs3/projects/hfv3gfs/gwv/ljtjet/lib/modulefiles
  module load bacio-intel-sandybridge
  module load sp-intel-sandybridge
  module load ip-intel-sandybridge
  module load w3nco-intel-sandybridge
  module load w3emc-intel-sandybridge
  module load nemsio-intel-sandybridge
  module load sfcio-intel-sandybridge
  module load sigio-intel-sandybridge
  module load g2-intel-sandybridge
  module load g2tmpl-intel-sandybridge
  module load gfsio-intel-sandybridge
  module load crtm-intel-sandybridge

  module use /lfs3/projects/hfv3gfs/emc.nemspara/soft/modulefiles
  module load esmf/7.1.0r_impi_optim
  module load contrib wrap-mpi
  { restore_shell_opts; } > /dev/null 2>&1

  np=${SLURM_NTASKS}
  APRUN="mpirun -np ${np}"
  ;;


"ODIN")
  APRUN="srun -n 1"
  ;;


esac

export METPLUS_PATH=/contrib/METplus/METplus-3.0-beta3
export METPLUS_CONF=/scratch2/BMC/det/jwolff/HIWT/add_metplus/regional_workflow/ush/templates/parm/metplus

#
#-----------------------------------------------------------------------
#
# Remove any files from previous runs and stage necessary files in gridstat_dir.
#
#-----------------------------------------------------------------------
#
cd ${gridstat_dir}

rm_vrfy -f grid_stat*.stat

#
#-----------------------------------------------------------------------
#
# Get the cycle date and hour (in formats of yyyymmdd and hh, respect-
# ively) from CDATE.
#
#-----------------------------------------------------------------------
#
yyyymmdd=${CDATE:0:8}
hh=${CDATE:8:2}
cyc=$hh

INIT=${CDATE}
export INIT

export ccpapath=/scratch2/BMC/det/harrold/data_pull/ccpa/reorg
export polydir=/contrib/met/9.0_beta3/share/met/poly

# Run CCPA organization script
/scratch2/BMC/det/jwolff/HIWT/add_metplus/regional_workflow/scripts/exregional_get_ccpa_files.ksh

export acc="01h" # for stats output prefix in GridStatConfig

# 1h ctc/sl1l2 scores:

export MODEL="FV3_GSD_SAR_GSD_HRRR3km"
export modpath=${postprd_dir}
${METPLUS_PATH}/ush/master_metplus.py \
  -c ${METPLUS_CONF}/common_hera.conf \
  -c ${METPLUS_CONF}/APCP_${acc}.conf

