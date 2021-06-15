#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test checks the capability of the workflow to retrieve from NOAA 
# HPSS files generated by the HRRR external model from which ICs (and 
# the LBCs at the 0th forecast hour) will be derived and files from the 
# RAP external model from which the LBCs (except for the ones at the 0th 
# forecast hour) will be derived.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

CCPP_PHYS_SUITE="FV3_GSD_SAR"

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="3"

DATE_FIRST_CYCL="20200801"
DATE_LAST_CYCL="20200801"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="HRRR"
EXTRN_MDL_NAME_LBCS="RAP"
