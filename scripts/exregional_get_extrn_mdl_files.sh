#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Source required files.
#
#-----------------------------------------------------------------------
#
. $USHDIR/extrn_mdl/set_extrn_mdl_filenames.sh
. $USHDIR/extrn_mdl/set_extrn_mdl_arcv_file_dir_names.sh
. $USHDIR/extrn_mdl/get_extrn_mdl_files_from_disk.sh
. $USHDIR/extrn_mdl/get_extrn_mdl_files_from_noaa_hpss.sh
. $USHDIR/extrn_mdl/get_extrn_mdl_files_from_nomads.sh
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
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that copies/fetches to a local directory 
either from disk or HPSS) the external model files from which initial or 
boundary condition files for the FV3 will be generated.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  Then 
# process the arguments provided to this script/function (which should 
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
valid_args=( \
  "ics_or_lbcs" \
  "data_sources" \
  "staging_dir" \
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
# Set the name of the external model.
#
#-----------------------------------------------------------------------
#
if [ "${ics_or_lbcs}" = "ICS" ]; then
  extrn_mdl_name="${EXTRN_MDL_NAME_ICS}"
elif [ "${ics_or_lbcs}" = "LBCS" ]; then
  extrn_mdl_name="${EXTRN_MDL_NAME_LBCS}"
fi
#
#-----------------------------------------------------------------------
#
# Set the number of hours to shift back the starting time of the external 
# model for LBCs (relative to the starting time of the FV3LAM).
#
#-----------------------------------------------------------------------
#
extrn_mdl_temporal_offset_hrs="0"
if [ "${ics_or_lbcs}" = "LBCS" ]; then

  case "${EXTRN_MDL_NAME_LBCS}" in
  "GSMGFS")
    extrn_mdl_temporal_offset_hrs="0"
    ;;
  "FV3GFS")
    extrn_mdl_temporal_offset_hrs="0"
    ;;
  "RAP")
    extrn_mdl_temporal_offset_hrs="3"
    ;;
  "HRRR")
    extrn_mdl_temporal_offset_hrs="0"
    ;;
  "NAM")
    extrn_mdl_temporal_offset_hrs="0"
    ;;
  esac

fi
#
#-----------------------------------------------------------------------
#
# Extract from CDATE the starting date (without the hour) and hour-of-day
# of the current FV3LAM cycle.  Then subtract the temporal offset given
# by extrn_mdl_temporal_offset_hrs (in units of hours) from CDATE to 
# obtain the starting date and time of the external model, express the
# result in YYYYMMDDHH format, and save it in cdate.  This is the starting
# time of the external model forecast.
#
#-----------------------------------------------------------------------
#
parse_cdate \
  cdate="$CDATE" \
  outvarname_yyyymmdd="yyyymmdd" \
  outvarname_hh="hh" \

cdate=$( date --utc --date \
         "${yyyymmdd} ${hh} UTC - ${extrn_mdl_temporal_offset_hrs} hours" \
         "+%Y%m%d%H" )
#
#-----------------------------------------------------------------------
#
# If fetching external model files for the purpose of creating lateral
# boundary conditions (LBCs), set lbc_spec_fhrs to the array of forecast 
# hours at which the LBCs are to be specified, starting with the 2nd such 
# time (i.e. the one having array index 1).  We do not include the first 
# hour (hour 0) because at this initial time, the LBCs are obtained from 
# the analysis fields provided by the external model (as opposed to a 
# forecast field).  Note that 
#
#-----------------------------------------------------------------------
#
lbc_spec_fhrs=( "" )

if [ "${ics_or_lbcs}" = "LBCS" ]; then

  lbc_spec_fhrs=( "${LBC_SPEC_FCST_HRS[@]}" )
