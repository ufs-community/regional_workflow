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

This is the ex-script for the task that generates initial condition 
(IC), surface, and zeroth hour lateral boundary condition (LBC0) files 
for FV3 (in NetCDF format).
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
print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Set number of OpenMP threads
#
#-----------------------------------------------------------------------
#
export NUM_OMP_THREADS=1
#
#-----------------------------------------------------------------------
#
# Retrieve platform's parallel application launcher command.
#
#-----------------------------------------------------------------------
#
local PLAUNCH

get_platform_info \
    num_threads="${NUM_OMP_THREADS}" \
    varname_run_cmd="PLAUNCH"
#
#-----------------------------------------------------------------------
#
workdir="${CYCLE_DIR}/NEXUS"
mkdir_vrfy -p "$workdir"
cd_vrfy $workdir
#
#-----------------------------------------------------------------------
#
# Copy the NEXUS config files to the tmp directory  
#
#
cp_vrfy ${EXECDIR}/nexus ${workdir}
cp_vrfy ${EXECDIR}/../sorc/arl_nexus/config/cmaq/*.rc ${workdir}
cp_vrfy ${EXECDIR}/../sorc/arl_nexus/fix/grid_spec_C401.nc ${workdir}/grid_spec.nc

#
#-----------------------------------------------------------------------
#
# Get the starting year, month, day, and hour of the the external model
# run.
#
#-----------------------------------------------------------------------
#
cyc="00" #"${PDY:8:2}"
yyyymmdd="${PDY:0:8}"
start_date=$(date -d "$yyyymmdd" +"%Y%m%d")
mm=$(date -d "$yyyymmdd" +"%m")
# assume ending date is +24 hours for now
end_date=$(date -d "$yyyymmdd + $FCST_LEN_HRS hours" +"%Y%m%d")

#
#######################################################################
# This will be the section to set the datasets used in $workdir/NEXUS_Config.rc 
# All Datasets in that file need to be placed here as it will link the files 
# necessary to that folder.  In the future this will be done by a get_nexus_input 
# script
NEI2016="TRUE"
TIMEZONES="TRUE"
CEDS2014="FALSE"
CEDS2017="FALSE"
HTAP2010="FALSE"
MASKS="TRUE"

NEXUS_INPUT_BASE_DIR=/scratch2/NAGAPE/arl/Barry.Baker/emissions
########################################################################

#
#----------------------------------------------------------------------
# 
# modify time configuration file
#
cp_vrfy ${EXECDIR}/../sorc/arl_nexus/utils/python/nexus_time_parser.py .
echo ${start_date} ${end_date} ${cyc}
./nexus_time_parser.py -f ${workdir}/HEMCO_sa_Time.rc -s $start_date -e $end_date -c $cyc

#
#---------------------------------------------------------------------
#
# set the root directory to the temporary directory
#
cp_vrfy ${EXECDIR}/../sorc/arl_nexus/utils/python/nexus_root_parser.py .
./nexus_root_parser.py -f ${workdir}/NEXUS_Config.rc -d ${workdir}/inputs

#
#----------------------------------------------------------------------
# Get all the files needed (TEMPORARILY JUST COPY FROM THE DIRECTORY)
mkdir_vrfy -p ${workdir}/inputs
mkdir_vrfy -p ${workdir}/output
if [ ${NEI2016} == "TRUE" ]; then #NEI2016
    cp_vrfy ${EXECDIR}/../sorc/arl_nexus/utils/python/nexus_nei2016_linker.py .
    cp_vrfy ${EXECDIR}/../sorc/arl_nexus/utils/python/nexus_nei2016_control_tilefix.py .
    mkdir_vrfy -p ${workdir}/inputs/NEI2016v1
    mkdir_vrfy -p ${workdir}/inputs/NEI2016v1/v2020-07
    mkdir_vrfy -p ${workdir}/inputs/NEI2016v1/v2020-07/${mm}
    ./nexus_nei2016_linker.py --src_dir ${NEXUS_INPUT_BASE_DIR} --date ${yyyymmdd} --work_dir ${workdir}/inputs
    ./nexus_nei2016_control_tilefix.py -f NEXUS_Config.rc -d ${yyyymmdd}
fi

if [ ${TIMEZONES} == 'TRUE' ]; then # TIME ZONES
    cp_vrfy -r ${NEXUS_INPUT_BASE_DIR}/TIMEZONES ${workdir}/inputs
fi

if [ ${MASKS} == 'TRUE' ]; then # MASKS
    cp_vrfy -r ${NEXUS_INPUT_BASE_DIR}/MASKS ${workdir}/inputs
fi

#
#----------------------------------------------------------------------
#
# Execute NEXUS
#
${PLAUNCH} ${EXECDIR}/nexus -c NEXUS_Config.rc -r grid_spec.nc || \
print_err_msg_exit "\
Call to execute nexus standalone for the FV3SAR failed
"


#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
NEXUS has successfully generated emissions files in netcdf format!!!!

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
