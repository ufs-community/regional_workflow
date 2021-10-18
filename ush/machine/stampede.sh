#!/bin/bash

set -x

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model file_tmpl location

  external_model=${1}
  external_file_fmt=${2}

  case ${external_model} in

    "GSMGFS")
      ;&
    "FV3GFS")
      location='/scratch/00315/tg455890/GDAS/20190530/2019053000_mem001'
      case $external_file_fmt in
        "nemsio")
          file_tmpl='gfs.t${hh}z.atmf${fcst_hhh}.nemsio'
          ;;
        "grib2")
          file_tmpl='gfs.t${hh}z.pgrb2.0p25.f${fcst_hhh}'
          ;;
        "netcdf")
          file_tmpl='gfs.t${hh}z.atmf${fcst_hhh}.nc'
          ;;
      esac
      ;;
    "*")
      print_err_msg_exit"\
        External model \'${external_model}\' does not have a default
      location on Jet Please set a user-defined file location."
      ;;

  esac
  echo ${location:-}/${file_tmpl:-}
}


# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE=68
SCHED="slurm"
YSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location \
  ${EXTRN_MDL_NAME_ICS} \
  ${FV3GFS_FILE_FMT_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location \
  ${EXTRN_MDL_NAME_LBCS} \
  ${FV3GFS_FILE_FMT_ICS})}

QUEUE_DEFAULT=${QUEUE_DEFAULT:-"normal"}
PARTITION_HPSS=${PARTITION_HPSS:-"normal"}
QUEUE_HPSS=${QUEUE_HPSS:-"normal"}
PARTITION_FCST=${PARTITION_FCST:-"normal"}

# UFS SRW App specific paths
FIXgsm=${FIXgsm:-"/work/00315/tg455890/stampede2/regional_fv3/fix_am"}
TOPO_DIR=${TOPO_DIR:-"/work/00315/tg455890/stampede2/regional_fv3/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/work/00315/tg455890/stampede2/regional_fv3/climo_fields_netcdf"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/needs/to/be/specified"}

SERIAL_APRUN="time"
RUN_CMD_UTILS='ibrun -np $nprocs'
RUN_CMD_FCST='ibrun -np $nprocs'
RUN_CMD_POST='ibrun -np $nprocs'

ulimit -s unlimited
ulimit -a
