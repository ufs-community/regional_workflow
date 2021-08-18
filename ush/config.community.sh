MACHINE="hera"
ACCOUNT="an_account"
EXPT_SUBDIR="test_community"

COMPILER="intel"
VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

CCPP_PHYS_SUITE="FV3_GFS_v15p2"
FCST_LEN_HRS="48"
LBC_SPEC_INTVL_HRS="6"

DATE_FIRST_CYCL="20190615"
DATE_LAST_CYCL="20190615"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="FV3GFS"
FV3GFS_FILE_FMT_ICS="grib2"
EXTRN_MDL_NAME_LBCS="FV3GFS"
FV3GFS_FILE_FMT_LBCS="grib2"

WTIME_RUN_FCST="01:00:00"

MODEL="FV3_GFS_v15p2_CONUS_25km"
METPLUS_PATH="path/to/METPlus"
MET_INSTALL_DIR="path/to/MET"
CCPA_OBS_DIR="/path/to/processed/CCPA/data"
MRMS_OBS_DIR="/path/to/processed/MRMS/data"
NDAS_OBS_DIR="/path/to/processed/NDAS/data"

RUN_TASK_MAKE_GRID="TRUE"
RUN_TASK_MAKE_OROG="TRUE"
RUN_TASK_MAKE_SFC_CLIMO="TRUE"
RUN_TASK_GET_OBS_CCPA="FALSE"
RUN_TASK_GET_OBS_MRMS="FALSE"
RUN_TASK_GET_OBS_NDAS="FALSE"
RUN_TASK_VX_GRIDSTAT="FALSE"
RUN_TASK_VX_POINTSTAT="FALSE"
#
# Uncomment the following lines to be able to use user-staged external 
# model files.  Note that the values of EXTRN_MDL_BASEDIRS_ICS and 
# EXTRN_MDL_BASEDIRS_LBCS below are specifically for Hera.  
#
# If the lines below are left commented, the workflow scripts will first 
# attempt to get the files from disk, then from NOAA HPSS, and finally
# (if needed) from NOMADS.  The attempt from disk will fail because the 
# default values that EXTRN_MDL_BASEDIRS_ICS and EXTRN_MDL_BASEDIRS_LBCS 
# get assigned if they are not specified below will not contain the data 
# for the date specified above (because that date is not recent, i.e. 
# not within the last 2 weeks or 2 days, depending on the machine).  
# Whether or not the attempt to get the files from NOAA HPSS will succeed 
# or fail depends on whether the machine the experiment is running on 
# has access to NOAA HPSS.  Finally, the attempt to fetch from NOMADS 
# will also fail because the date above is not recent (and only data 
# that is relatively recent dates is available on NOMADS).
#
#EXTRN_MDL_BASEDIRS_ICS="/scratch2/BMC/det/UFS_SRW_app/develop2/model_data/FV3GFS/grib2"
#EXTRN_MDL_BASEDIRS_LBCS="/scratch2/BMC/det/UFS_SRW_app/develop2/model_data/FV3GFS/grib2"
#EXTRN_MDL_DIR_FILE_LAYOUT="user_spec"
#EXTRN_MDL_FNS_ICS=( "gfs.pgrb2.0p25.f000" )
#EXTRN_MDL_FNS_LBCS_PREFIX="gfs.pgrb2.0p25.f"
#EXTRN_MDL_FNS_LBCS_SUFFIX=""

