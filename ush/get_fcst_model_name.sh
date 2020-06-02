#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions. 
#
#-----------------------------------------------------------------------
#
# . ${GLOBAL_VAR_DEFNS_FP}
# . $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# This file defines a function that is used to obtain information (e.g.
# output file names, system and mass store file and/or directory names)
# for a specified external model, analysis or forecast, and cycle date.
# See the usage statement below for this function should be called and
# the definitions of the input parameters.
# 
#-----------------------------------------------------------------------
#
function get_fcst_model_name() {
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
# Check arguments.
#
#-----------------------------------------------------------------------
#
if [ 0 = 1 ]; then

  if [ $# -lt 1 ]; then

    print_err_msg_exit "
Incorrect number of arguments specified:

  Function name:  \"${func_name}\"
  Number of arguments specified:  $#

Usage:

  ${func_name} \
    workflow_cfg_fp

where the arguments are defined as follows:
 
  workflow_cfg_fp:
  Name of workflow configuration file (config.sh)
"

  fi

fi

#
#-----------------------------------------------------------------------
#
# Declare additional local variables.  Note that all variables in this 
# function should be local.  The variables set by this function are not
# directly passed back to the calling script because that is not easily
# feasable in bash.  Instead, the calling script specifies a file in 
# which to store the output variables and their values.  The name of 
# of this file
#
#-----------------------------------------------------------------------

  local workflow_cfg_fp=$1

  if [ -r ${workflow_cfg_fp} ]; then
    . ${workflow_cfg_fp}
    printf "%s" "${FCST_MODEL}"
  else
    print_err_msg_exit "\
The specified workflow configuration file does not exist: \"${workflow_cfg_fp}\""
  fi
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1
}
