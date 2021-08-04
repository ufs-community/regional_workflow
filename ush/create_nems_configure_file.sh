#
#-----------------------------------------------------------------------
#
# This file defines a function that creates a NEMS configuration file
# in the specified run directory.
#
#-----------------------------------------------------------------------
#
function create_nems_configure_file() {
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
  { save_shell_opts; set -u -x; } > /dev/null 2>&1
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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=(
run_dir \
dt_atmos \
  )
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
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local settings \
        model_config_fp
#
#-----------------------------------------------------------------------
#
# Create a NEMS configuration file in the specified run directory.
#
#-----------------------------------------------------------------------
#
  print_info_msg "$VERBOSE" "
Creating a NEMS configuration file (\"${NEMS_CONFIG_FN}\") in the specified
run directory (run_dir):
  run_dir = \"${run_dir}\""
#
#-----------------------------------------------------------------------
#
# Create a multiline variable that consists of a yaml-compliant string
# specifying the values that the jinja variables in the template 
# nems_configure file should be set to.
#
#-----------------------------------------------------------------------
#
  settings="\
  'dt_atmos': ${DT_ATMOS}"

  print_info_msg $VERBOSE "
The variable \"settings\" specifying values to be used in the \"${NEMS_CONFIG_FN}\"
file has been set as follows:
#-----------------------------------------------------------------------
settings =
$settings"
#
#-----------------------------------------------------------------------
#
# Call a python script to generate the experiment's actual MODEL_CONFIG_FN
# file from the template file.
#
#-----------------------------------------------------------------------
#
  nems_config_fp="${run_dir}/${NEMS_CONFIG_FN}"
  $USHDIR/fill_jinja_template.py -q \
                                 -u "${settings}" \
                                 -t ${NEMS_CONFIG_TMPL_FP} \
                                 -o ${nems_config_fp} || \
  print_err_msg_exit "\
Call to python script fill_jinja_template.py to create a \"${NEMS_CONFIG_FN}\"
file from a jinja2 template failed.  Parameters passed to this script are:
  Full path to template file:
    NEMS_CONFIG_TMPL_FP = \"${NEMS_CONFIG_TMPL_FP}\"
  Full path to output file:
    nems_config_fp = \"${nems_config_fp}\"
  Namelist settings specified on command line:
    settings =
$settings"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}

