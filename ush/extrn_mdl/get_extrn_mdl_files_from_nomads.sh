#
#-----------------------------------------------------------------------
#
# This file defines a function that fetches external model files from
# NOMADS (NOAA Operational Model Archive and Distribution System) and
# places them in the current cycle's external model file staging directory 
# (staging_dir).
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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "ics_or_lbcs" \
    "extrn_mdl_name" \
    "cdate" \
    "staging_dir" \
    "arcvrel_dir" \
    "fns_in_arcv" \
    )
  process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script/function.  Note that these will be printed out only if VERBOSE 
# is set to TRUE.
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
  local file_url \
        file_urls \
        fv3gfs_file_fmt \
        i \
        nomads_base_url \
        num_files \
        prefix \
        wget_log_fn
#
#-----------------------------------------------------------------------
#
# Currently, this script can fetch only FV3GFS files from NOMADS.  Check
# that the specified external model is FV3GFS.
#
#-----------------------------------------------------------------------
#
  if [ "${extrn_mdl_name}" != "FV3GFS" ]; then
    print_info_msg "
Files generated by the specified external model (extrn_mdl_name) are not
available on NOMADS:
  extrn_mdl_name = \"${extrn_mdl_name}\"
Returning with a nonzero return code.
"
    return 1
  fi
#
#-----------------------------------------------------------------------
#
# Set the format of the FV3GFS files.  Currently, the only supported 
# format is "grib2".
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    fv3gfs_file_fmt="${FV3GFS_FILE_FMT_ICS}"
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    fv3gfs_file_fmt="${FV3GFS_FILE_FMT_LBCS}"
  fi

  if [ "${fv3gfs_file_fmt}" != "grib2" ]; then
    print_info_msg "
Fetching of FV3GFS files of the specified format (fv3gfs_file_fmt) is
currently not available on NOMADS:
  fv3gfs_file_fmt = \"${fv3gfs_file_fmt}\"
Returning with a nonzero return code.
"
    return 1
  fi
#
#-----------------------------------------------------------------------
#
# Set the URLs to the external model files.
#
#-----------------------------------------------------------------------
#
# First, set the base URL for NOMADS. 
#
  nomads_base_url="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
#
# Now append to the NOMADS base URL the relative path to the files 
# specified by arcvrel_dir (which depends on the cycle date and time) to 
# get the full URL where the files are located.
#
  prefix="${nomads_base_url}/${arcvrel_dir}/"
#
# For clarity, replace any occurrences of the substring "/./" in prefix 
# with a single "/".
#
  prefix=$( printf "%s" "$prefix" | sed -r -e 's|/\./|/|g' )
#
# Finally, set the array containing the full URLs to each of the external
# model files.
#
  file_urls=( "${fns_in_arcv[@]/#/$prefix}" )
#
#-----------------------------------------------------------------------
#
# Loop through the file URLs and use the wget utility to get each file.
# The files will be placed in the directory specified by staging_dir.
#
#-----------------------------------------------------------------------
#
  num_files="${#file_urls[@]}"
  for (( i=0; i<${num_files}; i++ )); do

    file_url="${file_urls[$i]}"

    wget_log_fn="log.wget"                                             
    wget --continue \
         --directory-prefix="${staging_dir}" \
         --output-file="${staging_dir}/${wget_log_fn}" \
         "${file_url}" || { \
      print_info_msg "
Fetching of file (file_url) from NOMADS failed:
  file_url = \"${file_url}\"
Please check the log file (wget_log_fp) for details:
  wget_log_fp = \"${wget_log_fp}\"
Returning with a nonzero return code.
";
      return 1;
    }

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