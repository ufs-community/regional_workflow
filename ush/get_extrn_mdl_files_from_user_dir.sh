#
#-----------------------------------------------------------------------
#
# This file defines a function that
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
    "outvarname_fns_on_disk" \
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
  local fn \
        aaafns_on_disk \
        aaafns_on_disk_str \
        fp \
        fps_on_disk \
        i \
        num_files \
        prefix \
        source_dir
#
#-----------------------------------------------------------------------
#
# Set the elements of fps_on_disk to the full paths of the 
# external model files on disk.
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    source_dir="${EXTRN_MDL_SOURCE_BASEDIR_ICS}/$cdate"
    aaafns_on_disk=( $( printf "%s " "${EXTRN_MDL_FILES_ICS[@]}" ))
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    source_dir="${EXTRN_MDL_SOURCE_BASEDIR_LBCS}/$cdate"
    aaafns_on_disk=( $( printf "%s " "${EXTRN_MDL_FILES_LBCS[@]}" ))
  fi

  if [ ! -d "${source_dir}" ]; then
    print_info_msg "
The user-specified directory containing the user-staged external model 
files (source_dir) does not exist:
  source_dir = \"${source_dir}\"
Please ensure that the directory specified by source_dir exists and that 
all the files specified in the array aaafns_on_disk exist within it:
  source_dir = \"${source_dir}\"
  aaafns_on_disk = ( $( printf "\"%s\" " "${aaafns_on_disk[@]}" ))
Returning with a nonzero return code.
"
    return 1
  fi

  prefix="${source_dir}/"
  fps_on_disk=( "${aaafns_on_disk[@]/#/$prefix}" )
#
#-----------------------------------------------------------------------
#
# Loop through the list of external model files and create a symlink to
# each in the experiment's staging directory.  If any external file does
# not exist, return from this function with a nonzero return code.
#
#-----------------------------------------------------------------------
#
  aaafns_on_disk_str="( "$( printf "\"%s\" " "${aaafns_on_disk[@]}" )")"
  print_info_msg "
Creating symlinks in the staging directory (staging_dir) to the external 
model files on disk (aaafns_on_disk) in the source directory (source_dir):
  source_dir = \"${source_dir}\"
  aaafns_on_disk = ${aaafns_on_disk_str}
  staging_dir = \"${staging_dir}\"
"

  num_files="${#fps_on_disk[@]}"
  for (( i=0; i<${num_files}; i++ )); do

    fn="${aaafns_on_disk[$i]}"
    fp="${fps_on_disk[$i]}"

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
  if [ ! -z "${outvarname_fns_on_disk}" ]; then
    eval ${outvarname_fns_on_disk}=${aaafns_on_disk_str}
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

