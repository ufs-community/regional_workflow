#!/bin/bash

set -x

function file_location() {

  # Return the default location of external model files on disk
  # Orion does not currently have any files staged on disk.

  local external_file_fmt external_model file_tmpl location

  external_model=${1}
  external_file_fmt=${2}

  case ${external_model} in

    "*")
      print_info_msg"\
        External model \'${external_model}\' does not have a default
      location on Orion. Please set a user-defined file location."
      ;;

  esac
  echo ${location:-}/${file_tmpl}

}


EXTRN_MDL_SYSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location ${EXTRN_MDL_NAME_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location ${EXTRN_MDL_NAME_LBCS})}

# System Installations
MODULE_INIT_PATH=${MODULE_INIT_PATH:-/apps/lmod/lmod/init/sh}

# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE=40
SCHED=${SCHED:-"slurm"}
PARTITION_DEFAULT=${PARTITION_DEFAULT:-"orion"}
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"batch"}
PARTITION_HPSS=${PARTITION_HPSS:-"service"}
QUEUE_HPSS=${QUEUE_HPSS:-"batch"}
PARTITION_FCST=${PARTITION_FCST:-"orion"}

# UFS SRW App specific paths
FIXgsm=${FIXgsm:-"/work/noaa/global/glopara/fix/fix_am"}
TOPO_DIR=${TOPO_DIR:-"/work/noaa/global/glopara/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/work/noaa/global/glopara/fix/fix_sfc_climo"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/needs/to/be/specified"}

SERIAL_APRUN="time"
RUN_CMD_UTILS="srun"
RUN_CMD_FCST="srun"
RUN_CMD_POST="srun"

ulimit -s unlimited
ulimit -a
