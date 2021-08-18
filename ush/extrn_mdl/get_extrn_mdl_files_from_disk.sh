#
#-----------------------------------------------------------------------
#
# This file defines a function that does one of the following:
#
# 1) If running in NCO mode (RUN_ENVIR set to "nco") or if using a user-
#    specified directory and file layout for the external model files
#    (EXTRN_MDL_DIR_FILE_LAYOUT set to "user_spec"), creates symlinks in 
#    the current cycle's external model file staging directory (staging_dir) 
#    to the specified set of external model files (fns) in a specified 
#    directory (extrn_mdl_dir).
#
# 2) If running in community mode (RUN_ENVIR set to "community") and not
#    using a user-specified and file layout for the external model files
#    (EXTRN_MDL_DIR_FILE_LAYOUT not set to "user_spec"), copies the 
#    external model files to the staging directory.
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
        basedir_next \
        basedirs \
        basedirs_str \
        extrn_mdl_dir \
        fn \
        fns_str \
        fp \
        fps \
        hh \
        i \
        j \
        jp1 \
        min_file_age \
        msg \
        num_basedirs \
        num_files \
        num_files_obtained \
        prefix \
        rc \
        rel_path \
        slash_atmos_or_null \
        yyyymmdd
#
#-----------------------------------------------------------------------
#
# Set the array basedirs containing the set of base directories that may
# contain the external model files.  Here, by base directory, we mean the
# beginning cycle-independent portion of the full path to the directory 
# containing the external model files.  Below, we will try each base
# directory specified in this array until we find one that contains the
# files.
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    basedirs=( "${EXTRN_MDL_BASEDIRS_ICS[@]:-}" )
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    basedirs=( "${EXTRN_MDL_BASEDIRS_LBCS[@]:-}" )
  fi

  basedirs_str="( "$( printf "\"%s\" " "${basedirs[@]}" )")"
  num_basedirs="${#basedirs[@]}"
  if [ ${num_basedirs} -eq 0 ]; then
    print_info_msg "
The array containing base directories (basedirs) in which to look for 
external model files is empty:
  basedirs = ${basedirs_str}
Returning with a nonzero return code.
"
    return 1
  fi
#
#-----------------------------------------------------------------------
#
# Set the relative path (rel_path) in which to search for external model
# files.  The relative path is the cycle-dependent portion of the full 
# path to the directory containing the files.  This relative path will 
# be appended to each base directory in basedirs and the resulting full 
# directory searched for the files until the files are found (or until
# we run out of base directories to try).
#
# There are two ways in which the relative path may be set.  Which is 
# used depends on the value of EXTRN_MDL_DIR_FILE_LAYOUT as follows:
#
# 1) If EXTRN_MDL_DIR_FILE_LAYOUT is set to "native_to_extrn_mdl", the
#    assumed directory structure is the one that is native to the external 
#    model (in which there may be multiple levels of subdirectories under 
#    the base directory).
#
# 2) If EXTRN_MDL_DIR_FILE_LAYOUT is set to "user_spec", the assumed 
#    directory structure is such that the external model files are located 
#    directly under a subdirectory named after the cycle date in the 
#    format "YYYYMMDDHH".
#
# In the first case, the way rel_path is set is machine-dependent because
# we attempt here to use the same directory structure as the one used in
# the system directory on the current machine in which the files from a 
# given external model are stored (if such a system directory exists at
# all on the machine).  Since different machines may use different 
# directory structures for the same model, the relative path is in 
# general machine dependent.  In addition, since some machines won't 
# contain system directories for certain models, rel_path may remain set
# below to its default value of a null string.
#
#-----------------------------------------------------------------------
#
  if [ "${EXTRN_MDL_DIR_FILE_LAYOUT}" = "native_to_extrn_mdl" ]; then

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

    rel_path=""
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

  elif [ "${EXTRN_MDL_DIR_FILE_LAYOUT}" = "user_spec" ]; then

    rel_path="$cdate"

  fi
#
#-----------------------------------------------------------------------
#
# In NCO mode, to ensure that the external model files are complete (i.e.
# not still being written to), we require that they be at least min_file_age
# minutes old.  Set this value.
#
#-----------------------------------------------------------------------
#
  min_file_age="5"
#
#-----------------------------------------------------------------------
#
# Loop through the base directories in basedirs.  For each one, append
# the relative path to obtain a full path and try to obtain the external
# model files from the directory represented by that path.
#
#-----------------------------------------------------------------------
#
# Initialize the return code from this function to a non-zero value.
# This will be reset to zero only after all the files have been obtained
# successfully.
#
  rc=1

  for (( j=0; j<${num_basedirs}; j++ )); do

    basedir="${basedirs[$j]}"
#
# Define quantities that may be needed below in error messages.
#
    basedir_next=""
    jp1=$((j+1))
    if [ $jp1 -ne ${num_basedirs} ]; then
      basedir_next="${basedirs[$jp1]}"
    fi
#
# Check if the current base directory is actually a directory, e.g. 
# whether it exists at all.
#
    if [ ! -d "$basedir" ]; then
      msg="
The base directory (basedir) in which to look for external model files
does not exist or is not a directory:
  basedir = \"$basedir\""
      if [ ! -z "${basedir_next}" ]; then
        msg=$msg"
Skipping to next base directory (basedir_next) in basedirs:
  basedirs = ${basedirs_str}
  basedir_next = \"${basedir_next}\"
