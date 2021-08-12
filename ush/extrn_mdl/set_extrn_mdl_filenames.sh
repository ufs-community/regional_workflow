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
    "data_src" \
    "extrn_mdl_name" \
    "file_naming_convention" \
    "ics_or_lbcs" \
    "cdate" \
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
  print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local dd \
        ddd \
        fcst_hh \
        fcst_hhh \
        fcst_mn \
        fns \
        fns_str \
        fv3gfs_file_fmt \
        hh \
        mm \
        mn \
        prefix \
        suffix \
        yy \
        yyyy \
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
  if [ "${file_naming_convention}" = "extrn_mdl" ]; then

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
#        fns=( "atm" "sfc" "nst" )
        fns=( "atm" "sfc" )
        prefix="gfs.t${hh}z."
        fns=( "${fns[@]/#/$prefix}" )
        suffix="anl.nemsio"
        fns=( "${fns[@]/%/$suffix}" )
        ;;

      "FV3GFS")

        fv3gfs_file_fmt="${FV3GFS_FILE_FMT_ICS}"

        if [ "${fv3gfs_file_fmt}" = "nemsio" ]; then

          fns=( "atm" "sfc" )
          if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
            prefix="${yy}${ddd}${hh}00.gfs.t${hh}z."
          else
            prefix="gfs.t${hh}z."
          fi
          fns=( "${fns[@]/#/$prefix}" )

          suffix="anl.nemsio"
          fns=( "${fns[@]/%/$suffix}" )

        elif [ "${fv3gfs_file_fmt}" = "grib2" ]; then

# GSK 12/16/2019:
# Turns out that the .f000 file contains certain necessary fields that
# are not in the .anl file, so switch to the former.
#          fns=( "gfs.t${hh}z.pgrb2.0p25.anl" )  # Get only 0.25 degree files for now.
          fns=( "gfs.t${hh}z.pgrb2.0p25.f000" )  # Get only 0.25 degree files for now.

        elif [ "${fv3gfs_file_fmt}" = "netcdf" ]; then

          fns=( "atm" "sfc" )
          if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
            prefix="${yy}${ddd}${hh}00.gfs.t${hh}z."
          else
            prefix="gfs.t${hh}z."
          fi
          fns=( "${fns[@]/#/$prefix}" )

          suffix="anl.nc"
          fns=( "${fns[@]/%/$suffix}" )

        fi
        ;;

      "RAP")
#
# Note that this is GSL RAPX data, not operational NCEP RAP data.  An
# option for the latter may be added in the future.
#
        if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
          fns=( "wrfnat_130_${fcst_hh}.grib2" )
        else
          fns=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
        fi
        ;;

      "HRRR")
#
# Note that this is GSL HRRRX data, not operational NCEP HRRR data.  An
# option for the latter may be added in the future.
#
        if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
          fns=( "wrfnat_hrconus_${fcst_hh}.grib2" )
        else
          fns=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
        fi
        ;;

      "NAM")
        fns=( "" )
        prefix="nam.t${hh}z.bgrdsfi${hh}"
        fns=( "${fns[@]/#/$prefix}" )
        suffix=".tm${hh}"
        fns=( "${fns[@]/%/$suffix}" )
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

      fcst_hh=( $( printf "%02d " "${lbc_spec_fhrs[@]}" ) )
      fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
      fcst_mn="00"

      case "${extrn_mdl_name}" in

      "GSMGFS")
        prefix="gfs.t${hh}z.atmf"
        fns=( "${fcst_hhh[@]/#/$prefix}" )
        suffix=".nemsio"
        fns=( "${fns[@]/%/$suffix}" )
        ;;

      "FV3GFS")

        fv3gfs_file_fmt="${FV3GFS_FILE_FMT_LBCS}"

        if [ "${fv3gfs_file_fmt}" = "nemsio" ]; then

          if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
            prefix="${yy}${ddd}${hh}00.gfs.t${hh}z.atmf"
          else
            prefix="gfs.t${hh}z.atmf"
          fi
          fns=( "${fcst_hhh[@]/#/$prefix}" )

          suffix=".nemsio"
          fns=( "${fns[@]/%/$suffix}" )

        elif [ "${fv3gfs_file_fmt}" = "grib2" ]; then

          prefix="gfs.t${hh}z.pgrb2.0p25.f"
          fns=( "${fcst_hhh[@]/#/$prefix}" )

        elif [ "${fv3gfs_file_fmt}" = "netcdf" ]; then

          if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
            prefix="${yy}${ddd}${hh}00.gfs.t${hh}z.atmf"
          else
            prefix="gfs.t${hh}z.atmf"
          fi
          fns=( "${fcst_hhh[@]/#/$prefix}" )

          suffix=".nc"
          fns=( "${fns[@]/%/$suffix}" )

        fi
        ;;

      "RAP")
#
# Note that this is GSL RAPX data, not operational NCEP RAP data.  An
# option for the latter may be added in the future.
#
        if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
          prefix="wrfnat_130_"
          suffix=".grib2"
        else
          prefix="${yy}${ddd}${hh}${mn}"
          suffix="${fcst_mn}"
        fi
        fns=( "${fcst_hh[@]/#/$prefix}" )
        fns=( "${fns[@]/%/$suffix}" )
        ;;

      "HRRR")
#
# Note that this is GSL HRRRX data, not operational NCEP HRRR data.  An
# option for the latter may be added in the future.
#
        if [ "${MACHINE}" = "JET" ] && [ "${data_src}" = "disk" ]; then
          prefix="wrfnat_hrconus_"
          suffix=".grib2"
        else
          prefix="${yy}${ddd}${hh}${mn}"
          suffix="${fcst_mn}"
        fi
        fns=( "${fcst_hh[@]/#/$prefix}" )
        fns=( "${fns[@]/%/$suffix}" )
        ;;

      "NAM")
        prefix="nam.t${hh}z.bgrdsf"
        fns=( "${fcst_hhh[@]/#/$prefix}" )
        suffix=""
        fns=( "${fns[@]/%/$suffix}" )
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
#
#
#-----------------------------------------------------------------------
#
  elif [ "${file_naming_convention}" = "user_spec" ]; then

    if [ "${ics_or_lbcs}" = "ICS" ]; then
      fns=( $( printf "%s " "${EXTRN_MDL_FNS_ICS[@]}" ))
    elif [ "${ics_or_lbcs}" = "LBCS" ]; then
      fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
      fns=( "${fcst_hhh[@]/#/${EXTRN_MDL_FNS_LBCS_PREFIX}}" )
      fns=( "${fns[@]/%/${EXTRN_MDL_FNS_LBCS_SUFFIX}}" )
    fi

  fi
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
    fns_str="( "$( printf "\"%s\" " "${fns[@]}" )")"
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
