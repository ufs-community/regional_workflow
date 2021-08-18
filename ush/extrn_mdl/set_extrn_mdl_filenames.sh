#
#-----------------------------------------------------------------------
#
# This file defines a function that sets and returns the set of external
# model file names that are to be obtained (copied from disk, linked to,
# fetched from a URL, etc).  The way these are set depends on:
#
# 1) The data source (data_src) from which the files are to be obtained.
#
# 2) The directory structure and file naming convention assumed for the
#    external model (EXTRN_MDL_DIR_FILE_LAYOUT).
#
# 3) The external model (extrn_mdl_name) for which to obtain the files.
#
# 4) Whether the files obtained will be used to generate initial or 
#    lateral boundary conditions for the FV3LAM (ics_or_lbcs).
#
# 5) The starting date and hour of the external model forecast (cdate)
#    for which the files will be obtained.  Note that this will usually 
#    correspond to the starting date and time of the FV3GFS forecast for 
#    which ICs and LBCs will be generated, but this is not always the 
#    case.  For example, when using RAP model output to generate LBCs
#    for the FV3LAM, the staring time of the RAP forecast is set back 6 
#    hours relative to the FV3LAM forecast.
#
# Note that for simplicity, this function first sets the file names for
# all three of the following possibilities:
#
# 1) File names in an archive file located on NOAA HPSS or file names on
#    NOMADS (i.e. data_src set to "noaa_hpss" or "nomads"; they use the 
#    same names).  For these possibilities, the file names are stored in 
#    the local variable fns_in_arcv.
#
# 2) File names on disk (data_src set to "disk") using the same file
#    naming convention as in the external model (EXTRN_MDL_DIR_FILE_LAYOUT 
#    set to "native_to_extrn_mdl").  For this case, the file names are
#    stored in the local variable fns_on_disk_in_sysdir.
#
# 3) File names on disk (data_src set to "disk") using a user-specified
#    file naming convention (EXTRN_MDL_DIR_FILE_LAYOUT set to "user_spec").  
#    For this case, the file names are stored in the local variable 
#    fns_on_disk_user_spec.
#
# The function then sets the set of file names to be returned to one of
# these three local variables (fns_in_arcv, fns_on_disk_in_sysdir, or 
# fns_on_disk_user_spec) depending on the values of data_src and 
# EXTRN_MDL_DIR_FILE_LAYOUT.
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
        fns_in_arcv \
        fns_on_disk_in_sysdir \
        fns_on_disk_user_spec \
        fv3gfs_file_fmt \
        hh \
        mm \
        mn \
        prefix \
        str \
        suffix \
        yy \
        yyyy
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
# First, consider initial condition files.
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
#
# First, set the names of the files (fns_in_arcv) as they would be found 
# in an archive file (e.g. one obtained from NOAA HPSS) and as they would
# be found on disk (fns_on_disk_in_sysdir) in the system directory where 
# the last few days of output are stored.
#
    fcst_hh="00"
    fcst_mn="00"

    case "${extrn_mdl_name}" in

    "GSMGFS")
#      fns=( "atm" "sfc" "nst" )
      fns=( "atm" "sfc" )
      prefix="gfs.t${hh}z."
      fns=( "${fns[@]/#/$prefix}" )
      suffix="anl.nemsio"
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      fns_on_disk_in_sysdir=( "${fns[@]/%/$suffix}" )
      ;;

    "FV3GFS")

      fv3gfs_file_fmt="${FV3GFS_FILE_FMT_ICS}"

      if [ "${fv3gfs_file_fmt}" = "nemsio" ]; then

        fns=( "atm" "sfc" )
        suffix="anl.nemsio"
        fns=( "${fns[@]/%/$suffix}" )

        prefix="gfs.t${hh}z."
        fns_in_arcv=( "${fns[@]/#/$prefix}" )

        if [ "${MACHINE}" = "JET" ]; then
          prefix="${yy}${ddd}${hh}00.gfs.t${hh}z."
        else
          prefix="gfs.t${hh}z."
        fi
        fns_on_disk_in_sysdir=( "${fns[@]/#/$prefix}" )

      elif [ "${fv3gfs_file_fmt}" = "grib2" ]; then

