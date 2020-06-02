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
function get_fcst_model_info() {
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
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
# local fcst_model_cfg_fp fcst_model_name cfg_property

# local valid_args=( \
#   "external_name", "build_dir", "build_cmd", "build_opt" \
# )
# process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script/function.  Note that these will be printed out only if VERBOSE
# is set to TRUE.
#
#-----------------------------------------------------------------------
#
# print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Check arguments.
#
#-----------------------------------------------------------------------
#
if [ 0 = 1 ]; then

  if [ $# -lt 3 ]; then

    print_err_msg_exit "
Incorrect number of arguments specified:

  Function name:  \"${func_name}\"
  Number of arguments specified:  $#

Usage:

  ${func_name} \
    fcst_model_cfg_fp \
    fcst_model_name   \ 
    property_name \
    [property_name1 property_name2 ...]

where the arguments are defined as follows:
 
  fcst_model_cfg_fp:
  Name of forecast model configuration file.

  fcst_model_name:
  Name of the forecast model.
 
  property_name:
  Name of property defined under the forecast model name in the forecast
  model configuration file. It is set to the property value on output.
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

  local fcst_model_cfg_fp fcst_model_name property_name cfg_property

  fcst_model_cfg_fp=$1

  if [ ! -r ${fcst_model_cfg_fp} ]; then
    print_err_msg_exit "\
The specified model configuration file does not exist: \"${fcst_model_cfg_fp}\""
  fi

  fcst_model_name=$2

  shift 2

#-----------------------------------------------------------------------
#
# Use the eval function to set values of output variables.
#
#-----------------------------------------------------------------------
#
  while [ $# -gt 0 ]
  do
    case "${1}" in
      external_name|externals_cfg|build_dir|build_cmd|build_opt|exec_path)
        property_name=$1
        cfg_property=$(\
          get_manage_externals_config_property \
          "${fcst_model_cfg_fp}" "${fcst_model_name}" "${property_name}" ) || \
          print_err_msg_exit "\
            Call to function get_manage_externals_config_property failed."
        eval ${1}=\"${cfg_property}\"
        shift
        ;;
      *)
        print_err_msg_exit "\
          Call to function ${func_name} failed - Invalid argument: ${1}"
        ;;
    esac
  done
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
