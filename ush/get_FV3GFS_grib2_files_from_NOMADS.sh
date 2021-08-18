#!/bin/bash

#
# Usage:
#
# To get files for generating ICs:
#
#   ./get_FV3GFS_grib2_files_from_NOMADS.sh "cheyenne" "./tmp" "ICS" "2021081500"
#
# To get files for generating LBCs, e.g. at forecast hours 1, 2, and 4:
#
# ./get_FV3GFS_grib2_files_from_NOMADS.sh "cheyenne" "./tmp" "LBCS" "2021081500" "1 2 4"
#
# ./get_FV3GFS_grib2_files_from_NOMADS.sh machine="HERA" ics_or_lbcs="ICS" staging_basedir="./tmp" all_cdates='( "2021081500" "2021081600" )' lbc_spec_fhrs='( "1" "3" )'

#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script or function is
# located (scrfunc_fp), the name of that file (scrfunc_fn), and the
# directory in which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Set the full path to the top-level directory of the regional_workflow
# repository.  We denote this path by homerrfs.
#
#-----------------------------------------------------------------------
#
homerrfs=${scrfunc_dir%/*}
#
#-----------------------------------------------------------------------
#
# Set other directories that depend on homerrfs.
#
#-----------------------------------------------------------------------
#
ushdir="$homerrfs/ush"
#
#-----------------------------------------------------------------------
#
# Source bash utility functions.
#
#-----------------------------------------------------------------------
#
. $ushdir/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Source other needed files.
#
#-----------------------------------------------------------------------
#
. $ushdir/source_util_funcs.sh
. $ushdir/extrn_mdl/set_extrn_mdl_filenames.sh
. $ushdir/extrn_mdl/set_extrn_mdl_arcv_file_dir_names.sh
. $ushdir/extrn_mdl/get_extrn_mdl_files_from_nomads.sh
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
valid_args=( \
  "machine" \
  "ics_or_lbcs" \
  "staging_basedir" \
  "all_cdates" \
  "lbc_spec_fhrs" \
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
#
#
#-----------------------------------------------------------------------
#
MACHINE="${machine^^}"
ics_or_lbcs="${ics_or_lbcs^^}"
#
# Make sure that all_cdates and lbc_spec_fhrs are arrays.
#
is_array "all_cdates" || all_cdates=( "${all_cdates}" )
is_array "lbc_spec_fhrs" || lbc_spec_fhrs=( "${lbc_spec_fhrs}" )


data_src="nomads"
extrn_mdl_name="FV3GFS"
#export FV3GFS_FILE_FMT_ICS="grib2"
#export FV3GFS_FILE_FMT_LBCS="grib2"
FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"
#
#
#
#export EXTRN_MDL_DIR_FILE_LAYOUT=""
#export EXTRN_MDL_FNS_ICS=("")
#export EXTRN_MDL_FNS_LBCS_PREFIX=""
#export EXTRN_MDL_FNS_LBCS_SUFFIX=""
EXTRN_MDL_DIR_FILE_LAYOUT=""
EXTRN_MDL_FNS_ICS=("")
EXTRN_MDL_FNS_LBCS_PREFIX=""
EXTRN_MDL_FNS_LBCS_SUFFIX=""

mkdir_vrfy -p "${staging_basedir}"
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${lbc_spec_fhrs[@]}" )")"

num_lbc_spec_fhrs="${#lbc_spec_fhrs[@]}"
echo
echo "========>>>>>>"
echo "num_lbc_spec_fhrs = ${num_lbc_spec_fhrs}"


num_cdates="${#all_cdates[@]}"
for (( i=0; i<${num_cdates}; i++ )); do

#echo
#echo "num_cdates = ${num_cdates};  i = $i"
#continue

  cdate="${all_cdates[$i]}"
  staging_dir="${staging_basedir}/$cdate"

  print_info_msg "
Attempting to obtain external model files from NOMADS for:
  ics_or_lbcs = \"${ics_or_lbcs}\"
  cdate = \"$cdate\"
"

  set_extrn_mdl_filenames \
    data_src="${data_src}" \
    extrn_mdl_name="${extrn_mdl_name}" \
    ics_or_lbcs="${ics_or_lbcs}" \
    cdate="$cdate" \
    lbc_spec_fhrs="${lbc_spec_fhrs_str}" \
    outvarname_fns="__fns"
  
  fns_str="( "$( printf "\"%s\" " "${__fns[@]}" )")"
  
  set_extrn_mdl_arcv_file_dir_names \
    extrn_mdl_name="${extrn_mdl_name}" \
    ics_or_lbcs="${ics_or_lbcs}" \
    cdate="$cdate" \
    outvarname_arcvrel_dir="__arcvrel_dir"
  
  get_extrn_mdl_files_from_nomads \
    extrn_mdl_name="${extrn_mdl_name}" \
    ics_or_lbcs="${ics_or_lbcs}" \
    staging_dir="${staging_dir}" \
    arcvrel_dir="${__arcvrel_dir}" \
    fns="${fns_str}" || \
  print_err_msg_exit "\
Attempt to obtain external model files from NOMADS for the current cycle
date (cdate) was unsuccessful:
  cdate = \"$cdate\"
Exiting loop over cycle dates since this is probably due to inaccessiblity
of NOMADS host.
"

done
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script or
# function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
