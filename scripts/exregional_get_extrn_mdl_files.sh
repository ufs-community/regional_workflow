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
. $USHDIR/set_extrn_mdl_filenames.sh
. $USHDIR/get_extrn_mdl_files_from_user_dir.sh
. $USHDIR/get_extrn_mdl_files_from_sys_dir.sh
. $USHDIR/get_extrn_mdl_files_from_noaa_hpss.sh
. $USHDIR/get_extrn_mdl_files_from_nomads.sh
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
#  "ics_or_lbcs" \
#  "extrn_mdl_cdate" \
#  "extrn_mdl_lbc_spec_fhrs" \
#  "extrn_mdl_fns_on_disk" \
#  "extrn_mdl_fns_in_arcv" \
#  "extrn_mdl_source_dir" \
#  "extrn_mdl_staging_dir" \
#  "extrn_mdl_arcv_fmt" \
#  "extrn_mdl_arcv_fns" \
#  "extrn_mdl_arcv_fps" \
#  "extrn_mdl_arcvrel_dir" \
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
# Extract from CDATE the starting year, month, day, and hour of
# the FV3-LAM cycle.  Then subtract the temporal offset specified by
# EXTRN_MDL_LBCS_OFFSET_HRS (in units of hours) from CDATE
# to obtain the starting date and time of the external model, express the
# result in YYYYMMDDHH format, and save it in cdate.  This is the starting
# time of the external model forecast.
#
#-----------------------------------------------------------------------
#
  parse_cdate \
    cdate="$CDATE" \
    outvarname_yyyymmdd="yyyymmdd" \
    outvarname_hh="hh" \

  cdate=$( date --utc --date "${yyyymmdd} ${hh} UTC - ${EXTRN_MDL_LBCS_OFFSET_HRS} hours" "+%Y%m%d%H" )
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
# Add the temporal offset specified in EXTRN_MDL_LBCS_OFFSET_HRS (which 
# is in units of hours) to the the array of LBC update forecast hours to 
# make up for shifting the starting hour back in time.  After this addition, 
# lbc_spec_fhrs will contain the LBC update forecast hours relative to
# the start time of the external model run.
#
    num_fhrs=${#lbc_spec_fhrs[@]}
    for (( i=0; i<=$((num_fhrs-1)); i++ )); do
      lbc_spec_fhrs[$i]=$(( ${lbc_spec_fhrs[$i]} + ${EXTRN_MDL_LBCS_OFFSET_HRS} ))
    done

  fi
#
#-----------------------------------------------------------------------
#
#
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
#
#
#-----------------------------------------------------------------------
#
num_data_sources="${#data_sources[@]}"
for (( i=0; i<${num_data_sources}; i++ )); do
echo
echo "===>>>  i = $i"

  data_src="${data_sources[i]}"
echo "data_src = \"${data_src}\""

  print_info_msg "
Attempting to obtain external model data from current data source (data_src):
  data_src = \"${data_src}\"
..."

  if [ "${data_src}" = "user_dir" ]; then
echo
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

    get_extrn_mdl_files_from_user_dir \
      ics_or_lbcs="${ics_or_lbcs}" \
      cdate="$cdate" \
      staging_dir="${staging_dir}" \
      varname_fns_on_disk="fns_on_disk"
echo
echo "  fns_on_disk = \"${fns_on_disk[@]}\""

  elif [ "${data_src}" = "sys_dir" ]; then
echo
echo "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"

    set_extrn_mdl_filenames \
      ics_or_lbcs="${ics_or_lbcs}" \
      extrn_mdl_name="${extrn_mdl_name}" \
      cdate="$cdate" \
      outvarname_fns_on_disk="fns_on_disk"

echo
echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "  fns_on_disk = ( ${fns_on_disk[@]} )"

    fns_on_disk_str="( "$( printf "\"%s\" " "${fns_on_disk[@]}" )")"
    get_extrn_mdl_files_from_sys_dir \
      ics_or_lbcs="${ics_or_lbcs}" \
      extrn_mdl_name="${extrn_mdl_name}" \
      cdate="$cdate" \
      staging_dir="${staging_dir}" \
      fns_on_disk="${fns_on_disk_str}"

  elif [ "${data_src}" = "noaa_hpss" ]; then
echo
echo "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"

    set_extrn_mdl_filenames \
      ics_or_lbcs="${ics_or_lbcs}" \
      extrn_mdl_name="${extrn_mdl_name}" \
      cdate="$cdate" \
      outvarname_fns_in_arcv="fns_in_arcv"

echo
echo "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"
echo "  fns_in_arcv = ( ${fns_in_arcv[@]} )"

    fns_in_arcv_str="( "$( printf "\"%s\" " "${fns_in_arcv[@]}" )")"
    get_extrn_mdl_files_from_noaa_hpss \
      extrn_mdl_name="${extrn_mdl_name}" \
      cdate="$cdate" \
      staging_dir="${staging_dir}" \
      fns_in_arcv="${fns_in_arcv_str}"

  elif [ "${data_src}" = "nomads" ]; then
echo
echo "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"

    get_extrn_mdl_files_from_nomads

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

    if [ "${data_src}" = "user_dir" ] || \
       [ "${data_src}" = "sys_dir" ]; then

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
# Create a variable definitions file (a shell script) and save in it the
# values of several external-model-associated variables generated in this
# script that will be needed by downstream workflow tasks.
#
#-----------------------------------------------------------------------
#
echo "0000000000000000000000000"
if [ "${ics_or_lbcs}" = "ICS" ]; then
  var_defns_fn="${EXTRN_MDL_ICS_VAR_DEFNS_FN}"
elif [ "${ics_or_lbcs}" = "LBCS" ]; then
  var_defns_fn="${EXTRN_MDL_LBCS_VAR_DEFNS_FN}"
fi
var_defns_fp="${staging_dir}/${var_defns_fn}"
check_for_preexist_dir_file "${var_defns_fp}" "delete"

echo "111111111111111111111111111"
if [ "${data_src}" = "user_dir" ] || \
   [ "${data_src}" = "sys_dir" ]; then
  fns_str="( "$( printf "\"%s\" " "${fns_on_disk[@]}" )")"
elif [ "${data_src}" = "noaa_hpss" ]; then
  fns_str="( "$( printf "\"%s\" " "${fns_in_arcv[@]}" )")"
elif [ "${data_src}" = "nomads" ]; then
  fns_str="( "$( printf "\"%s\" " "${fns_on_disk[@]}" )")"
fi

echo "222222222222222222222222222"
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
echo "33333333333333333333333333333"
if [ "${ics_or_lbcs}" = "LBCS" ]; then
  extrn_mdl_lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${lbc_spec_fhrs[@]}" )")"
  settings="$settings
EXTRN_MDL_LBC_SPEC_FHRS=${extrn_mdl_lbc_spec_fhrs_str}"
fi

echo "444444444444444444444444444444"
echo "var_defns_fp = \"${var_defns_fp}\""
{ cat << EOM >> ${var_defns_fp}
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


