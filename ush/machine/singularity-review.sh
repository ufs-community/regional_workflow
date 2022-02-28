#!/bin/bash

set -x

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model location

  external_model=${1}
  external_file_fmt=${2}

  case ${external_model} in

    "*")
      print_info_msg"\
        External model \'${external_model}\' does not have a default
      location. Please set a user-defined file location."
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
MODULE_INIT_PATH=${MODULE_INIT_PATH:-/usr/share/lmod/6.6/init/profile}

# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE=${NCORES_PER_NODE:-40}
SCHED=${SCHED:-"slurm"}
PARTITION_DEFAULT=${PARTITION_DEFAULT:-"orion"}
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"batch"}
PARTITION_HPSS=${PARTITION_HPSS:-"service"}
QUEUE_HPSS=${QUEUE_HPSS:-"batch"}
PARTITION_FCST=${PARTITION_FCST:-"orion"}
QUEUE_FCST=${QUEUE_FCST:-"batch"}

# UFS SRW App specific paths
FIXgsm=${FIXgsm:-"/contrib/global/glopara/fix/fix_am"}
FIXaer=${FIXaer:-"/contrib/global/glopara/fix/fix_aer"}
FIXlut=${FIXlut:-"/contrib/global/glopara/fix/fix_lut"}
TOPO_DIR=${TOPO_DIR:-"/contrib/global/glopara/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/contrib/global/glopara/fix/fix_sfc_climo"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/needs/to/be/specified"}

RUN_CMD_SERIAL="time"
RUN_CMD_UTILS="mpi"
RUN_CMD_FCST='mpirun -n ${PE_MEMBER01} --oversubscribe'
RUN_CMD_POST="mpi"

# Test Data Locations
TEST_EXTRN_MDL_SOURCE_BASEDIR=/contrib/gsd-fv3-dev/gsketefia/UFS/staged_extrn_mdl_files

ulimit -s unlimited
ulimit -a
