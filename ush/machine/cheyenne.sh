#!/bin/bash

set -x

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model location


  external_model=${1}
  external_file_fmt=${2}

  case ${external_model} in

    "FV3GFS")
      location='/glade/p/ral/jntp/UFS_CAM/COMGFS/gfs.${yyyymmdd}/${hh}'
      ;;
    "*")
      print_info_msg"\
        External model \'${external_model}\' does not have a default
      location on Cheyenne. Please set a user-defined file location."
      ;;

  esac
  echo ${location:-}

}

EXTRN_MDL_SYSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location \
  ${EXTRN_MDL_NAME_ICS} \
  ${FV3GFS_FILE_FMT_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location \
  ${EXTRN_MDL_NAME_LBCS} \
  ${FV3GFS_FILE_FMT_ICS})}

# System Installations
MODULE_INIT_PATH=${MODULE_INIT_PATH:-/glade/u/apps/ch/opt/lmod/8.1.7/lmod/8.1.7/init/sh}

# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE="${NCORES_PER_NODE:-36}"
SCHED=${SCHED:-"pbspro"}
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"regular"}
QUEUE_HPSS=${QUEUE_HPSS:-"regular"}
QUEUE_FCST=${QUEUE_FCST:-"regular"}

# UFS SRW App specific paths
FIXgsm=${FIXgsm:-"/glade/p/ral/jntp/UFS_CAM/fix/fix_am"}
TOPO_DIR=${TOPO_DIR:-"/glade/p/ral/jntp/UFS_CAM/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/glade/p/ral/jntp/UFS_CAM/fix/climo_fields_netcdf"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/needs/to/be/specified"}

RUN_CMD_SERIAL="time"
RUN_CMD_UTILS='mpirun -np $nprocs'
RUN_CMD_FCST='mpirun -np $nprocs'
RUN_CMD_POST='mpirun -np $nprocs'

ulimit -s unlimited
ulimit -a
