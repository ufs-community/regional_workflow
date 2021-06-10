# 
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test checks the capability of the workflow to specify the character 
# in the names of the various grid and orography files that comes after 
# the C-resolution via the workflow parameter DOT_OR_USCORE, e.g.
#
#   C403${DOT_OR_USCORE}grid.tile7.halo4.nc
#
# This character is by default an underscore, but for consistency with
# the rest of the separators in the file name (as well as with the 
# character after the C-resolution in the names of the surface climatology 
# files), it should be a "." (a dot).  The MAKE_GRID_TN and MAKE_OROG_TN
# tasks will name the grid and orography files that they create using 
# this character.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

CCPP_PHYS_SUITE="FV3_GFS_2017_gfdlmp"

FCST_LEN_HRS="06"
LBC_SPEC_INTVL_HRS="6"

DATE_FIRST_CYCL="20190520"
DATE_LAST_CYCL="20190520"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="GSMGFS"
EXTRN_MDL_NAME_LBCS="GSMGFS"
USE_USER_STAGED_EXTRN_FILES="TRUE"

DOT_OR_USCORE="."
