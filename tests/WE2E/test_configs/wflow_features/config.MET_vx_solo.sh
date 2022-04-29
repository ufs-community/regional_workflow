#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test is to ensure that a workflow running in community mode that
# contains only deterministic MET verification tasks completes successfully.
# The location of the input data to MET/METplus must be specified by the
# variable MET_INPUT_DIR.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
CCPP_PHYS_SUITE="FV3_GFS_v15p2"

USE_USER_STAGED_EXTRN_FILES="TRUE"

EXTRN_MDL_NAME_ICS="FV3GFS"
FV3GFS_FILE_FMT_ICS="grib2"
EXTRN_MDL_NAME_LBCS="FV3GFS"
FV3GFS_FILE_FMT_LBCS="grib2"

DATE_FIRST_CYCL="20190615"
DATE_LAST_CYCL="20190615"
CYCL_HRS=( "00" )

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="6"

RUN_TASK_MAKE_GRID="FALSE"
RUN_TASK_MAKE_OROG="FALSE"
RUN_TASK_MAKE_SFC_CLIMO="FALSE"
RUN_TASK_GET_EXTRN_ICS="FALSE"
RUN_TASK_GET_EXTRN_LBCS="FALSE"
RUN_TASK_MAKE_ICS="FALSE"
RUN_TASK_MAKE_LBCS="FALSE"
RUN_TASK_RUN_FCST="FALSE"
RUN_TASK_RUN_POST="FALSE"

RUN_TASK_GET_OBS_CCPA="TRUE"
RUN_TASK_GET_OBS_MRMS="TRUE"
RUN_TASK_GET_OBS_NDAS="TRUE"
RUN_TASK_VX_GRIDSTAT="TRUE"
RUN_TASK_VX_POINTSTAT="TRUE"

MODEL="${CCPP_PHYS_SUITE}_${PREDEF_GRID_NAME}"
MET_INPUT_DIR="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/TEST_Ligia_namelists/expt_dirs/MET_bug01/MET_verification"
CCPA_OBS_DIR="/scratch2/BMC/fv3lam/ens_design_RRFS/obs_data/ccpa/proc"
MRMS_OBS_DIR="/scratch2/BMC/fv3lam/ens_design_RRFS/obs_data/mrms/proc"
NDAS_OBS_DIR="/scratch2/BMC/fv3lam/ens_design_RRFS/obs_data/ndas/proc"

