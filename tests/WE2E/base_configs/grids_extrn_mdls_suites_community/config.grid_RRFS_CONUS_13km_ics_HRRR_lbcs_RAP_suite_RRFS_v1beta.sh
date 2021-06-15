#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test is to ensure that the workflow running in community mode 
# completes successfully on the RRFS_CONUS_13km grid using the RRFS_v1beta
# physics suite with ICs derived from the HRRR and LBCs derived from the
# RAP.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_13km"
QUILTING="TRUE"

CCPP_PHYS_SUITE="FV3_RRFS_v1beta"
FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="3"

DATE_FIRST_CYCL="20200801"
DATE_LAST_CYCL="20200801"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="HRRR"
EXTRN_MDL_NAME_LBCS="RAP"
USE_USER_STAGED_EXTRN_FILES="TRUE"
