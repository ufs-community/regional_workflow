#
#-----------------------------------------------------------------------
#
# This file defines a function that
#
#-----------------------------------------------------------------------
#
function set_extrn_mdl_arcv_file_dir_names() {
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
    "outvarname_arcv_fmt" \
    "outvarname_arcv_fns" \
    "outvarname_arcv_fps" \
    "outvarname_arcvrel_dir"
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
  local anl_or_fcst \
        arcv_dir \
        arcv_fmt \
        arcv_fn \
        arcv_fns \
        arcv_fp \
        arcv_fps \
        arcv_fps_str \
        arcvrel_dir \
        fv3gfs_file_fmt
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
  if [ "${ics_or_lbcs}" = "ICS" ]; then
    anl_or_fcst="ANL"
    fv3gfs_file_fmt="${FV3GFS_FILE_FMT_ICS}"
  elif [ "${ics_or_lbcs}" = "LBCS" ]; then
    anl_or_fcst="FCST"
    fv3gfs_file_fmt="${FV3GFS_FILE_FMT_LBCS}"
  fi
#
#-----------------------------------------------------------------------
#
# Extract from cdate the starting year, month, day, and hour of the 
# external model forecast as well as the date without time (yyyymmdd).
#
#-----------------------------------------------------------------------
#
  parse_cdate \
    cdate="$cdate" \
    outvarname_yyyymmdd="yyyymmdd" \
    outvarname_yyyy="yyyy" \
    outvarname_mm="mm" \
    outvarname_dd="dd" \
    outvarname_hh="hh"
#
#-----------------------------------------------------------------------
#
# Set parameters associated with the mass store (HPSS) for the specified
# cycle date (cdate).  These consist of:
#
# 1) The type of the archive file (e.g. tar, zip, etc).
# 2) The name of the archive file.
# 3) The full path in HPSS to the archive file.
# 4) The relative directory in the archive file in which the module output
#    files are located.
#
# Note that these will be used by the calling script only if the archive
# file for the specified cdate actually exists on HPSS.
#
#-----------------------------------------------------------------------
#
  case "${extrn_mdl_name}" in

  "GSMGFS")
    arcv_dir="/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyy}${mm}/${yyyymmdd}"
    arcv_fmt="tar"
    arcv_fns="gpfs_hps_nco_ops_com_gfs_prod_gfs.${cdate}."
    if [ "${anl_or_fcst}" = "ANL" ]; then
      arcv_fns="${arcv_fns}anl"
      arcvrel_dir="."
    elif [ "${anl_or_fcst}" = "FCST" ]; then
      arcv_fns="${arcv_fns}sigma"
      arcvrel_dir="/gpfs/hps/nco/ops/com/gfs/prod/gfs.${yyyymmdd}"
    fi
    arcv_fns="${arcv_fns}.${arcv_fmt}"
    arcv_fps="${arcv_dir}/${arcv_fns}"
    ;;

  "FV3GFS")

    if [ "${cdate}" -lt "2019061200" ]; then
      arcv_dir="/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/prfv3rt3/${cdate}"
      arcv_fns=""
    elif [ "${cdate}" -ge "2019061200" ] && \
         [ "${cdate}" -lt "2020022600" ]; then
      arcv_dir="/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyy}${mm}/${yyyymmdd}"
      arcv_fns="gpfs_dell1_nco_ops_com_gfs_prod_gfs.${yyyymmdd}_${hh}."
    elif [ "${cdate}" -ge "2020022600" ]; then
      arcv_dir="/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyy}${mm}/${yyyymmdd}"
      arcv_fns="com_gfs_prod_gfs.${yyyymmdd}_${hh}."
    fi

    if [ "${fv3gfs_file_fmt}" = "nemsio" ]; then

      if [ "${anl_or_fcst}" = "ANL" ]; then
        arcv_fns="${arcv_fns}gfs_nemsioa"
      elif [ "${anl_or_fcst}" = "FCST" ]; then
        last_fhr_in_nemsioa="39"
        first_lbc_fhr="${lbc_spec_fhrs[0]}"
        last_lbc_fhr="${lbc_spec_fhrs[-1]}"
        if [ "${last_lbc_fhr}" -le "${last_fhr_in_nemsioa}" ]; then
          arcv_fns="${arcv_fns}gfs_nemsioa"
        elif [ "${first_lbc_fhr}" -gt "${last_fhr_in_nemsioa}" ]; then
          arcv_fns="${arcv_fns}gfs_nemsiob"
        else
          arcv_fns=( "${arcv_fns}gfs_nemsioa" "${arcv_fns}gfs_nemsiob" )
        fi
      fi

    elif [ "${fv3gfs_file_fmt}" = "grib2" ]; then

      arcv_fns="${arcv_fns}gfs_pgrb2"

    elif [ "${fv3gfs_file_fmt}" = "netcdf" ]; then

      if [ "${anl_or_fcst}" = "ANL" ]; then
        arcv_fns="${arcv_fns}gfs_nca"
      elif [ "${anl_or_fcst}" = "FCST" ]; then
        last_fhr_in_netcdfa="39"
        first_lbc_fhr="${lbc_spec_fhrs[0]}"
        last_lbc_fhr="${lbc_spec_fhrs[-1]}"
        if [ "${last_lbc_fhr}" -le "${last_fhr_in_netcdfa}" ]; then
          arcv_fns="${arcv_fns}gfs_nca"
        elif [ "${first_lbc_fhr}" -gt "${last_fhr_in_netcdfa}" ]; then
          arcv_fns="${arcv_fns}gfs_ncb"
        else
          arcv_fns=( "${arcv_fns}gfs_nca" "${arcv_fns}gfs_ncb" )
        fi
      fi

    fi

    arcv_fmt="tar"

    slash_atmos_or_null=""
    if [ "${cdate}" -ge "2021032100" ]; then
      slash_atmos_or_null="/atmos"
    fi
    arcvrel_dir="./gfs.${yyyymmdd}/${hh}${slash_atmos_or_null}"

    if is_array "arcv_fns"; then
      suffix=".${arcv_fmt}"
      arcv_fns=( "${arcv_fns[@]/%/$suffix}" )
      prefix="${arcv_dir}/"
      arcv_fps=( "${arcv_fns[@]/#/$prefix}" )
    else
      arcv_fns="${arcv_fns}.${arcv_fmt}"
      arcv_fps="${arcv_dir}/${arcv_fns}"
    fi
    ;;


  "RAP")
