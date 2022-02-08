#
# The machine on which to run, the account to which to charge computational
# resources, the base directory in which to create the experiment directory
# (if different from the default location), and the name of the experiment
# subdirectory.
#
MACHINE="SINGULARITY"
COMPILER="gnu"
ACCOUNT="none"
EXPT_SUBDIR="SING_GST_lowres"
EXPT_BASEDIR="/lustre/$USER/expt_dirs"

VERBOSE="TRUE"

NNODES_MAKE_ICS="1"
NNODES_MAKE_LBCS="1"
NNODES_RUN_POST="1"
NNODES_MAKE_SFC_CLIMO="1"
OMP_NUM_THREADS_MAKE_SFC_CLIMO="1"
PPN_MAKE_SFC_CLIMO="20"
PPN_RUN_FCST="44"
OMP_NUM_THREADS_RUN_FCST="1"
OMP_STACKSIZE_RUN_FCST="1024m"
PPN_MAKE_ICS="2"
PPN_MAKE_LBCS="2"
PPN_RUN_POST="2"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"


DATE_FIRST_CYCL="20190615"
DATE_LAST_CYCL="20190615"
CYCL_HRS=( "18" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"

FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"

WTIME_RUN_FCST="00:30:00"

USE_USER_STAGED_EXTRN_FILES="TRUE"
EXTRN_MDL_SOURCE_BASEDIR_ICS="/contrib/GST/model_data/FV3GFS"
EXTRN_MDL_FILES_ICS=( "gfs.pgrb2.0p25.f000" )
EXTRN_MDL_SOURCE_BASEDIR_LBCS="/contrib/GST/model_data/FV3GFS"
EXTRN_MDL_FILES_LBCS=( "gfs.pgrb2.0p25.f006" "gfs.pgrb2.0p25.f012" )
#
# Flag specifying whether or not to automatically resubmit the worfklow
# to the batch system via cron and, if so, the frequency (in minutes) of
# resubmission.
#
#USE_CRON_TO_RELAUNCH="TRUE"
#CRON_RELAUNCH_INTVL_MNTS="02"
#
# Flag specifying whether to run in verbose mode.
#
VERBOSE="TRUE"
#
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
# The following section is a copy of this WE2E test's configuration file.
#
#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# Testing a custom grid for the AMS 2022 SRW Workshop.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

CCPP_PHYS_SUITE="FV3_GFS_v15p2"

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"
USE_USER_STAGED_EXTRN_FILES="TRUE"

DATE_FIRST_CYCL="20190615"
DATE_LAST_CYCL="20190615"
CYCL_HRS=( "18" )

FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="6"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
GRID_GEN_METHOD="ESGgrid"

LAYOUT_X="${LAYOUT_X:-2}"
LAYOUT_Y="${LAYOUT_Y:-17}"

QUILTING="TRUE"
MAXTRIES_MAKE_GRID="1"
MAXTRIES_MAKE_OROG="1"
MAXTRIES_MAKE_SFC_CLIMO="1"
MAXTRIES_GET_EXTRN_ICS="1"
MAXTRIES_GET_EXTRN_LBCS="1"
MAXTRIES_MAKE_ICS="2"
MAXTRIES_MAKE_LBCS="2"
MAXTRIES_RUN_FCST="1"
MAXTRIES_RUN_POST="2"
