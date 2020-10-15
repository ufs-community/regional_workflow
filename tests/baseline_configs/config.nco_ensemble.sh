RUN_ENVIR="nco"
PREEXISTING_DIR_METHOD="rename"

EMC_GRID_NAME="conus_c96"  # This maps to PREDEF_GRID_NAME="EMC_CONUS_coarse".
GRID_GEN_METHOD="GFDLgrid"
QUILTING="TRUE"

CCPP_PHYS_SUITE="FV3_GFS_2017_gfdlmp_regional"

FCST_LEN_HRS="06"
LBC_SPEC_INTVL_HRS="3"

DATE_FIRST_CYCL="20190901"
DATE_LAST_CYCL="20190901"
CYCL_HRS=( "12" "18" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"
USE_USER_STAGED_EXTRN_FILES="TRUE"

DO_ENSEMBLE="TRUE"
NUM_ENS_MEMBERS="2"
