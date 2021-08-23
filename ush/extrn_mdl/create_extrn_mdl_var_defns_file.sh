#
#-----------------------------------------------------------------------
#
# This file defines a function that creates a variable definitions file 
# (in bash script syntax) and save in it the values of several external-
# model-associated variables that may be needed by downstream workflow 
# tasks.
#
#-----------------------------------------------------------------------
#
function create_extrn_mdl_var_defns_file() {
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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "extrn_mdl_var_defns_fp" \
    "ics_or_lbcs" \
    "extrn_mdl_cdate" \
    "extrn_mdl_staging_dir" \
    "extrn_mdl_fns" \
    "extrn_mdl_lbc_spec_fhrs"
    )
  process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script or function.  Note that these will be printed out only if an
# environment variable named VERBOSE exists and is set to TRUE.
#
#-----------------------------------------------------------------------
#
  print_input_args "valid_args"
#
#-----------------------------------------------------------------------
#
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local extrn_mdl_fns_str \
        extrn_mdl_lbc_spec_fhrs_str \
        settings 
#
#-----------------------------------------------------------------------
#
# If the external model variable definitions file already exists, delete 
# it.
#
#-----------------------------------------------------------------------
#
  check_for_preexist_dir_file "${extrn_mdl_var_defns_fp}" "delete"
#
#-----------------------------------------------------------------------
#
# Save the contents of the file in the variable "settings".
#
#-----------------------------------------------------------------------
#
  extrn_mdl_fns_str="( "$( printf "\"%s\" " "${extrn_mdl_fns[@]}" )")"

  settings="\
EXTRN_MDL_CDATE=\"${extrn_mdl_cdate}\"
EXTRN_MDL_STAGING_DIR=\"${extrn_mdl_staging_dir}\"
EXTRN_MDL_FNS=${extrn_mdl_fns_str}"
#
# If the external model files obtained above were for generating LBCS (as
# opposed to ICs), then add to the external model variable definitions
# file the array variable EXTRN_MDL_LBC_SPEC_FHRS containing the forecast
# hours at which the lateral boundary conditions are specified.
#
  if [ "${ics_or_lbcs}" = "LBCS" ]; then
    extrn_mdl_lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${extrn_mdl_lbc_spec_fhrs[@]}" )")"
    settings="$settings
EXTRN_MDL_LBC_SPEC_FHRS=${lbc_spec_fhrs_str}"
  fi
#
#-----------------------------------------------------------------------
#
# Write the contents of "settings" to file.
#
#-----------------------------------------------------------------------
#
  { cat << EOM >> "${extrn_mdl_var_defns_fp}"
$settings
EOM
  } || print_err_msg_exit "\
Heredoc (cat) command to create a variable definitions file associated
with the external model from which to generate ${ics_or_lbcs} returned with a
nonzero status.  The full path to this variable definitions file is:
  extrn_mdl_var_defns_fp = \"${extrn_mdl_var_defns_fp}\""
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script or 
# function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}
