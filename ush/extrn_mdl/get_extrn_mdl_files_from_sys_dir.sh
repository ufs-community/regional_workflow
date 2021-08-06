#
#-----------------------------------------------------------------------
#
# This file defines a function that either (1) creates symlinks in the 
# current cycle's external model file staging directory (staging_dir) to 
# the specified set of external model files (fns) in a system directory 
# (sys_dir) (if running in NCO mode) or (2) copies the external model 
# files to the staging directory (if running in community mode).
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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "ics_or_lbcs" \
    "cdate" \
    "extrn_mdl_name" \
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
  local fn \
        fns_str \
        fp \
        fps \
        hh \
        i \
        min_age \
        num_files \
        prefix \
        sys_dir \
        sys_subdir \
        sys_basedir \
        yyyymmdd
#
#-----------------------------------------------------------------------
#
# Set the base system directory (sys_basedir) that contains the date-
# dependent full system directory in which the external model files are 
# located.
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    sys_basedir="${EXTRN_MDL_SYS_BASEDIR_ICS}"
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    sys_basedir="${EXTRN_MDL_SYS_BASEDIR_LBCS}"
  fi

  if [ ! -d "${sys_basedir}" ]; then
    print_info_msg "
The system base directory (sys_basedir) in which to look for external 
model files does not exist or is not a directory:
  sys_basedir = \"${sys_basedir}\"
Returning with a nonzero return code.
"
    return 1
  fi
#
#-----------------------------------------------------------------------
#
# Extract from cdate the starting date without time (yyyymmdd) and the
# hour-of-day (hh) of the external model forecast.
#
#-----------------------------------------------------------------------
#
  parse_cdate \
    cdate="$cdate" \
    outvarname_yyyymmdd="yyyymmdd" \
    outvarname_hh="hh"
#
#-----------------------------------------------------------------------
#
# Set the subdirectory (sys_subdir) under the system base directory 
# (sys_basedir) in which the external model files are located.  Then set
# the full system directory (sys_dir).
#
#-----------------------------------------------------------------------
#
  if [ "${extrn_mdl_name}" = "FV3GFS" ]; then
    slash_atmos_or_null=""
    if [ "${cdate}" -ge "2021032100" ]; then
      slash_atmos_or_null="/atmos"
    fi
  fi

  sys_subdir=""
  case "$MACHINE" in

  "WCOSS_CRAY")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      sys_subdir="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
      ;;
    esac
    ;;

  "WCOSS_DELL_P3")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      sys_subdir="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
      ;;
    esac
    ;;

  "HERA")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      sys_subdir="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
      ;;
    esac
    ;;

  "JET")
    case "${extrn_mdl_name}" in
    "RAP")
      sys_subdir="${yyyymmdd}${hh}/postprd"
      ;;
    "HRRR")
      sys_subdir="${yyyymmdd}${hh}/postprd"
      ;;
    esac
    ;;

  "ODIN")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      sys_subdir="${yyyymmdd}"
      ;;
    esac
    ;;

  "CHEYENNE")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      sys_subdir="gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"
      ;;
    esac
    ;;

  esac

  if [ -z "${sys_subdir}" ]; then
    print_info_msg "
The subdirectroy (sys_subdir) under the system base directory (sys_basedir) 
in which to look for external model files has not been specified for this 
machine (MACHINE) and external model (extrn_mdl_name) combination:
  MACHINE = \"$MACHINE\"
  extrn_mdl_name = \"${extrn_mdl_name}\"
  sys_basedir = \"${sys_basedir}\"
  sys_subdir = \"${sys_subdir}\"
Returning with a nonzero return code.
"
    return 1
  fi

  sys_dir="${sys_basedir}/${sys_subdir}"
#
#-----------------------------------------------------------------------
#
# Set the array fps to the full paths of the external model files in the 
# system directory.
#
#-----------------------------------------------------------------------
#
  prefix="${sys_dir}/"
  fps=( "${fns[@]/#/$prefix}" )
#
#-----------------------------------------------------------------------
#
# Loop through the list of external model files and either create a 
# symlink in the staging directory to each (if running in NCO mode) or
# copy each to the current cycle's staging directory (if running in 
# community mode).
#
#-----------------------------------------------------------------------
#
  fns_str="( "$( printf "\"%s\" " "${fns[@]}" )")"
  if [ "${RUN_ENVIR}" = "nco" ]; then
    print_info_msg "
Creating symlinks in the current cycle's staging directory (staging_dir) 
to the external model files (fns) in the system directory (sys_dir):
  sys_dir = \"${sys_dir}\"
  fns = ${fns_str}
  staging_dir = \"${staging_dir}\"
"
  else
    print_info_msg "
Copying external model files on disk (fns) from the system directory 
(sys_dir) to the current cycle's staging directory (staging_dir):
  sys_dir = \"${sys_dir}\"
  fns = ${fns_str}
  staging_dir = \"${staging_dir}\"
"
  fi
#
# To ensure that the external model files are complete (i.e. not still
# being written to), we require that they be at least min_age minutes
# old.  Set this value.
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
# Link to or copy the current file.
#
    if [ "${RUN_ENVIR}" = "nco" ]; then
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
