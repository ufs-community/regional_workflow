#
#-----------------------------------------------------------------------
#
# This file defines a function that
#
#-----------------------------------------------------------------------
#
function set_extrn_mdl_filenames() {
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
    "varname_fns_on_disk" \
    "varname_fns_in_arcv" \
    )
#    "yyyymmdd" \
#    "yyyy" \
#    "mm" \
#    "dd" \
#    "hh" \
#    "mn" \
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
  local ruc_lsm_name \
        regex_search \
        ruc_lsm_name_or_null \
        sdf_uses_ruc_lsm
#
#-----------------------------------------------------------------------
#
# Extract from cdate the starting year, month, day, hour, and minute of
# the external model forecast.  [The minute (mn) will get set to "00" 
# since cdate does not contain minutes.]
#
#-----------------------------------------------------------------------
#
  parse_cdate \
    cdate="$cdate" \
    outvarname_yyyy="yyyy" \
    outvarname_mm="mm" \
    outvarname_dd="dd" \
    outvarname_hh="hh" \
    outvarname_mn="mn"
#
#-----------------------------------------------------------------------
#
# Set additional parameters needed in forming the names of the external
# model files only under certain circumstances.
#
#-----------------------------------------------------------------------
#
  if [ "${extrn_mdl_name}" = "RAP" ] || \
     [ "${extrn_mdl_name}" = "HRRR" ] || \
     [ "${extrn_mdl_name}" = "NAM" ] || \
     [ "${extrn_mdl_name}" = "FV3GFS" -a "${MACHINE}" = "JET" ]; then
#
# Get the Julian day-of-year of the starting date and time of the exter-
# nal model forecast.
#
    ddd=$( date --utc --date "${yyyy}-${mm}-${dd} ${hh}:${mn} UTC" "+%j" )
#
# Get the last two digits of the year of the starting date and time of
# the external model forecast.
#
    yy=${yyyy:2:4}

  fi
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
  case "${ics_or_lbcs}" in
#
#-----------------------------------------------------------------------
#
# Consider analysis files (possibly including surface files).
#
#-----------------------------------------------------------------------
#
  "ICS")

    fcst_hh="00"
    fcst_mn="00"

    case "${extrn_mdl_name}" in

    "GSMGFS")
#      fns=( "atm" "sfc" "nst" )
      fns=( "atm" "sfc" )
      prefix="gfs.t${hh}z."
      fns=( "${fns[@]/#/$prefix}" )
      suffix="anl.nemsio"
      fns_on_disk=( "${fns[@]/%/$suffix}" )
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      ;;

    "FV3GFS")

      fv3gfs_file_fmt="${FV3GFS_FILE_FMT_ICS}"

      if [ "${fv3gfs_file_fmt}" = "nemsio" ]; then

        fns=( "atm" "sfc" )
        suffix="anl.nemsio"
        fns=( "${fns[@]/%/$suffix}" )

# Set names of external files if searching on disk.
        if [ "${MACHINE}" = "JET" ]; then
          prefix="${yy}${ddd}${hh}00.gfs.t${hh}z."
        else
          prefix="gfs.t${hh}z."
        fi
        fns_on_disk=( "${fns[@]/#/$prefix}" )

# Set names of external files if searching in an archive file, e.g. from
# HPSS.
        prefix="gfs.t${hh}z."
        fns_in_arcv=( "${fns[@]/#/$prefix}" )

      elif [ "${fv3gfs_file_fmt}" = "grib2" ]; then

# GSK 12/16/2019:
# Turns out that the .f000 file contains certain necessary fields that
# are not in the .anl file, so switch to the former.
#        fns=( "gfs.t${hh}z.pgrb2.0p25.anl" )  # Get only 0.25 degree files for now.
#        fns=( "gfs.t${hh}z.pgrb2.0p25.f000" )  # Get only 0.25 degree files for now.
        fns_on_disk=( "gfs.t${hh}z.pgrb2.0p25.f000" )  # Get only 0.25 degree files for now.
        fns_in_arcv=( "gfs.t${hh}z.pgrb2.0p25.f000" )  # Get only 0.25 degree files for now.
     
      elif [ "${fv3gfs_file_fmt}" = "netcdf" ]; then
     
#
#This whole section needs to be set based on what is in HPSS. They are placeholders for now.
#

        fns=( "" "" )
        suffix=""
        fns=( "" )
       
