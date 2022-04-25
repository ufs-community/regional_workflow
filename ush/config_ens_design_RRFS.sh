MACHINE="hera"
ACCOUNT="fv3lam"
EXPT_SUBDIR="test_io"

COMPILER="intel"
VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

RUN_TASK_RUN_POST="FALSE"

DO_SPPT="false"
DO_SHUM="false"
DO_SKEB="false"

DO_SPP="false"
#SPP_VAR_LIST=( "pbl" "sfc" "mp" "rad" "gwd" )
#SPP_MAG_LIST=( "0.2" "0.2" "0.75" "0.2" "0.2" ) #Variable "spp_prt_list" in input.nml
#SPP_LSCALE=( "150000.0" "150000.0" "150000.0" "150000.0" "150000.0" )
#SPP_TSCALE=( "21600.0" "21600.0" "21600.0" "21600.0" "21600.0" ) #Variable "spp_tau" in input.nml
#SPP_SIGTOP1=( "0.1" "0.1" "0.1" "0.1" "0.1")
#SPP_SIGTOP2=( "0.025" "0.025" "0.025" "0.025" "0.025" )
#SPP_STDDEV_CUTOFF=( "1.5" "1.5" "2.5" "1.5" "1.5" )
#ISEED_SPP=( "4" "4" "4" "4" "4" )

DO_ENSEMBLE="TRUE"
NUM_ENS_MEMBERS="9"

CCPP_PHYS_SUITE="FV3_GFS_v15p2"
FCST_LEN_HRS="24"
LBC_SPEC_INTVL_HRS="6"

DATE_FIRST_CYCL="20210530"
DATE_LAST_CYCL="20210530"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"

FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"

WTIME_RUN_FCST="01:00:00"

NET='RRFSE_CONUS'

MODEL="FV3_GFS_v15p2_CONUS_25km"
METPLUS_PATH="/scratch2/BMC/fv3lam/ens_design_RRFS/metplus"
MET_INSTALL_DIR="/contrib/met/10.1.0"
MET_INPUT_DIR="/scratch1/BMC/hmtb/beck/ens_design_RRFS/data"
MET_OUTPUT_DIR="/scratch2/BMC/fv3lam/ens_design_RRFS/breakout_io/expt_dirs/test_io"
CCPA_OBS_DIR="/scratch2/BMC/fv3lam/ens_design_RRFS/obs_data/ccpa/proc"
MRMS_OBS_DIR="/scratch2/BMC/fv3lam/ens_design_RRFS/obs_data/mrms/proc"
NDAS_OBS_DIR="/scratch2/BMC/fv3lam/ens_design_RRFS/obs_data/ndas/proc"

RUN_TASK_GET_EXTRN_ICS="TRUE"
RUN_TASK_GET_EXTRN_LBCS="TRUE"
RUN_TASK_MAKE_ICS="TRUE"
RUN_TASK_MAKE_LBCS="TRUE"
RUN_TASK_MAKE_GRID="TRUE"
RUN_TASK_MAKE_OROG="TRUE"
RUN_TASK_MAKE_SFC_CLIMO="TRUE"
RUN_TASK_RUN_FCST="TRUE"
RUN_TASK_RUN_POST="TRUE"
RUN_TASK_GET_OBS_CCPA="TRUE"
RUN_TASK_GET_OBS_MRMS="TRUE"
RUN_TASK_GET_OBS_NDAS="TRUE"
RUN_TASK_VX_GRIDSTAT="TRUE"
RUN_TASK_VX_POINTSTAT="TRUE"
RUN_TASK_VX_ENSGRID="TRUE"
RUN_TASK_VX_ENSPOINT="TRUE"
RUN_GEN_ENS_PROD="TRUE"
RUN_ENSEMBLE_STAT="TRUE"

#
# Uncomment the following line in order to use user-staged external model 
# files with locations and names as specified by EXTRN_MDL_SOURCE_BASEDIR_ICS/
# LBCS and EXTRN_MDL_FILES_ICS/LBCS.
#
#USE_USER_STAGED_EXTRN_FILES="TRUE"
#
# The following is specifically for Hera.  It will have to be modified
# if on another platform, using other dates, other external models, etc.
# Uncomment the following EXTRN_MDL_*_ICS/LBCS only when USE_USER_STAGED_EXTRN_FILES=TRUE
#
#EXTRN_MDL_SOURCE_BASEDIR_ICS="/scratch2/BMC/det/UFS_SRW_app/v1p0/model_data/FV3GFS"
#EXTRN_MDL_FILES_ICS=( "gfs.pgrb2.0p25.f000" )
#EXTRN_MDL_SOURCE_BASEDIR_LBCS="/scratch2/BMC/det/UFS_SRW_app/v1p0/model_data/FV3GFS"
#EXTRN_MDL_FILES_LBCS=( "gfs.pgrb2.0p25.f006" "gfs.pgrb2.0p25.f012" "gfs.pgrb2.0p25.f018" "gfs.pgrb2.0p25.f024" )
