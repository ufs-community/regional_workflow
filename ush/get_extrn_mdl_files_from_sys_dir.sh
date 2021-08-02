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
    "fns_on_disk" \
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
        fns_on_disk_str \
        fp \
        fps_on_disk \
        hh \
        i \
        min_age \
        num_files \
        prefix \
        source_dir \
        source_subdir \
        sysbasedir \
        yyyymmdd
#
#-----------------------------------------------------------------------
#
# Set the system directory (i.e. a directory on disk) in which the external
# model output files for the specified cycle date (cdate) may be located.
# Note that this will be used by the calling script only if the output
# files for the specified cdate actually exist at this location.  Otherwise,
# the files will be searched for on the mass store (HPSS).
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    sysbasedir="${EXTRN_MDL_SYSBASEDIR_ICS}"
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    sysbasedir="${EXTRN_MDL_SYSBASEDIR_LBCS}"
  fi

  if [ ! -d "$sysbasedir" ]; then
    print_info_msg "
The system base directory in which to look for external model files does
not exist or is not a directory:
  sysbasedir = \"$sysbasedir\"
Returning with a nonzero return code.
"
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
#
#
#-----------------------------------------------------------------------
#
  source_subdir=""
  case "$MACHINE" in

  "WCOSS_CRAY")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      source_subdir="gfs.${yyyymmdd}/${hh}/atmos"
      ;;
    esac
    ;;

  "WCOSS_DELL_P3")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      source_subdir="gfs.${yyyymmdd}/${hh}/atmos"
      ;;
    esac
    ;;

  "HERA")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      source_subdir="gfs.${yyyymmdd}/${hh}/atmos"
      ;;
    esac
    ;;

  "JET")
    case "${extrn_mdl_name}" in
    "RAP")
      source_subdir="${yyyymmdd}${hh}/postprd"
      ;;
    "HRRR")
      source_subdir="${yyyymmdd}${hh}/postprd"
      ;;
    esac
    ;;

  "ODIN")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      source_subdir="${yyyymmdd}"
      ;;
    esac
    ;;

  "CHEYENNE")
    case "${extrn_mdl_name}" in
    "FV3GFS")
      source_subdir="gfs.${yyyymmdd}/${hh}"
      ;;
    esac
    ;;

  esac

  if [ -z "${source_subdir}" ]; then
    print_info_msg "
The subdirectroy (source_subdir) under the system base directory (sysbasedir) 
in which to look for external model files has not been specified for this 
machine (MACHINE) and external model (extrn_mdl_name) combination:
  MACHINE = \"$MACHINE\"
  extrn_mdl_name = \"${extrn_mdl_name}\"
  sysbasedir = \"${sysbasedir}\"
  source_subdir = \"${source_subdir}\"
Returning with a nonzero return code.
"
  fi

  source_dir="${sysbasedir}/${source_subdir}"
#
#-----------------------------------------------------------------------
#
# Set the elements of fps_on_disk to the full paths of the 
# external model files on disk.
#
#-----------------------------------------------------------------------
#
  prefix="${source_dir}/"
  fps_on_disk=( "${fns_on_disk[@]/#/$prefix}" )
#
#-----------------------------------------------------------------------
#
# Loop through the list of external model files and either create a 
# symlink in the staging director to each (if running in NCO mode) or
# copy each to the experiment's staging directory (in community mode).
#
#-----------------------------------------------------------------------
#
  fns_on_disk_str="( "$( printf "\"%s\" " "${fns_on_disk[@]}" )")"
  if [ "${RUN_ENVIR}" = "nco" ]; then
    print_info_msg "
Creating symlinks in the staging directory (staging_dir) to the external 
model files on disk (fns_on_disk) in the source directory (source_dir):
  source_dir = \"${source_dir}\"
  fns_on_disk = ${fns_on_disk_str}
  staging_dir = \"${staging_dir}\"
"
  else
    print_info_msg "
Copying external model files on disk (fns_on_disk) from the
source directory (source_dir) to the staging directory 
(staging_dir):
  source_dir = \"${source_dir}\"
  fns_on_disk = ${fns_on_disk_str}
  staging_dir = \"${staging_dir}\"
"
  fi
#
# To ensure that the external model files are complete (i.e. not still
# being written to), we require that they be at least min_age minutes
# old.  Set this value.
#
  min_age="5"

  num_files="${#fps_on_disk[@]}"
  for (( i=0; i<${num_files}; i++ )); do

    fn="${fns_on_disk[$i]}"
    fp="${source_dir}/$fn"

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
# Link to or copy the file.
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