#
# Add the temporal offset specified by extrn_mdl_temporal_offset_hrs 
# (which is in units of hours) to the array of LBC update forecast hours 
# to make up for the fact that the starting time of the external model 
# is shifted back from that of the FV3LAM by this offset.  After this 
# addition, lbc_spec_fhrs will contain the LBC update forecast hours 
# relative to the start time of the external model.
#
  num_fhrs=${#lbc_spec_fhrs[@]}
  for (( i=0; i<=$((num_fhrs-1)); i++ )); do
    lbc_spec_fhrs[$i]=$(( ${lbc_spec_fhrs[$i]} + ${extrn_mdl_temporal_offset_hrs} ))
  done

fi
#
#-----------------------------------------------------------------------
#
# Loop through the specified external model data sources until we are 
# able to get the external model files from one.
#
#-----------------------------------------------------------------------
#
num_data_sources="${#data_sources[@]}"
for (( i=0; i<${num_data_sources}; i++ )); do

  data_src="${data_sources[i]}"

  print_info_msg "
Attempting to obtain external model data from current data source (data_src):
  data_src = \"${data_src}\"
..."
#
# Get file names.
#
  set_extrn_mdl_filenames \
    data_src="${data_src}" \
    extrn_mdl_name="${extrn_mdl_name}" \
    ics_or_lbcs="${ics_or_lbcs}" \
    cdate="$cdate" \
    outvarname_fns="__fns"

  fns_str="( "$( printf "\"%s\" " "${__fns[@]}" )")"
#
# Data source is local disk.
#
  if [ "${data_src}" = "disk" ]; then

    get_extrn_mdl_files_from_disk \
      extrn_mdl_name="${extrn_mdl_name}" \
      ics_or_lbcs="${ics_or_lbcs}" \
      cdate="$cdate" \
      staging_dir="${staging_dir}" \
      fns="${fns_str}"
#
# Data source is NOAA HPSS.
#
  elif [ "${data_src}" = "noaa_hpss" ]; then

    set_extrn_mdl_arcv_file_dir_names \
      extrn_mdl_name="${extrn_mdl_name}" \
      ics_or_lbcs="${ics_or_lbcs}" \
      cdate="$cdate" \
      outvarname_arcv_fmt="__arcv_fmt" \
      outvarname_arcv_fns="__arcv_fns" \
      outvarname_arcv_fps="__arcv_fps" \
      outvarname_arcvrel_dir="__arcvrel_dir"

    arcv_fns_str="( "$( printf "\"%s\" " "${__arcv_fns[@]}" )")"
    arcv_fps_str="( "$( printf "\"%s\" " "${__arcv_fps[@]}" )")"
    get_extrn_mdl_files_from_noaa_hpss \
      cdate="$cdate" \
      staging_dir="${staging_dir}" \
      arcv_fmt="${__arcv_fmt}" \
      arcv_fns="${arcv_fns_str}" \
      arcv_fps="${arcv_fps_str}" \
      arcvrel_dir="${__arcvrel_dir}" \
      fns="${fns_str}"
#
# Data source is NOMADS.
#
  elif [ "${data_src}" = "nomads" ]; then

    set_extrn_mdl_arcv_file_dir_names \
      extrn_mdl_name="${extrn_mdl_name}" \
      ics_or_lbcs="${ics_or_lbcs}" \
      cdate="$cdate" \
      outvarname_arcvrel_dir="__arcvrel_dir"

    get_extrn_mdl_files_from_nomads \
      ics_or_lbcs="${ics_or_lbcs}" \
      extrn_mdl_name="${extrn_mdl_name}" \
      cdate="$cdate" \
      staging_dir="${staging_dir}" \
      arcvrel_dir="${__arcvrel_dir}" \
      fns="${fns_str}"

  fi
#
#-----------------------------------------------------------------------
#
# If the file retrieval from the current external model data source
# (data_src) failed, then print out a message and either try the next
# data source (if more are available) or exit.
#
#-----------------------------------------------------------------------
#
  if [ $? -ne 0 ]; then

    if [ $i -eq "$((${num_data_sources}-1))" ]; then
      data_sources_str="( "$( printf "\"%s\" " "${data_sources[@]}" )")"
      print_err_msg_exit "
Failed to obtain the external model data files for generating "${ics_or_lbcs}" from
any of the data sources specified in data_sources, which are:
  data_sources = ${data_sources_str}"
    else
      print_info_msg "\
Failed to obtain the external model data files for generating "${ics_or_lbcs}" from
the current data source (data_src):
  data_src = \"${data_src}\"
Will try the next data source specified in data_sources, which is:
  \"${data_sources[$((i+1))]}\""
    fi
#
#-----------------------------------------------------------------------
#
# If the file retrieval from the current external model data source
# (data_src) succeeded, there is no need to try to retrieve the files
# from the remaining data sources specified in data_sources.  In this
# case, print out an appropriate message and break out of the for-loop
# over the locations.
#
#-----------------------------------------------------------------------
#
  else

    if [ "${data_src}" = "disk" ]; then

      if [ "${ics_or_lbcs}" = "ICS" ]; then

        print_info_msg "
========================================================================
Successfully copied or linked to external model files on disk needed for
generating initial conditions and surface fields for the FV3 forecast!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"

      elif [ "${ics_or_lbcs}" = "LBCS" ]; then

        print_info_msg "
========================================================================
Successfully copied or linked to external model files on disk needed for
generating lateral boundary conditions for the FV3 forecast!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"

      fi

    elif [ "${data_src}" = "noaa_hpss" ]; then

      if [ "${ics_or_lbcs}" = "ICS" ]; then

        print_info_msg "
========================================================================
External model files needed for generating initial condition and surface
fields for the FV3-LAM successfully fetched from NOAA HPSS!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"

      elif [ "${ics_or_lbcs}" = "LBCS" ]; then

        print_info_msg "
========================================================================
External model files needed for generating lateral boundary conditions
on the halo of the FV3-LAM's regional grid successfully fetched from
NOAA HPSS!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"

      fi

    elif [ "${data_src}" = "nomads" ]; then

      print_info_msg "
========================================================================
External model files needed for generating initial and/or lateral boundary
conditions successfully fetched from NOMADS!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"

    fi

    break

  fi

done
#
#-----------------------------------------------------------------------
#
# Create a variable definitions file (in bash syntax) and save in it the
# values of several external-model-associated variables generated in this
# script that will be needed by downstream workflow tasks.
#
#-----------------------------------------------------------------------
#
if [ "${ics_or_lbcs}" = "ICS" ]; then
  var_defns_fn="${EXTRN_MDL_ICS_VAR_DEFNS_FN}"
elif [ "${ics_or_lbcs}" = "LBCS" ]; then
  var_defns_fn="${EXTRN_MDL_LBCS_VAR_DEFNS_FN}"
fi
var_defns_fp="${staging_dir}/${var_defns_fn}"
check_for_preexist_dir_file "${var_defns_fp}" "delete"

settings="\
DATA_SRC=\"${data_src}\"
EXTRN_MDL_CDATE=\"${cdate}\"
EXTRN_MDL_STAGING_DIR=\"${staging_dir}\"
EXTRN_MDL_FNS=${fns_str}"
#
# If the external model files obtained above were for generating LBCS (as
# opposed to ICs), then add to the external model variable definitions
# file the array variable EXTRN_MDL_LBC_SPEC_FHRS containing the forecast
# hours at which the lateral boundary conditions are specified.
#
if [ "${ics_or_lbcs}" = "LBCS" ]; then
  lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${lbc_spec_fhrs[@]}" )")"
  settings="$settings
EXTRN_MDL_LBC_SPEC_FHRS=${lbc_spec_fhrs_str}"
fi

{ cat << EOM >> "${var_defns_fp}"
$settings
EOM
} || print_err_msg_exit "\
Heredoc (cat) command to create a variable definitions file associated
with the external model from which to generate ${ics_or_lbcs} returned with a
nonzero status.  The full path to this variable definitions file is:
  var_defns_fp = \"${var_defns_fp}\""
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