# Set names of external files if searching on disk.
        if [ "${MACHINE}" = "JET" ]; then
          prefix=""
        else
          prefix=""
        fi
        fns_on_disk=( "" )

# Set names of external files if searching in an archive file, e.g. from
# HPSS.
        prefix=""
        fns_in_arcv=( "" )

        fns_on_disk_str="( "$( printf "\"%s\" " "${fns_on_disk[@]}")")"
        fns_in_arcv_str="( "$( printf "\"%s\" " "${fns_in_arcv[@]}")")"

        print_info_msg "
Fetching of external model files from NOAA HPSS is not yet supported for
this external model (extrn_mdl_name) and file format (fv3gfs_file_fmt)
combination:
  extrn_mdl_name = \"${extrn_mdl_name}\"
  fv3gfs_file_fmt = \"${fv3gfs_file_fmt}\"
Setting fns_on_disk and fns_in_arcv to arrays containing empty elements:
  fns_on_disk = ${fns_on_disk_str}
  fns_in_arcv = ${fns_in_arcv_str}
If USE_USER_STAGED_EXTRN_FILES is set to \"TRUE\", this will allow the
workflow to look for the external model files in a user-staged directory."

      fi
      ;;

    "RAP")
#
# Note that this is GSL RAPX data, not operational NCEP RAP data.  An option for the latter
# may be added in the future.
#
      if [ "${MACHINE}" = "JET" ]; then
        fns_on_disk=( "wrfnat_130_${fcst_hh}.grib2" )
      else
        fns_on_disk=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      fi
      fns_in_arcv=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      ;;

    "HRRR")
#
# Note that this is GSL HRRRX data, not operational NCEP HRRR data.  An option for the latter
# may be added in the future.
#
      if [ "${MACHINE}" = "JET" ]; then
        fns_on_disk=( "wrfnat_hrconus_${fcst_hh}.grib2" )
      else
        fns_on_disk=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      fi
      fns_in_arcv=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      ;;

    "NAM")
      fns=( "" )
      prefix="nam.t${hh}z.bgrdsfi${hh}"
      fns=( "${fns[@]/#/$prefix}" )
      suffix=".tm${hh}"
      fns_on_disk=( "${fns[@]/%/$suffix}" )
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      ;;

    *)
      print_err_msg_exit "\
The external model file names (either on disk or in archive files) have 
not yet been specified for this combination of external model (extrn_mdl_name) 
and ICs or LBCs (ics_or_lbcs):
  extrn_mdl_name = \"${extrn_mdl_name}\"
  ics_or_lbcs = \"${ics_or_lbcs}\""
      ;;

    esac
    ;;
#
#-----------------------------------------------------------------------
#
# Consider forecast files.
#
#-----------------------------------------------------------------------
#
  "LBCS")

    fcst_mn="00"

    case "${extrn_mdl_name}" in

    "GSMGFS")
      fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
      prefix="gfs.t${hh}z.atmf"
      fns=( "${fcst_hhh[@]/#/$prefix}" )
      suffix=".nemsio"
      fns_on_disk=( "${fns[@]/%/$suffix}" )
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      ;;

    "FV3GFS")

      fv3gfs_file_fmt="${FV3GFS_FILE_FMT_LBCS}"

      if [ "${fv3gfs_file_fmt}" = "nemsio" ]; then

        fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
        suffix=".nemsio"
        fns=( "${fcst_hhh[@]/%/$suffix}" )

        if [ "${MACHINE}" = "JET" ]; then
          prefix="${yy}${ddd}${hh}00.gfs.t${hh}z.atmf"
        else
          prefix="gfs.t${hh}z.atmf"
        fi
        fns_on_disk=( "${fns[@]/#/$prefix}" )

        prefix="gfs.t${hh}z.atmf"
        fns_in_arcv=( "${fns[@]/#/$prefix}" )

      elif [ "${fv3gfs_file_fmt}" = "grib2" ]; then

        fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
        prefix="gfs.t${hh}z.pgrb2.0p25.f"
        fns_on_disk=( "${fcst_hhh[@]/#/$prefix}" )
        fns_in_arcv=( "${fcst_hhh[@]/#/$prefix}" )


      elif [ "${fv3gfs_file_fmt}" = "netcdf" ]; then

        fcst_hhh=( "" )
        suffix=""
        fns=( "" )

        if [ "${MACHINE}" = "JET" ]; then
          prefix=""
        else
          prefix=""
        fi
        fns_on_disk=( "" )

        prefix=""
        fns_in_arcv=( "" )

        fns_on_disk_str="( "$( printf "\"%s\" " "${fns_on_disk[@]}")")"
        fns_in_arcv_str="( "$( printf "\"%s\" " "${fns_in_arcv[@]}")")"

        print_info_msg "
