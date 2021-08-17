#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test checks the capability of the workflow to retrieve from NOAA 
# HPSS grib2-formatted output files generated by the FV3GFS external 
# model (from which ICs and LBCs will be derived) on the last cycle date 
# (2020022518) before changes to the FV3GFS output files took effect on 
# 2020022600.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
CCPP_PHYS_SUITE="FV3_GFS_v15p2"

EXTRN_MDL_NAME_ICS="FV3GFS"
FV3GFS_FILE_FMT_ICS="grib2"
EXTRN_MDL_NAME_LBCS="FV3GFS"
FV3GFS_FILE_FMT_LBCS="grib2"

EXTRN_MDL_DATA_SOURCES=( "noaa_hpss" )

DATE_FIRST_CYCL="20200225"
DATE_LAST_CYCL="20200225"
CYCL_HRS=( "18" )

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="3"
