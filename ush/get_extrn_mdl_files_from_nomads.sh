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
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "extrn_mdl_name" \
    "cdate" \
    "staging_dir" \
    "arcvrel_dir" \
    "fns_in_arcv" \
    )
#    "arcv_fmt" \
#    "arcv_fns" \
#    "arcv_fps" \
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
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    fv3gfs_file_fmt="${FV3GFS_FILE_FMT_ICS}"
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    fv3gfs_file_fmt="${FV3GFS_FILE_FMT_LBCS}"
  fi

  if [ "${extrn_mdl_name}" = "FV3GFS" ]; then

    if [ "${fv3gfs_file_fmt}" != "grib2" ]; then
      print_info_msg "
Fetching of FV3GFS files of the specified format (FV3GFS_FILE_FMT) is
currently not available on NOMADS:
  FV3GFS_FILE_FMT = \"${FV3GFS_FILE_FMT}\"
Returning with a nonzero return code.
"
      return 1

    fi

  else

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
#
#
#-----------------------------------------------------------------------
#
  nomads_base_url="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"

  prefix="${nomads_base_url}/${arcvrel_dir}/"
  file_urls=( "${fns_in_arcv[@]/#/$prefix}" )

  num_files="${#file_urls[@]}"
  for (( i=0; i<${num_files}; i++ )); do

    file_url="${file_urls[$i]}"

    wget_log_fn="log.wget"                                             
    wget --continue \
         --directory-prefix="${staging_dir}" \
         --output-file="${staging_dir}/${wget_log_fn}" \
         "${file_url}" \ || \
      print_info_msg "
Fetching of file (file_url) from NOMADS failed:
  file_url = \"${file_url}\"
Returning with a nonzero return code.
"
      return 1

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