#
# Note that this is GSL RAPX data, not operational NCEP RAP data.  An option for the latter
# may be added in the future.
#
# The zip archive files for RAPX are named such that the forecast files
# for odd-numbered starting hours (e.g. 01, 03, ..., 23) are stored
# together with the forecast files for the corresponding preceding even-
# numbered starting hours (e.g. 00, 02, ..., 22, respectively), in an
# archive file whose name contains only the even-numbered hour.  Thus,
# in forming the name of the archive file, if the starting hour (hh) is
# odd, we reduce it by one to get the corresponding even-numbered hour
# and use that to form the archive file name.
#
    hh_orig=$hh
# if it starts with a 0 (e.g. 00, 01, ..., 09), bash will treat it as an
# octal number, and 08 and 09 are illegal ocatal numbers for which the
# arithmetic operations below will fail.
    hh=$((10#$hh))
    if [ $(($hh%2)) = 1 ]; then
      hh=$((hh-1))
    fi
# Now that the arithmetic is done, recast hh as a two-digit string because
# that is needed in constructing the names below.
    hh=$( printf "%02d\n" $hh )

    arcv_dir="/BMC/fdr/Permanent/${yyyy}/${mm}/${dd}/data/fsl/rap/full/wrfnat"
    arcv_fmt="zip"
    arcv_fns="${yyyy}${mm}${dd}${hh}00.${arcv_fmt}"
    arcv_fps="${arcv_dir}/${arcv_fns}"
    arcvrel_dir=""
#
# Reset hh to its original value in case it is used again later below.
#
    hh=${hh_orig}
    ;;

  "HRRR")
#
# Note that this is GSL HRRRX data, not operational NCEP HRRR data.  An option for the latter
# may be added in the future.
#
    arcv_dir="/BMC/fdr/Permanent/${yyyy}/${mm}/${dd}/data/fsl/hrrr/conus/wrfnat"
    arcv_fmt="zip"
    arcv_fns="${yyyy}${mm}${dd}${hh}00.${arcv_fmt}"
    arcv_fps="${arcv_dir}/${arcv_fns}"
    arcvrel_dir=""
    ;;

  "NAM")
    arcv_dir="/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyy}${mm}/${yyyymmdd}"
    arcv_fmt="tar"
    arcv_fns="com_nam_prod_nam.${yyyy}${mm}${dd}${hh}.bgrid.${arcv_fmt}"
    arcv_fps="${arcv_dir}/${arcv_fns}"
    arcvrel_dir=""
    ;;

  *)
    print_err_msg_exit "\
Archive file information has not been specified for this external model:
  extrn_mdl_name = \"${extrn_mdl_name}\""
    ;;

  esac
#
# Depending on the experiment configuration, the above code may set
# arcv_fns and arcv_fps to either scalars or arrays.  If they are not
# arrays, recast them as arrays because that is what is expected in the
# code below.
#
  is_array "arcv_fns" || arcv_fns=( "${arcv_fns}" )
  is_array "arcv_fps" || arcv_fps=( "${arcv_fps}" )
#
#-----------------------------------------------------------------------
#
# Use the eval function to set the output variables.  Note that each of
# these is set only if the corresponding input variable specifying the
# name to use for the output variable is not empty.
#
#-----------------------------------------------------------------------
#
  if [ ! -z "${outvarname_arcv_fmt}" ]; then
    eval ${outvarname_arcv_fmt}=${arcv_fmt}
  fi

  if [ ! -z "${outvarname_arcv_fns}" ]; then
    arcv_fns_str="( "$( printf "\"%s\" " "${arcv_fns[@]}" )")"
    eval ${outvarname_arcv_fns}=${arcv_fns_str}
  fi

  if [ ! -z "${outvarname_arcv_fps}" ]; then
    arcv_fps_str="( "$( printf "\"%s\" " "${arcv_fps[@]}" )")"
    eval ${outvarname_arcv_fps}=${arcv_fps_str}
  fi

  if [ ! -z "${outvarname_arcvrel_dir}" ]; then
    eval ${outvarname_arcvrel_dir}=${arcvrel_dir}
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

