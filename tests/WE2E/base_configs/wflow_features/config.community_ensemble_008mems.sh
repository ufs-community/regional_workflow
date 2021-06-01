# 
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test checks the capability of the workflow to run ensemble forecasts
# (i.e. DO_ENSEMBLE set to "TRUE") in community mode (i.e. RUN_ENVIR set 
# to "community") with the number of ensemble members (NUM_ENS_MEMBERS)
# set to "008".  The leading zeros in "008" should cause the ensemble 
# members to be numbered "mem001", "mem002", ..., "mem008" (instead of, 
# for instance, "mem1", "mem2", ..., "mem8").
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

CCPP_PHYS_SUITE="FV3_GFS_2017_gfdlmp"

FCST_LEN_HRS="06"
LBC_SPEC_INTVL_HRS="3"

DATE_FIRST_CYCL="20190701"
DATE_LAST_CYCL="20190702"
CYCL_HRS=( "00" "12" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"
USE_USER_STAGED_EXTRN_FILES="TRUE"

DO_ENSEMBLE="TRUE"
NUM_ENS_MEMBERS="008"
