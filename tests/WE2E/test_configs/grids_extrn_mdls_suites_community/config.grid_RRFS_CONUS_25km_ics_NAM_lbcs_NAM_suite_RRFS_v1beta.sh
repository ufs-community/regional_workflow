#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test is to ensure that the workflow running in community mode 
# completes successfully on the RRFS_CONUS_25km grid using the RRFS_v1beta
# physics suite with ICs and LBCs derived from the NAM.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
CCPP_PHYS_SUITE="FV3_RRFS_v1beta"

EXTRN_MDL_NAME_ICS="NAM"
EXTRN_MDL_NAME_LBCS="NAM"

EXTRN_MDL_DATA_SOURCES=( "disk" )
EXTRN_MDL_DIR_FILE_LAYOUT="user_spec"

DATE_FIRST_CYCL="20150602"
DATE_LAST_CYCL="20150602"
CYCL_HRS=( "12" )

FCST_LEN_HRS="24"
LBC_SPEC_INTVL_HRS="3"
