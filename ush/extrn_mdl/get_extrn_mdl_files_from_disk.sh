#
#-----------------------------------------------------------------------
#
# This file defines a function that either (1) creates symlinks in the
# current cycle's external model file staging directory (staging_dir) to
# the specified set of external model files (fns) in a specified directory
# (extrn_mdl_dir) (if running in NCO mode) or (2) copies the external model
# files to the staging directory (if running in community mode).
#
#-----------------------------------------------------------------------
#
function get_extrn_mdl_files_from_disk() {
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
    "extrn_mdl_name" \
    "file_naming_convention" \
    "ics_or_lbcs" \
    "cdate" \
    "staging_dir" \
    "fns" \
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
  local basedir \
        extrn_mdl_dir \
        fn \
        fns_str \
        fp \
        fps \
        hh \
        i \
        min_age \
        num_files \
        prefix \
        rel_path \
        slash_atmos_or_null \
        yyyymmdd
#
#-----------------------------------------------------------------------
#
# Set the base directory (basedir) containing the external model files.
# The base directory is the portion of the directory that is cycle-
# independent (the full directory containing the files is cycle-dependent).
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    basedir="${EXTRN_MDL_BASEDIR_ICS}"
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    basedir="${EXTRN_MDL_BASEDIR_LBCS}"
  fi

  if [ ! -d "${basedir}" ]; then
    print_info_msg "
The base directory (basedir) in which to look for external model files
does not exist or is not a directory:
  basedir = \"${basedir}\"
Returning with a nonzero return code.
"
    return 1
  fi
#
#-----------------------------------------------------------------------
#
# Set the relative path (rel_path) under the base directory (basedir) in
# which the external model files are located.  This relative path is the
# cycle-dependent portion of the full directory containing the files.
# How this is set depends on the assumed file naming convention.
#
# First, consider the case of a user-specified naming convention.  In
# this case, the files are located in a subdirectory with a name that is
# identical to cdate.  Thus, the relative path is just cdate.
#
#-----------------------------------------------------------------------
#
  rel_path=""

  if [ "${file_naming_convention}" = "user_spec" ]; then

    rel_path="$cdate"
#
#-----------------------------------------------------------------------
#
# Now consider the case of a naming convention that is identical to what
# the external model uses.  In this case, the relative path depends on
# the external model as well as the machine on which the experiment is
# running.  Note that rel_path is not defined for all machine and external 
# model combinations.  Thus, in certain cases, it may remain set to a null 
# string.  We will check for this later below.
#
#-----------------------------------------------------------------------
#
  elif [ "${file_naming_convention}" = "extrn_mdl" ]; then
#
# Extract from cdate the starting date without time (yyyymmdd) and the
# hour-of-day (hh) of the external model forecast.
#
    parse_cdate \
      cdate="$cdate" \
      outvarname_yyyymmdd="yyyymmdd" \
      outvarname_hh="hh"

    if [ "${extrn_mdl_name}" = "FV3GFS" ]; then
      slash_atmos_or_null=""
      if [ "${cdate}" -ge "2021032100" ]; then
        slash_atmos_or_null="/atmos"
      fi
    fi

    case "$MACHINE" in

    "WCOSS_CRAY")
      case "${extrn_mdl_name}" in
      "FV3GFS")
        rel_path="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
        ;;
      esac
      ;;

    "WCOSS_DELL_P3")
      case "${extrn_mdl_name}" in
      "FV3GFS")
        rel_path="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
        ;;
      esac
      ;;

    "HERA")
      case "${extrn_mdl_name}" in
      "FV3GFS")
        rel_path="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
        ;;
      esac
      ;;

    "JET")
      case "${extrn_mdl_name}" in
      "RAP")
        rel_path="${yyyymmdd}${hh}/postprd"
        ;;
      "HRRR")
        rel_path="${yyyymmdd}${hh}/postprd"
        ;;
      esac
      ;;

    "ODIN")
      case "${extrn_mdl_name}" in
      "FV3GFS")
        rel_path="${yyyymmdd}"
        ;;
      esac
      ;;

    "CHEYENNE")
      case "${extrn_mdl_name}" in
      "FV3GFS")
        rel_path="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
        ;;
      esac
      ;;

    esac
