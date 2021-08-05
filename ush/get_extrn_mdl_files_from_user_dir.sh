#
#-----------------------------------------------------------------------
#
# This file defines a function that creates symlinks in the current 
# cycle's external model file staging directory (staging_dir) to a set 
# of user-specified external model files (fns) in a user-specified 
# directory (user_dir).
#
#-----------------------------------------------------------------------
#
function get_extrn_mdl_files_from_user_dir() {
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
    "ics_or_lbcs" \
    "cdate" \
    "staging_dir" \
    "outvarname_fns" \
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
  print_input_args "valid_args"
#
#-----------------------------------------------------------------------
#
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local fn \
        __fns \
        fns_str \
        fp \
        fps \
        i \
        num_files \
        prefix \
        user_dir
#
#-----------------------------------------------------------------------
#
# Set the user directory in which the external model files are located 
# (user_dir), the names of the files (__fns), and the full paths to the 
# files.
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    user_dir="${EXTRN_MDL_SOURCE_BASEDIR_ICS}/$cdate"
    __fns=( $( printf "%s " "${EXTRN_MDL_FILES_ICS[@]}" ))
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    user_dir="${EXTRN_MDL_SOURCE_BASEDIR_LBCS}/$cdate"
    __fns=( $( printf "%s " "${EXTRN_MDL_FILES_LBCS[@]}" ))
  fi
  fns_str="( "$( printf "\"%s\" " "${__fns[@]}" )")"

  if [ ! -d "${user_dir}" ]; then
    print_info_msg "
The user-specified directory (user_dir) containing the user-specified
external model files (__fns) does not exist:
  user_dir = \"${user_dir}\"
  __fns = ${fns_str}
Returning with a nonzero return code.
"
    return 1
  fi

  prefix="${user_dir}/"
  fps=( "${__fns[@]/#/$prefix}" )
#
#-----------------------------------------------------------------------
#
# Loop through the list of external model files and create a symlink to
# each in the experiment's staging directory.  If any external file does
# not exist, return from this function with a nonzero return code.
#
#-----------------------------------------------------------------------
#
  print_info_msg "
Creating symlinks in the staging directory (staging_dir) to the external 
model files on disk (__fns) in the source directory (user_dir):
  user_dir = \"${user_dir}\"
  __fns = ${fns_str}
  staging_dir = \"${staging_dir}\"
"

  num_files="${#fps[@]}"
  for (( i=0; i<${num_files}; i++ )); do

    fn="${__fns[$i]}"
    fp="${fps[$i]}"

    if [ ! -f "$fp" ]; then
      print_info_msg "
The external model file fp is not a regular file (probably because it
does not exist):
  fp = \"$fp\"
Returning with a nonzero return code.
"
      return 1
    fi
#
# Create a symlink in the staging directory to the current file.
#
    create_symlink_to_file target="$fp" \
                           symlink="${staging_dir}/$fn" \
                           relative="FALSE"

  done
#
#-----------------------------------------------------------------------
#
# Use the eval function to set the output variables.  Note that each of
# these is set only if the corresponding input variable specifying the
# name to use for the output variable is not empty.
#
#-----------------------------------------------------------------------
#
  if [ ! -z "${outvarname_fns}" ]; then
    eval ${outvarname_fns}=${fns_str}
  fi
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}
