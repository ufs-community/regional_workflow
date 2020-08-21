#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that copies/fetches to a local direc-
tory (either from disk or HPSS) the external model files from which ini-
tial or boundary condition files for the FV3 will be generated.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=()
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
#print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# We first check whether the external model output files exist on the 
# system disk (and are older than a certain age).  If so, we simply copy
# them from the system disk to the location specified by EXTRN_MDL_-
# FILES_DIR.  If not, we try to fetch them from HPSS.
#
# Start by setting EXTRN_MDL_FPS to the full paths that the external mo-
# del output files would have if they existed on the system disk.  Then
# count the number of such files that actually exist on disk (i.e. have
# not yet been scrubbed) and are older than a specified age (to make 
# sure that they are not still being written to).
#
#-----------------------------------------------------------------------
#
cyc="00" #"${PDY:8:2}"
yyyymmdd="${PDY:0:8}"
mm=$(date -d "$yyyymmdd" +"%m")

CHEM_BOUNDARY_CONDITION_FILE=gfs_bndy_chem_${mm}.tile7.000.nc

boundary_file_loc=/scratch2/NAGAPE/arl/Barry.Baker/boundary_conditions

FULL_CHEMICAL_BOUNDARY_FILE=${boundary_file_loc}/${CHEM_BOUNDARY_CONDITION_FILE}
if [ -f ${FULL_CHEMICAL_BOUNDARY_FILE} ]; then
    #Copy the boundary condition file to the current location
    cp ${FULL_CHEMICAL_BOUNDARY_FILE} .
else
    CHEM_BOUNDARY_CONDITION_FILE=LBCS/${CHEM_BOUNDARY_CONDITION_FILE}
    print_info_msg "
Fetching chemical lateral boundary condition filesfrom HPSS:
  AQM_ARCHIVE = ${AQM_ARCHIVE}
  CHEM_BOUNDARY_CONDITION_FILE = ${CHEM_BOUNDARY_CONDITION_FILE}
  "
    htar -xvf ${AQM_ARCHIVE} ${CHEM_BOUNDARY_CONDITION_FILE}
fi

for hr in 00 06 12 18 24; do
    ncks -A ${CHEM_BOUNDARY_CONDITION_FILE} ${CYCLE_DIR}/INPUT/gfs_bndy.tile7.0${hr}.nc
done
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
    print_info_msg "
========================================================================
Successfully copied or linked to external model files on system disk 
needed for generating initial conditions and surface fields for the FV3
forecast!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"

#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

