#
# The values of the variables MACHINE, ACCOUNT, and EXPT_SUBDIR are required
# inputs to the script that launces the WE2E test experiments.  That script 
# will use those inputs to fill in the values of these variables below.
#
MACHINE=""
ACCOUNT=""
EXPT_SUBDIR=""
#
# The values of the variables USE_CRON_TO_RELAUNCH and CRON_RELAUNCH_INTVL_MNTS
# are optional inputs to the script that launces the WE2E test experiments.  
# If one or both of these values are specified, then that script will 
# replace the default values of these variables below with those values.
# Otherwise, it will keep the default values.
#
USE_CRON_TO_RELAUNCH="TRUE"
CRON_RELAUNCH_INTVL_MNTS="02"


QUEUE_DEFAULT="batch"
QUEUE_HPSS="service"
QUEUE_FCST="batch"

VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_HRRR3km"
GRID_GEN_METHOD="GFDLgrid"

QUILTING="TRUE"
USE_CCPP="TRUE"
CCPP_PHYS_SUITE="FV3_GSD_SAR"
FCST_LEN_HRS="06"
LBC_SPEC_INTVL_HRS="3"

DATE_FIRST_CYCL="20200801"
DATE_LAST_CYCL="20200801"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="HRRRX"
EXTRN_MDL_NAME_LBCS="RAPX"

RUN_TASK_MAKE_GRID="TRUE"
RUN_TASK_MAKE_OROG="TRUE"
RUN_TASK_MAKE_SFC_CLIMO="TRUE"

# If want to use user-staged external model files:

#On Hera:
EXTRN_MDL_SOURCE_DIR_ICS="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/staged_extrn_mdl_files/HRRRX"
EXTRN_MDL_FILES_ICS=( "hrrrx.out.for_f000" )
EXTRN_MDL_SOURCE_DIR_LBCS="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/staged_extrn_mdl_files/RAPX"
EXTRN_MDL_FILES_LBCS=( "rapx.out.for_f003" "rapx.out.for_f006" )

#On Jet:
#EXTRN_MDL_SOURCE_DIR_ICS="/mnt/lfs1/BMC/fim/Gerard.Ketefian/UFS_CAM/staged_extrn_mdl_files/HRRRX"
#EXTRN_MDL_FILES_ICS=( "hrrrx.out.for_f000" )
#EXTRN_MDL_SOURCE_DIR_LBCS="/mnt/lfs1/BMC/fim/Gerard.Ketefian/UFS_CAM/staged_extrn_mdl_files/RAPX"
#EXTRN_MDL_FILES_LBCS=( "rapx.out.for_f003" "rapx.out.for_f006" )

