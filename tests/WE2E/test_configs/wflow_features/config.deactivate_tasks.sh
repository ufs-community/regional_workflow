#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test has two purposes:
#
# 1) It checks that the various workflow tasks can be deactivated, i.e. 
#    removed from the Rocoto XML.
# 2) It checks the capability of the workflow to use "template" experiment 
#    variables, i.e. variables whose definitions include references to 
#    other variables, e.g.
#
#      MY_VAR='\${ANOTHER_VAR}'
#
# Note that we do not deactivate all tasks in the workflow; we leave the 
# MAKE_GRID_TN, MAKE_OROG_TN, and MAKE_SFC_CLIMO_TN activated because:
#
# 1) There is already a WE2E test that runs with these three tasks
#    deactivated (that test is to ensure that pre-generated grid, 
#    orography, and surface climatology files can be used).
# 2) In checking the template variable capability, we want to make sure
#    that the variable defintions file (GLOBAL_VAR_DEFNS_FN) generated
#    does not have syntax or other errors in it by sourcing it in these 
#    three tasks.
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
CCPP_PHYS_SUITE="FV3_GFS_v15p2"

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"
USE_USER_STAGED_EXTRN_FILES="TRUE"

DATE_FIRST_CYCL="20190701"
DATE_LAST_CYCL="20190701"
CYCL_HRS=( "00" )

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="3"

RUN_TASK_GET_EXTRN_ICS="FALSE"
RUN_TASK_GET_EXTRN_LBCS="FALSE"
RUN_TASK_MAKE_ICS="FALSE"
RUN_TASK_MAKE_LBCS="FALSE"
RUN_TASK_RUN_FCST="FALSE"
RUN_TASK_RUN_POST="FALSE"
#
# The following shows examples of how to define template variables.  Here,
# we define RUN_CMD_UTILS, RUN_CMD_FCST, and RUN_CMD_POST as template 
# variables.  Note that these variables aren't actually needed to run
# any commands but are simply included for demonstration purposes.
#
# If we want the contents in RUN_CMD_UTILS, RUN_CMD_FCST, and RUN_CMD_POST 
# to be expanded and/or executed when the variable definitions file 
# (GLOBAL_VAR_DEFNS_FN) is sourced in a script or function, then we must
# escape bash's variable reference character "$" using backslashes, as 
# follows:
#
#   RUN_CMD_UTILS="echo \$yyyymmdd"
#   RUN_CMD_FCST="mpirun -np \${PE_MEMBER01}"
#   RUN_CMD_POST="\$( echo hello \$yyymmdd )"
#
# With this method, when the variable defintions file is sourced, the 
# variable references on the right-hand sides (here $yyyymmdd and 
# ${PE_MEMBER01}) as well as the command substitution [i.e. $( echo ...)]
# will first be evaluated/expanded and the results then combined with 
# the remainder of each string on the right-hand side (if any) to obtain 
# literal strings to assign to RUN_CMD_UTILS, RUN_CMD_FCST, and RUN_CMD_POST.  
# Thus, the values that these three variables are assigned in the variable
# definitions file will not contain any variable references; they will
# contain only literal strings.
#
# In general, this is not what we want because the variables on the right-
# hand sides may not yet be defined at the time the variable definitions
# file is sourced.  Thus, what we usually want is for variable references
# and command substitutions appearing on the right-hand sides in that 
# file to be escaped.  To do this, we must escape the "$" character twice, 
# as follows:
#
#   RUN_CMD_UTILS="echo \\\$yyyymmdd"
#   RUN_CMD_FCST="mpirun -np \\\${PE_MEMBER01}"
#   RUN_CMD_POST="\\\$( echo hello \\\$yyyymmdd )"
#
# A more compact way to do this is to use single quotes on the outside
# and eliminate the escaped-\ within, i.e.
#
#   RUN_CMD_UTILS='echo \$yyyymmdd'
#   RUN_CMD_FCST='mpirun -np \${PE_MEMBER01}'
#   RUN_CMD_POST='\$( echo hello \$yyyymmdd )'
#
# This will cause $yyyymmdd, ${PE_MEMBER01}, and $(...) to be expanded
# only at the time RUN_CMD_UTILS, RUN_CMD_FCST, and RUN_CMD_POST are 
# referenced in a file or script (using the syntax ${RUN_CMD_UTILS}, ...)
# and not earlier when the variable definitions file is sourced.  That
# is what we do in this WE2E test.
#
# With the last set of settings above, in a given script or function we 
# can source the variable defintions file and then use the three variables 
# as follows:
#
#   . $exptdir/var_defns.sh
#   yyyymmdd="goodbye"
#   eval ${RUN_CMD_UTILS}
#   eval ${RUN_CMD_FCST}
#   eval myvar=${RUN_CMD_POST}
#
# (The mpirun command in RUN_CMD_FCST will generate an error, but that is
# ok since using mpirun is not the primary concern here.)
#
RUN_CMD_UTILS='echo \$yyyymmdd'
RUN_CMD_FCST='mpirun -np \${PE_MEMBER01}'
RUN_CMD_POST='\$( echo hello \$yyyymmdd )'
