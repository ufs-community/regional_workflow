#
#-----------------------------------------------------------------------
#
# This file defines and then calls a function that sets a secondary set
# of parameters needed by the various scripts that are called by the 
# FV3SAR rocoto community workflow.  This secondary set of parameters is 
# calculated using the primary set of user-defined parameters in the de-
# fault and custom experiment/workflow configuration scripts (whose file
# names are defined below).  This script then saves both sets of parame-
# ters in a global variable definitions file (really a bash script) in 
# the experiment directory.  This file then gets sourced by the various 
# scripts called by the tasks in the workflow.
#
#-----------------------------------------------------------------------
#
function setup_externals() {
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
local scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
local scrfunc_fn=$( basename "${scrfunc_fp}" )
local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
#cd_vrfy ${scrfunc_dir}
#
#-----------------------------------------------------------------------
#
# Source bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${scrfunc_dir}/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Source other necessary files.
#
#-----------------------------------------------------------------------
#
# . ./set_gridparams_GFDLgrid.sh
# . ./set_gridparams_JPgrid.sh
# . ./link_fix.sh
# . ./set_fix_filenames.sh
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
# Set the names of the default and local workflow/experiment configura-
# tion scripts.
#
#-----------------------------------------------------------------------
#
DEFAULT_EXPT_CONFIG_FN="${scrfunc_dir}/config_defaults.sh"
EXPT_CONFIG_FN="${scrfunc_dir}/config.sh"
FCST_MODEL_CFG_FP="conf/fcst_model.cfg"
#
#-----------------------------------------------------------------------
#
# Source the default configuration file containing default values for
# the experiment/workflow variables.
#
#-----------------------------------------------------------------------
#
. ${DEFAULT_EXPT_CONFIG_FN}
#
#-----------------------------------------------------------------------
#
# If a user-specified configuration file exists, source it.  This file
# contains user-specified values for a subset of the experiment/workflow 
# variables that override their default values.  Note that the user-
# specified configuration file is not tracked by the repository, whereas
# the default configuration file is tracked.
#
#-----------------------------------------------------------------------
#
if [ -f "${EXPT_CONFIG_FN}" ]; then
#
# We require that the variables being set in the user-specified configu-
# ration file have counterparts in the default configuration file.  This
# is so that we do not introduce new variables in the user-specified 
# configuration file without also officially introducing them in the de-
# fault configuration file.  Thus, before sourcing the user-specified 
# configuration file, we check that all variables in the user-specified
# configuration file are also assigned default values in the default 
# configuration file.
#
  . ${scrfunc_dir}/compare_config_scripts.sh
#
# Now source the user-specified configuration file.
#
  . ${EXPT_CONFIG_FN}
#
fi


externals_cfg=
get_fcst_model_info ${FCST_MODEL_CFG_FP} ${FCST_MODEL} externals_cfg
externals_cfg="conf/${externals_cfg}"

if [ -r "${externals_cfg}" ] ; then
  cp_vrfy ${externals_cfg} Externals.cfg
else
  print_err_msg_exit "\
    Configuration file \"${externals_cfg}\" not found
    for model \"${FCST_MODEL}\""
fi

#
#-----------------------------------------------------------------------
#
# Source the script defining the valid values of experiment variables.
#
#-----------------------------------------------------------------------
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Setup externals completed successfully!!!
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the start of this script/function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

}
