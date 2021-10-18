#!/bin/bash

set -x

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model file_tmpl location

  external_model=${1}
  external_file_fmt=${2}

  case ${external_model} in

    "FV3GFS")
      location='/gpfs/dell1/nco/ops/com/gfs/prod/gfs.${yyyymmdd}/${hh}/atmos'
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
    "RAP")
      location='/gpfs/hps/nco/ops/com/rap/prod'
      file_tmpl='${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}'
      ;;
    "HRRR")
      location='/gpfs/hps/nco/ops/com/hrrr/prod'
      file_tmpl='${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}'
      ;;
    "NAM")
      location='/gpfs/dell1/nco/ops/com/nam/prod'
      file_tmpl='nam.t${hh}z.bgrds${fcst_hh}.tm${hh}'
      ;;
    "*")
      print_err_msg_exit"\
        External model \'${external_model}\' does not have a default
      location on Jet Please set a user-defined file location."
      ;;

  esac
  echo ${location:-}/${file_tmpl:-}
}


EXTRN_MDL_SYSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location \
  ${EXTRN_MDL_NAME_ICS} \
  ${FV3GFS_FILE_FMT_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location \
  ${EXTRN_MDL_NAME_LBCS} \
  ${FV3GFS_FILE_FMT_ICS})}

# System Installations
MODULE_INIT_PATH=${MODULE_INIT_PATH:-/opt/modules/default/init/sh}

# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE="24"
SCHED="lsfcray"
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"dev"}
QUEUE_HPSS=${QUEUE_HPSS:-"dev_transfer"}
QUEUE_FCST=${QUEUE_FCST:-"dev"}
RELATIVE_LINK_FLAG=""

# UFS SRW App specific paths
FIXgsm=${FIXgsm:-"/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix/fix_am"}
TOPO_DIR=${TOPO_DIR:-"/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix/fix_sfc_climo"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/needs/to/be/specified"}
