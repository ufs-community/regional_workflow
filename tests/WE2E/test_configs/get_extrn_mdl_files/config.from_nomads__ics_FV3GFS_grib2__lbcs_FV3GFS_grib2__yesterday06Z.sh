#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test checks the capability of the workflow to retrieve from NOMADS 
# (NOAA Operational Model Archive and Distribution System) grib2-formatted 
# output files generated by the FV3GFS external model (from which ICs and 
# LBCs will be derived).
#
# Note that NOMADS hosts only the most recent few days' files.  For this 
# reason, the starting day of the forecast is set here to be "1 days ago" 
# (i.e. yesterday).
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
CCPP_PHYS_SUITE="FV3_GFS_v15p2"

EXTRN_MDL_NAME_ICS="FV3GFS"
FV3GFS_FILE_FMT_ICS="grib2"
EXTRN_MDL_NAME_LBCS="FV3GFS"
FV3GFS_FILE_FMT_LBCS="grib2"

EXTRN_MDL_DATA_SOURCES=( "nomads" )

DATE_FIRST_CYCL=$( date --utc --date="1 days ago" "+%Y%m%d" )
DATE_LAST_CYCL="${DATE_FIRST_CYCL}"
CYCL_HRS=( "00" )

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="3"