Fetching of external model files from NOAA HPSS is not yet supported for
this external model (extrn_mdl_name) and file format (fv3gfs_file_fmt)
combination:
  extrn_mdl_name = \"${extrn_mdl_name}\"
  fv3gfs_file_fmt = \"${fv3gfs_file_fmt}\"
Setting fns_on_disk and fns_in_arcv to arrays containing empty elements:
  fns_on_disk = ${fns_on_disk_str}
  fns_in_arcv = ${fns_in_arcv_str}
If USE_USER_STAGED_EXTRN_FILES is set to \"TRUE\", this will allow the
workflow to look for the external model files in a user-staged directory."

      fi
      ;;

    "RAP")
#
# Note that this is GSL RAPX data, not operational NCEP RAP data.  An option for the latter
# may be added in the future.
#
      fcst_hh=( $( printf "%02d " "${lbc_spec_fhrs[@]}" ) )

      if [ "${MACHINE}" = "JET" ]; then 
        prefix="wrfnat_130_"
        suffix=".grib2"
      else
        prefix="${yy}${ddd}${hh}${mn}"
        suffix="${fcst_mn}"
      fi
      fns_on_disk=( "${fcst_hh[@]/#/$prefix}" )
      fns_on_disk=( "${fns_on_disk[@]/%/$suffix}" )

      prefix="${yy}${ddd}${hh}${mn}"
      fns_in_arcv=( "${fcst_hh[@]/#/$prefix}" )
      suffix="${fcst_mn}"
      fns_in_arcv=( "${fns_in_arcv[@]/%/$suffix}" )
      ;;

    "HRRR")
#
# Note that this is GSL HRRRX data, not operational NCEP HRRR data.  An option for the latter
# may be added in the future.
#
      fcst_hh=( $( printf "%02d " "${lbc_spec_fhrs[@]}" ) )

      if [ "${MACHINE}" = "JET" ]; then
        prefix="wrfnat_hrconus_"
        suffix=".grib2"
      else
        prefix="${yy}${ddd}${hh}${mn}"
        suffix="${fcst_mn}"
      fi
      fns_on_disk=( "${fcst_hh[@]/#/$prefix}" )
      fns_on_disk=( "${fns_on_disk[@]/%/$suffix}" )

      prefix="${yy}${ddd}${hh}${mn}"
      fns_in_arcv=( "${fcst_hh[@]/#/$prefix}" )
      suffix="${fcst_mn}"
      fns_in_arcv=( "${fns_in_arcv[@]/%/$suffix}" )
      ;;

    "NAM")
      fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
      prefix="nam.t${hh}z.bgrdsf"
      fns=( "${fcst_hhh[@]/#/$prefix}" )
      suffix=""
      fns_on_disk=( "${fns[@]/%/$suffix}" )
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      ;;

    *)
      print_err_msg_exit "\
The external model file names have not yet been specified for this 
combination of external model (extrn_mdl_name) and ICs or LBCs 
(ics_or_lbcs):
  extrn_mdl_name = \"${extrn_mdl_name}\"
  ics_or_lbcs = \"${ics_or_lbcs}\""
      ;;

    esac
    ;;

  esac
#
#-----------------------------------------------------------------------
#
# Use the eval function to set the output variables.  Note that each of 
# these is set only if the corresponding input variable specifying the
# name to use for the output variable is not empty.
#
#-----------------------------------------------------------------------
#
  if [ ! -z "${varname_fns_on_disk}" ]; then
    fns_on_disk_str="( "$( printf "\"%s\" " "${fns_on_disk[@]}" )")"
    eval ${varname_fns_on_disk}=${fns_on_disk_str}
  fi

  if [ ! -z "${varname_fns_in_arcv}" ]; then
    fns_in_arcv_str="( "$( printf "\"%s\" " "${fns_in_arcv[@]}" )")"
    eval ${varname_fns_in_arcv}=${fns_in_arcv_str}
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


