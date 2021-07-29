#
#-----------------------------------------------------------------------
#
# This file defines a function that
#
#-----------------------------------------------------------------------
#
function get_extrn_mdl_files_from_nomads() {
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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "ccpp_phys_suite_fp" \
    "output_varname_sdf_uses_ruc_lsm" \
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
  local ruc_lsm_name \
        regex_search \
        ruc_lsm_name_or_null \
        sdf_uses_ruc_lsm
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
  print_info_msg "
========================================================================
getting data from online nomads data sources
========================================================================"
#
#-----------------------------------------------------------------------
#
# Set extrn_mdl_fps to the full paths within the archive files of the
# external model output files.
#
#-----------------------------------------------------------------------
#
  prefix=${extrn_mdl_arcvrel_dir:+${extrn_mdl_arcvrel_dir}/}
  extrn_mdl_fps=( "${extrn_mdl_fns_on_disk[@]/#/$prefix}" )

  extrn_mdl_fps_str="( "$( printf "\"%s\" " "${extrn_mdl_fps[@]}" )")"

  print_info_msg "
Getting external model files from nomads:
  extrn_mdl_fps= ${extrn_mdl_fps_str}"

  num_files_to_extract="${#extrn_mdl_fps[@]}"
  wget_LOG_FN="log.wget.txt"
  for (( nfile=0; nfile<${num_files_to_extract}; nfile++ )); do
    cp ../../../${extrn_mdl_fps[$nfile]} . || \
    print_err_msg_exit "\
    onlie file ${extrn_mdl_fps[$nfile]} not found."
  done
#
#-----------------------------------------------------------------------
#
# Set output variables.
#
#-----------------------------------------------------------------------
#
  eval ${output_varname_sdf_uses_ruc_lsm}="${sdf_uses_ruc_lsm}"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}