# GSK 12/16/2019:
# Turns out that the .f000 file contains certain necessary fields that
# are not in the .anl file, so switch to the former.
#        fns=( "gfs.t${hh}z.pgrb2.0p25.anl" )
        fns_in_arcv=( "gfs.t${hh}z.pgrb2.0p25.f000" )
        fns_on_disk_in_sysdir=( "gfs.t${hh}z.pgrb2.0p25.f000" )

      elif [ "${fv3gfs_file_fmt}" = "netcdf" ]; then

        fns=( "atm" "sfc" )
        suffix="anl.nc"
        fns=( "${fns[@]/%/$suffix}" )

        prefix="gfs.t${hh}z."
        fns_in_arcv=( "${fns[@]/#/$prefix}" )

        if [ "${MACHINE}" = "JET" ]; then
          prefix="${yy}${ddd}${hh}00.gfs.t${hh}z."
        else
          prefix="gfs.t${hh}z."
        fi
        fns_on_disk_in_sysdir=( "${fns[@]/#/$prefix}" )

      fi
      ;;

    "RAP")
#
# Note that this is GSL RAPX data, not operational NCEP RAP data.  An 
# option for the latter may be added in the future.
#
      fns_in_arcv=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      if [ "${MACHINE}" = "JET" ]; then
        fns_on_disk_in_sysdir=( "wrfnat_130_${fcst_hh}.grib2" )
      else
        fns_on_disk_in_sysdir=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      fi
      ;;

    "HRRR")
#
# Note that this is GSL HRRRX data, not operational NCEP HRRR data.  An 
# option for the latter may be added in the future.
#
      fns_in_arcv=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      if [ "${MACHINE}" = "JET" ]; then
        fns_on_disk_in_sysdir=( "wrfnat_hrconus_${fcst_hh}.grib2" )
      else
        fns_on_disk_in_sysdir=( "${yy}${ddd}${hh}${mn}${fcst_hh}${fcst_mn}" )
      fi
      ;;

    "NAM")
      fns=( "" )
      prefix="nam.t${hh}z.bgrdsfi${hh}"
      fns=( "${fns[@]/#/$prefix}" )
      suffix=".tm${hh}"
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      fns_on_disk_in_sysdir=( "${fns[@]/%/$suffix}" )
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
#
# Now set the names of the files on disk assuming a user-specified file 
# naming convention.
#
    fns_on_disk_user_spec=( "${EXTRN_MDL_FNS_ICS[@]}" )
#
#-----------------------------------------------------------------------
#
# Now consider lateral boundary condition files.
#
#-----------------------------------------------------------------------
#
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
#
# First, set the names of the files (fns_in_arcv) as they would be found 
# in an archive file (e.g. one obtained from NOAA HPSS) and as they would
# be found on disk (fns_on_disk_in_sysdir) in the system directory where 
# the last few days of output are stored.
#
    fcst_hh=( $( printf "%02d " "${lbc_spec_fhrs[@]}" ) )
    fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
    fcst_mn="00"

    case "${extrn_mdl_name}" in

    "GSMGFS")
      prefix="gfs.t${hh}z.atmf"
      fns=( "${fcst_hhh[@]/#/$prefix}" )
      suffix=".nemsio"
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      fns_on_disk_in_sysdir=( "${fns[@]/%/$suffix}" )
      ;;

    "FV3GFS")

      fv3gfs_file_fmt="${FV3GFS_FILE_FMT_LBCS}"

      if [ "${fv3gfs_file_fmt}" = "nemsio" ]; then

        suffix=".nemsio"
        fns=( "${fcst_hhh[@]/%/$suffix}" )

        prefix="gfs.t${hh}z.atmf"
        fns_in_arcv=( "${fns[@]/#/$prefix}" )

        if [ "${MACHINE}" = "JET" ]; then
          prefix="${yy}${ddd}${hh}00.gfs.t${hh}z.atmf"
        else
          prefix="gfs.t${hh}z.atmf"
        fi
        fns_on_disk_in_sysdir=( "${fns[@]/#/$prefix}" )

      elif [ "${fv3gfs_file_fmt}" = "grib2" ]; then

        prefix="gfs.t${hh}z.pgrb2.0p25.f"
        fns_in_arcv=( "${fcst_hhh[@]/#/$prefix}" )
        fns_on_disk_in_sysdir=( "${fcst_hhh[@]/#/$prefix}" )

      elif [ "${fv3gfs_file_fmt}" = "netcdf" ]; then

        suffix=".nc"
        fns=( "${fcst_hhh[@]/%/$suffix}" )

        prefix="gfs.t${hh}z.atmf"
        fns_in_arcv=( "${fns[@]/#/$prefix}" )

        if [ "${MACHINE}" = "JET" ]; then
          prefix="${yy}${ddd}${hh}00.gfs.t${hh}z.atmf"
        else
          prefix="gfs.t${hh}z.atmf"
        fi
        fns_on_disk_in_sysdir=( "${fns[@]/#/$prefix}" )

      fi
      ;;

    "RAP")