"
      fi
      print_info_msg "$msg"
      continue
    fi
#
# Append the relative path to the base directory to obtain the full path
# to the directory containing the external model files (for the current
# cycle).  Then check that the resulting full directory exists.
#
    extrn_mdl_dir="$basedir/${rel_path}"
    if [ ! -d "${extrn_mdl_dir}" ]; then
      msg="
The directory (extrn_mdl_dir) that should contain the external model 
files for the current cycle does not exist or is not a directory:
  extrn_mdl_dir = \"${extrn_mdl_dir}\""
      if [ ! -z "${basedir_next}" ]; then
        msg=$msg"
Skipping to next base directory (basedir_next) in basedirs:
  basedirs = ${basedirs_str}
  basedir_next = \"${basedir_next}\"
"
      fi
      print_info_msg "$msg"
      continue
    fi
#
# Set the array fps containing the full paths of all the external model 
# files to be obtained.
#
    prefix="${extrn_mdl_dir}/"
    fps=( "${fns[@]/#/$prefix}" )
#
# Loop through the list of external model files and either create a
# symlink in the staging directory to each (if running in NCO mode or if
# using a user-specified directory and file layout) or copy each to the
# current cycle's staging directory (if running in community mode and 
# not using a user-specified directory and file layout).  In the latter 
# case, the files are usually in a system directory and are available 
# for only a few days.  By copying the files, we ensure that they will 
# be available later, e.g. for rerunning the experiment.
#
    fns_str="( "$( printf "\"%s\" " "${fns[@]}" )")"
    if [ "${RUN_ENVIR}" = "nco" ] || \
       [ "${EXTRN_MDL_DIR_FILE_LAYOUT}" = "user_spec" ]; then
      print_info_msg "
Attempting to create symlinks in the current cycle's staging directory 
(staging_dir) to the specified files (fns) in the external model directory 
(extrn_mdl_dir):
  extrn_mdl_dir = \"${extrn_mdl_dir}\"
  fns = ${fns_str}
  staging_dir = \"${staging_dir}\"
"
    elif [ "${EXTRN_MDL_DIR_FILE_LAYOUT}" = "native_to_extrn_mdl" ]; then
      print_info_msg "
Attempting to copy the specified files (fns) from the external model 
directory (extrn_mdl_dir) to the current cycle's staging directory 
(staging_dir):
  extrn_mdl_dir = \"${extrn_mdl_dir}\"
  fns = ${fns_str}
  staging_dir = \"${staging_dir}\"
"
    fi
#
# Loop through the set of files and try to obtain (copy or link to) each
# one.
#
    num_files_obtained=0
    num_files="${#fps[@]}"
    for (( i=0; i<${num_files}; i++ )); do

      fn="${fns[$i]}"
      fp="${fps[$i]}"

      if [ ! -f "$fp" ]; then
        msg="
The external model file (fp) is not a regular file, probably because it
does not exist:
  fp = \"$fp\""
        if [ ! -z "${basedir_next}" ]; then
          msg=$msg"
Skipping to next base directory (basedir_next) in basedirs:
  basedirs = ${basedirs_str}
  basedir_next = \"${basedir_next}\"
"
        fi
        print_info_msg "$msg"
        break
      fi
#
# If in NCO mode, check that the file found is at least min_file_age 
# minutes old.
#
      if [ "${RUN_ENVIR}" = "nco" ] && \
         [ ! $( find "$fp" -mmin +${min_file_age} ) ]; then
        print_info_msg "
In NCO mode, the external model file (fp) must be older than a minimum
value [min_file_age (in minutes), where file age is taken as the time 
elapsed since the last modification time] to ensure that the file is not 
still being written to, but the current file (fp) is younger:
  fp = \"$fp\"
  min_file_age = ${min_file_age} minutes"
        if [ ! -z "${basedir_next}" ]; then
          msg=$msg"
Skipping to next base directory (basedir_next) in basedirs:
  basedirs = ${basedirs_str}
  basedir_next = \"${basedir_next}\"
"
        fi
        print_info_msg "$msg"
        break
      fi
#
# Link to or copy the current file.
#
      if [ "${RUN_ENVIR}" = "nco" ] || \
         [ "${EXTRN_MDL_DIR_FILE_LAYOUT}" = "user_spec" ]; then
        print_info_msg "
Linking to file fn:
  fn = \"$fn\""
        create_symlink_to_file target="$fp" \
                               symlink="${staging_dir}/$fn" \
                               relative="FALSE"
      else
        print_info_msg "
Copying file fn:
  fn = \"$fn\""
        cp_vrfy "$fp" "${staging_dir}/$fn"
      fi
#
# Increment the counter that keeps track of the number of external model
# files that have been obtained (i.e. copied or linked to).
#
      num_files_obtained=$(( num_files_obtained+1 ))

    done
#
# If, after exiting the loop over the files, the number of files obtained 
# is equal to the total number of files, then all files were successfully 
# obtained.  In this case, reset the return code to 0 (in case it is 
# needed later below) and exit the loop over the base directories.
#
    if [ "${num_files_obtained}" -eq "${num_files}" ]; then
      rc=0
      break
    fi

  done
#
# If, after exiting the loops above, the return code is non-zero, it 
# means the files were not obtained succesfully from any of the base 
# directories.  In this case, return with the non-zero code.
#
  if [ "$rc" -ne "0" ]; then
    return "$rc"
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
