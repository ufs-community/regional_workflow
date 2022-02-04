#!/bin/bash

set -x

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model location

  external_model=${1}
  external_file_fmt=${2}

  case ${external_model} in

    "FV3GFS")
      location='/gpfs/dell1/nco/ops/com/gfs/prod/gfs.${yyyymmdd}/${hh}/atmos'
      ;;
    "RAP")
      location='/gpfs/hps/nco/ops/com/rap/prod'
      ;;
    "HRRR")
      location='/gpfs/hps/nco/ops/com/hrrr/prod'
      ;;
    "NAM")
      location='/gpfs/dell1/nco/ops/com/nam/prod'
      ;;
    "*")
      print_err_msg_exit"\
        External model \'${external_model}\' does not have a default
      location on Jet Please set a user-defined file location."
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
MODULE_INIT_PATH=${MODULE_INIT_PATH:-/opt/modules/default/init/sh}

# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE=${NCORES_PER_NODE:-24}
SCHED=${SCHED:-"lsf"}
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"dev"}
QUEUE_HPSS=${QUEUE_HPSS:-"dev_transfer"}
QUEUE_FCST=${QUEUE_FCST:-"dev"}

# UFS SRW App specific paths
FIXgsm=${FIXgsm:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_am"}
FIXaer=${FIXaer:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_aer"}
FIXlut=${FIXlut:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_lut"}
TOPO_DIR=${TOPO_DIR:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_sfc_climo"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/gpfs/dell2/emc/modeling/noscrub/UFS_SRW_App/FV3LAM_pregen"}

# RRFS-CMAQ specific paths
AQM_CONFIG_DIR=${AQM_CONFIG_DIR:-"/gpfs/dell2/emc/modeling/noscrub/RRFS_CMAQ/aqm/epa/data"}
AQM_BIO_DIR=${AQM_BIO_DIR:-"/gpfs/dell2/emc/modeling/noscrub/RRFS_CMAQ/aqm/bio"}
AQM_FIRE_DIR=${AQM_FIRE_DIR:-"/gpfs/dell2/emc/modeling/noscrub/RRFS_CMAQ/emissions/GSCE/GBBEPx.in.C401/Reprocessed"}
AQM_LBCS_DIR=${AQM_LBCS_DIR:-"/gpfs/dell2/emc/modeling/noscrub/RRFS_CMAQ/LBCS/boundary_conditions_v4"}
AQM_GEFS_DIR=${AQM_GEFS_DIR:-"/gpfs/dell2/emc/modeling/noscrub/RRFS_CMAQ/GEFS_aerosol"}
NEXUS_INPUT_DIR=${NEXUS_INPUT_DIR:-"/gpfs/dell2/emc/retros/noscrub/Barry.Baker/emissions"}
NEXUS_FIX_DIR=${NEXUS_FIX_DIR:-"/gpfs/dell2/emc/modeling/noscrub/RRFS_CMAQ/nexus/fix"}
DA_OBS_DIR=${DA_OBS_DIR:-""}
FIXgsi=${FIXgsi:-""}
FIXcrtm=${FIXcrtm:-""}
AIRCRAFT_REJECT=${AIRCRAFT_REJECT:-""}
SFCOBS_USELIST=${SFCOBS_USELIST:-""}
AODPATH=${AODPATH:-""}
PMPATH=${PMPATH:-""}

# MET Installation Locations
MET_INSTALL_DIR="/gpfs/dell2/emc/verification/noscrub/emc.metplus/met/10.0.0"
METPLUS_PATH="/gpfs/dell2/emc/verification/noscrub/emc.metplus/METplus/METplus-4.0.0"
CCPA_OBS_DIR="/gpfs/dell2/emc/modeling/noscrub/UFS_SRW_App/obs_data/ccpa/proc"
MRMS_OBS_DIR="/gpfs/dell2/emc/modeling/noscrub/UFS_SRW_App/obs_data/mrms/proc"
NDAS_OBS_DIR="/gpfs/dell2/emc/modeling/noscrub/UFS_SRW_App/obs_data/ndas/proc"
MET_BIN_EXEC="exec"

# Test Data Locations
TEST_PREGEN_BASEDIR=/gpfs/dell2/emc/modeling/noscrub/UFS_SRW_App/FV3LAM_pregen
TEST_COMINgfs=/gpfs/dell2/emc/modeling/noscrub/UFS_SRW_App/COMGFS
TEST_EXTRN_MDL_SOURCE_BASEDIR=/gpfs/dell2/emc/modeling/noscrub/UFS_SRW_App/extrn_mdl_files