#
# Note that this is GSL RAPX data, not operational NCEP RAP data.  An 
# option for the latter may be added in the future.
#
      prefix="${yy}${ddd}${hh}${mn}"
      fns_in_arcv=( "${fcst_hh[@]/#/$prefix}" )
      suffix="${fcst_mn}"
      fns_in_arcv=( "${fns_in_arcv[@]/%/$suffix}" )

      if [ "${MACHINE}" = "JET" ]; then 
        prefix="wrfnat_130_"
        suffix=".grib2"
      else
        prefix="${yy}${ddd}${hh}${mn}"
        suffix="${fcst_mn}"
      fi
      fns_on_disk_in_sysdir=( "${fcst_hh[@]/#/$prefix}" )
      fns_on_disk_in_sysdir=( "${fns_on_disk_in_sysdir[@]/%/$suffix}" )
      ;;

    "HRRR")
#
# Note that this is GSL HRRRX data, not operational NCEP HRRR data.  An 
# option for the latter may be added in the future.
#
      prefix="${yy}${ddd}${hh}${mn}"
      fns_in_arcv=( "${fcst_hh[@]/#/$prefix}" )
      suffix="${fcst_mn}"
      fns_in_arcv=( "${fns_in_arcv[@]/%/$suffix}" )

      if [ "${MACHINE}" = "JET" ]; then
        prefix="wrfnat_hrconus_"
        suffix=".grib2"
      else
        prefix="${yy}${ddd}${hh}${mn}"
        suffix="${fcst_mn}"
      fi
      fns_on_disk_in_sysdir=( "${fcst_hh[@]/#/$prefix}" )
      fns_on_disk_in_sysdir=( "${fns_on_disk_in_sysdir[@]/%/$suffix}" )
      ;;

    "NAM")
      prefix="nam.t${hh}z.bgrdsf"
      fns=( "${fcst_hhh[@]/#/$prefix}" )
      suffix=""
      fns_in_arcv=( "${fns[@]/%/$suffix}" )
      fns_on_disk_in_sysdir=( "${fns[@]/%/$suffix}" )
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
#
# Now set the names of the files on disk assuming a user-specified file 
# naming convention.
#
    fcst_hhh=( $( printf "%03d " "${lbc_spec_fhrs[@]}" ) )
    fns_on_disk_user_spec=( "${fcst_hhh[@]/#/${EXTRN_MDL_FNS_LBCS_PREFIX}}" )
    fns_on_disk_user_spec=( "${fns_on_disk_user_spec[@]/%/${EXTRN_MDL_FNS_LBCS_SUFFIX}}" )

  fi
#
#-----------------------------------------------------------------------
#
# Set the variable containing the external file names that will be 
# returned to the calling function or script.  This depends on the data
# source as well as the directory structure and file naming convention
# assumed.
#
#-----------------------------------------------------------------------
#
  if [ "${data_src}" = "disk" ]; then
    if [ "${EXTRN_MDL_DIR_FILE_LAYOUT}" = "native_to_extrn_mdl" ]; then
      fns=( "${fns_on_disk_in_sysdir[@]}" )
    elif [ "${EXTRN_MDL_DIR_FILE_LAYOUT}" = "user_spec" ]; then
      fns=( "${fns_on_disk_user_spec[@]}" )
    fi
  elif [ "${data_src}" = "noaa_hpss" ] || \
       [ "${data_src}" = "nomads" ]; then
    fns=( "${fns_in_arcv[@]}" )
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
    str="( "$( printf "\"%s\" " "${fns[@]}" )")"
    eval ${outvarname_fns}=$str
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