#
# If rel_path was not set for the current machine and external model 
# combination, the external model files cannot be obtained.  In this 
# case, print out an error message and return with a nonzero return 
# code.
#
    if [ -z "${rel_path}" ]; then
      print_info_msg "
The relative path (rel_path) under the base directory (basedir) in which
to look for external model files has not been specified for this machine
(MACHINE) and external model (extrn_mdl_name) combination:
  MACHINE = \"$MACHINE\"
  extrn_mdl_name = \"${extrn_mdl_name}\"
  basedir = \"${basedir}\"
  rel_path = \"${rel_path}\"
Returning with a nonzero return code.
"
      return 1
    fi

  fi
#
#-----------------------------------------------------------------------
#
# Append the relative path to the base directory to obtain the full path
# of the directory containing the external model files for the current
# cycle.  Then set the array fps to the full paths of the external model
# files.
#
#-----------------------------------------------------------------------
#
  extrn_mdl_dir="${basedir}/${rel_path}"
  prefix="${extrn_mdl_dir}/"
  fps=( "${fns[@]/#/$prefix}" )
#
#-----------------------------------------------------------------------
#
# Loop through the list of external model files and either create a
# symlink in the staging directory to each (if running in NCO mode or if
# using a user-specified file naming convention) or copy each to the 
# current cycle's staging directory (if running in community mode.  In
# the latter case, the files are usually in a system directory and are
# kept for only a few days.  By copying the files, they will be available
# later, e.g. for rerunning the experiment.
#
#-----------------------------------------------------------------------
#
  fns_str="( "$( printf "\"%s\" " "${fns[@]}" )")"
  if [ "${RUN_ENVIR}" = "nco" ] || \
     [ "${file_naming_convention}" = "user_spec" ]; then
    print_info_msg "
Creating symlinks in the current cycle's staging directory (staging_dir)
to the specified files (fns) in the external model directory (extrn_mdl_dir):
  extrn_mdl_dir = \"${extrn_mdl_dir}\"
  fns = ${fns_str}
  staging_dir = \"${staging_dir}\"
"
  else
    print_info_msg "
Copying the specified files (fns) from the external model directory
(extrn_mdl_dir) to the current cycle's staging directory (staging_dir):
  extrn_mdl_dir = \"${extrn_mdl_dir}\"
  fns = ${fns_str}
  staging_dir = \"${staging_dir}\"
"
  fi
#
# In NCO mode, to ensure that the external model files are complete (i.e. 
# not still being written to), we require that they be at least min_age 
# minutes old.  Set this value.
#
  min_age="5"

  num_files="${#fps[@]}"
  for (( i=0; i<${num_files}; i++ )); do

    fn="${fns[$i]}"
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
# Check that the file found is at least min_age minutes old.  If not,
# return with a nonzero return code.
#
    if [ "${RUN_ENVIR}" = "nco" ] && \
       [ ! $( find "$fp" -mmin +${min_age} ) ]; then
      print_info_msg "
In NCO mode, the external model file (fp) must be older than a minimum
value [min_age (in minutes), where file age is taken as the time elapsed
since the last modification time] to ensure that the file is not still 
being written to:
  fp = \"$fp\"
  min_age = ${min_age} minutes
The current file is younger than min_age minutes.  Returning with a 
nonzero return code.
"
      return 1
    fi
#
# Link to or copy the current file.
#
    if [ "${RUN_ENVIR}" = "nco" ] || \
       [ "${file_naming_convention}" = "user_spec" ]; then
      create_symlink_to_file target="$fp" \
                             symlink="${staging_dir}/$fn" \
                             relative="FALSE"
    else
      cp_vrfy "$fp" "${staging_dir}/$fn"
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
