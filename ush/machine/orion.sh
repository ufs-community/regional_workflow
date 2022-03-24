#!/bin/bash

function file_location() {

  # Return the default location of external model files on disk
  # Orion does not currently have any files staged on disk.

  local external_file_fmt external_model location

  external_model=${1}
  external_file_fmt=${2}

  location=""
  echo ${location:-}

}

EXTRN_MDL_SYSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location \
  ${EXTRN_MDL_NAME_ICS} \
  ${FV3GFS_FILE_FMT_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location \
  ${EXTRN_MDL_NAME_LBCS} \
  ${FV3GFS_FILE_FMT_LBCS})}

# System scripts to source to initialize various commands within workflow
# scripts (e.g. "module").
if [ -z ${ENV_INIT_SCRIPTS_FPS:-""} ]; then
  ENV_INIT_SCRIPTS_FPS=( "/etc/profile" )
fi

# Commands to run at the start of each workflow task.
PRE_TASK_CMDS='{ ulimit -s unlimited; ulimit -a; }'

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
FIXgsm=${FIXgsm:-"/work/noaa/global/glopara/fix/fix_am"}
FIXaer=${FIXaer:-"/work/noaa/global/glopara/fix/fix_aer"}
FIXlut=${FIXlut:-"/work/noaa/global/glopara/fix/fix_lut"}
TOPO_DIR=${TOPO_DIR:-"/work/noaa/global/glopara/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/work/noaa/global/glopara/fix/fix_sfc_climo"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/work/noaa/fv3-cam/UFS_SRW_App/FV3LAM_pregen"}

# Run commands for executables
RUN_CMD_SERIAL="time"
RUN_CMD_UTILS="srun"
RUN_CMD_FCST='srun -n ${PE_MEMBER01}'
RUN_CMD_POST="srun"

# MET/METplus-Related Paths
MET_INSTALL_DIR=${MET_INSTALL_DIR:-"/apps/contrib/MET/10.1.0"}
METPLUS_PATH=${METPLUS_PATH:-"/apps/contrib/MET/METplus/METplus-4.0.0"}
CCPA_OBS_DIR=${CCPA_OBS_DIR:-"/work/noaa/fv3-cam/UFS_SRW_App/develop/obs_data/ccpa/proc"}
MRMS_OBS_DIR=${MRMS_OBS_DIR:-"/work/noaa/fv3-cam/UFS_SRW_App/develop/obs_data/mrms/proc"}
NDAS_OBS_DIR=${NDAS_OBS_DIR:-"/work/noaa/fv3-cam/UFS_SRW_App/develop/obs_data/ndas/proc"}
MET_BIN_EXEC=${MET_BIN_EXEC:-"bin"}

# Test Data Locations
TEST_PREGEN_BASEDIR="/work/noaa/fv3-cam/UFS_SRW_App/FV3LAM_pregen"
TEST_COMINgfs="/work/noaa/fv3-cam/UFS_SRW_App/COMGFS"
TEST_EXTRN_MDL_SOURCE_BASEDIR="/work/noaa/fv3-cam/UFS_SRW_App/develop/model_data"

