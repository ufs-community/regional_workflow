#
#-----------------------------------------------------------------------
#
# This file defines a function that
#
#-----------------------------------------------------------------------
#
function get_extrn_mdl_files_from_sys_dir() {
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
    "extrn_mdl_fns_on_disk" \
    "extrn_mdl_source_dir" \
    "extrn_mdl_staging_dir" \
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
  local extrn_mdl_fns_on_disk_str \
        extrn_mdl_fps_on_disk \
        fp \
        prefix
#
#-----------------------------------------------------------------------
#
# Set the elements of extrn_mdl_fps_on_disk to the full paths of the 
# external model files on disk.
#
#-----------------------------------------------------------------------
#
  prefix="${extrn_mdl_source_dir}/"
  extrn_mdl_fps_on_disk=( "${extrn_mdl_fns_on_disk[@]/#/$prefix}" )
#
#-----------------------------------------------------------------------
#
# Loop through the list of external model files and either create a 
# symlink in the staging director to each (if running in NCO mode) or
# copy each to the experiment's staging directory (in community mode).
#
#-----------------------------------------------------------------------
#
  extrn_mdl_fns_on_disk_str="( "$( printf "\"%s\" " "${extrn_mdl_fns_on_disk[@]}" )")"
  if [ "${RUN_ENVIR}" = "nco" ]; then
    print_info_msg "
Creating symlinks in the staging directory (extrn_mdl_staging_dir) to
the external model files on disk (extrn_mdl_fns_on_disk) in the source
directory (extrn_mdl_source_dir):
  extrn_mdl_source_dir = \"${extrn_mdl_source_dir}\"
  extrn_mdl_fns_on_disk = ${extrn_mdl_fns_on_disk_str}
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
"
  else
    print_info_msg "
Copying external model files on disk (extrn_mdl_fns_on_disk) from the
source directory (extrn_mdl_source_dir) to the staging directory 
(extrn_mdl_staging_dir):
  extrn_mdl_source_dir = \"${extrn_mdl_source_dir}\"
  extrn_mdl_fns_on_disk = ${extrn_mdl_fns_on_disk_str}
  extrn_mdl_staging_dir = \"${extrn_mdl_staging_dir}\"
"
  fi
#
# To ensure that the external model files are complete (i.e. not still
# being written to), we require that they be at least min_age minutes
# old.  Set this value.
#
  min_age="5"  # Minimum file age, in minutes.

  num_extrn_mdl_files="${#extrn_mdl_fps_on_disk[@]}"
  for (( i=0; i<${num_extrn_mdl_files}; i++ )); do

    fn="${extrn_mdl_fns_on_disk[$i]}"
    fp="${extrn_mdl_source_dir}/$fn"

    if [ ! -f "$fp" ]; then
      print_info_msg "
The external model file fp is not a regular file:
  fp = \"$fp\"
This is likely because it does not exist, but it could also be for other
reasons.  Returning with a nonzero return code.
"
      return 1
    fi
#
# Check that the file found is at least min_age minutes old.  If not, 
# return with a nonzero return code.
#
    if [ ! $( find "$fp" -mmin +${min_age} ) ]; then
      print_info_msg "
The external modle file fp is younger than the minumum required age of 
min_age minutes:
  fp = \"$fp\"
  min_age = ${min_age} minutes
Returning with a nonzero return code.
"
      return 1
    fi
#
# Link to or copy the file.
#
    if [ "${RUN_ENVIR}" = "nco" ]; then
      ln_vrfy -sf "$fp" "${extrn_mdl_staging_dir}/$fn"  # This should be replaced with the function "create_symlink_to_file" after the PR for that goes in.
    else
      cp_vrfy "$fp" "${extrn_mdl_staging_dir}/$fn"  # This should be replaced with the function "create_symlink_to_file" after the PR for that goes in.
    fi

  done
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}

