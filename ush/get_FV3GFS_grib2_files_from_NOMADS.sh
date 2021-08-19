#!/bin/bash

#
#-----------------------------------------------------------------------
#
# This script gets external model files from NOMADS.  Type
#
#   get_FV3GFS_grib2_files_from_NOMADS.sh --help
#
# for a full description of how to use this script.
#
#-----------------------------------------------------------------------
#

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
. $ushdir/valid_param_vals.sh
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
# Set the usage message.
#
#-----------------------------------------------------------------------
#
usage_str="\
Usage:

  ${scrfunc_fn} \\
    machine=... \\
    all_cdates=... \\
    lbc_spec_fhrs=... \\
    [data_basedir=...] \\
    [file_types=...]

The arguments in brackets are optional.  Examples:

1) On Cheyenne, to fetch from NOMADS the external model analysis file(s)
   and the forecast files for hours 1, 2, and 5 of the external model 
   cycle starting at 2021081500, use

   ${scrfunc_fn} \\
     machine=\"cheyenne\" \\
     all_cdates=\"2021081500\" \\
     lbc_spec_fhrs='( \"1\" \"2\" \"5\" )'

   This will place the files needed for generating both ICs and LBCs in
   the subdirectory \"./nomads_data/2021081500\" under the directory in 
   which this script is located.

2) On Cheyenne, to fetch just the analysis files for the cycles starting 
   at 2021081500 and 2021081600 and place them in the subdirectories 
   \"./my_data/2021081500\" and \"./my_data/2021081600\", respectively, 
   under the directory in which this script is located, use

  ${scrfunc_fn} \\
    machine=\"cheyenne\" \\
    all_cdates='( \"2021081500\" \"2021081600\" )' \\
    data_basedir=\"./my_data\" \\
    file_types=\"ANL\"

The arguments are defined as follows:

machine:
Machine (platform) on which the script is running.

all_cdates:
Array containing a set of cycle starting times (dates and hours) for 
which to fetch files.  Note that:
* The script will try to fetch from NOMADS the external model files 
  for each of these cycle times.  If fetching fails for a given time,
  it exits without attempting to fetch files for any of the remaining 
  cycle times in all_cdates.
* Each element of all_cdates has the form \"YYYYMMDDHH\", where YYYYY 
  is the four-digit year, MM is the two-digit month, DD is the two-digit 
  day, and HH is the two-digit hour of the cycle's starting time.  
* Normally, all_cdates should be specified as an array on the command 
  line as follows:
    all_cdates='( \"cdate1\" \"cdate2\", ... )'
  However, if file(s) for only one cycle time are needed, it may be 
  specified as a scalar, i.e.
    all_cdates=\"cdate1\"
* By default, for each cycle time, both the analysis files [needed to
  generate initial conditions (ICs) for the FV3LAM] and the forecast 
  files [needed to generate lateral boundary conditions (LBCs)] are
  fetched, but that can be changed via the argument file_types (see 
  below).

lbc_spec_fhrs:
Array containing the forecat hours for which to obtain external model 
forecast files.  Note that:
* This does not need to be specified if file_types does not contain the
  element \"FCST\".
* This must be specified if file_types contains the element \"FCST\".

data_basedir:
The base directory under which the external model files will be stored.
Note that:
* This is an optional argument.  If it is not specified, it will get 
  set to \"./nomads_data\".
* This argument may be an absolute or a relative directory.  If relative, 
  it is with respect to the directory in which this script is located.
* If this directory does not already exist, it will be created.  If it
  does exist, the old one will be renamed by appending to its name the
  string \"_oldNNN\", where NNN is a 3-digit integer, e.g. \"_old003\".
* A separate subdirectory with a name of the form \"YYYYMMDDHH\" will 
  be created under this base directory for each cycle time specified 
  in all_cdates, and the external model files for each cycle will be 
  placed in the corresponding subdirectory.  

file_types:
Array specifying which types of files (analysis and/or forecast) to 
fetch for each cycle date.  Note that:
* file_types may have one or two elements.  Each element may be either
  \"ANL\" or \"FCST\".  If it contains only one element, then if that
  element is set to \"ANL\", only the analysis files will be fetched 
  for each cycle, and if it is set to \"FCST\", only the forecast files
  will be fetched.  If it is set to the array
    ( \"ANL\" \"FCST\" )
  or
    ( \"FCST\" \"ANL\" )
  then both analysis and forecast files will be fetched.
* This is an optional argument.  If it is not specified, it will get 
  set to the array ( \"ANL\" \"FCST\" ), i.e. both analysis and forecast
  files will be fetched.
* Normally, file_types should be specified as an array on the command 
  line, e.g.
    file_types='( \"ANL\" )'
  or
    file_types='( \"ANL\" \"FCST\", ... )'
  However, if only one type of file is to be obtained, it may be specified
  as a scalar, e.g.
    file_types=\"FCST\"
"
#
#-----------------------------------------------------------------------
#
# Check to see if usage help for this script is being requested.  If so,
# print it out and exit with a 0 exit code (success).
#
#-----------------------------------------------------------------------
#
help_flag="--help"
if [ "$#" -eq 1 ] && [ "$1" = "${help_flag}" ]; then
  print_info_msg "${usage_str}"
  exit 0
fi
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
  "all_cdates" \
  "lbc_spec_fhrs" \
  "data_basedir" \
  "file_types" \
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
# Process command-line arguments.
#
#-----------------------------------------------------------------------
#
# Certain arguments that are assumed to be arrays in the code below are
# (for convenience) allowed to be specified as scalars on the command 
# line if they consist of a single element.  If necessary, convert any
# such arguments to arrays here.
#
is_array "all_cdates" || all_cdates=( "${all_cdates}" )
is_array "lbc_spec_fhrs" || lbc_spec_fhrs=( "${lbc_spec_fhrs}" )
is_array "file_types" || file_types=( "${file_types}" )
#
# If file_types is not set, set it to its default value.  This default
# value will cause both analysis and forecast files to be fetched for
# each cycle.
#
if [ -z "${file_types}" ]; then
  file_types=( "ANL" "FCST" )
fi

file_types_str="( "$( printf "\"%s\" " "${file_types[@]}" )")"
if is_element_of "file_types" "FCST"; then
  if [ -z "${lbc_spec_fhrs}" ]; then
    print_err_msg_exit "\
The set of forecast hours (lbc_fcst_hrs) for which to obtain forecast 
files cannot be empty when the array argument file_types contains the
element \"FCST\":
  file_types = ${file_types_str}  
"
  fi
fi
#
# Ensure that the specified machine is one of the valid ones.
#
MACHINE="${machine^^}"
check_var_valid_value "MACHINE" "valid_vals_MACHINE" 
#
# Ensure that all the cycle times in all_cdates consist of only digits
# and are exactly 10 characters in length.
#
all_cdates_str="( "$( printf "\"%s\" " "${all_cdates[@]}" )")"
num_cdates="${#all_cdates[@]}"
for (( i=0; i<${num_cdates}; i++ )); do

  cdate="${all_cdates[$i]}"

  if ! [[ "${cdate}" =~ ^[0-9]+$ ]]; then
    print_err_msg_exit "\
Each cycle time specified in the array all_cdates must consist of only
digits (of the form \"yyyymmddhh\"), but the element with index $i does
not:
  all_cdates = ${all_cdates_str}
  all_cdates[$i] = \"$cdate\""
  fi

  nchars_cdate=${#cdate}
  if [ "${nchars_cdate}" -ne "10" ]; then
    print_err_msg_exit "\
Each cycle time specified in the array all_cdates must consist of exactly 
10 digits (of the form \"yyyymmddhh\"), but the element with index $i does
not:
  all_cdates = ${all_cdates_str}
  all_cdates[$i] = \"$cdate\""
  fi

done
#
# If data_basedir was not set on the command line (or was set to a null
# string), reset it to its default value.  Then check if an identically 
# named directory already exists and if so, move (rename) it.
#
data_basedir="${data_basedir:-./nomads_data}"
VERBOSE="TRUE" # Needed by the check_for_preexist_dir_file function.
check_for_preexist_dir_file "${data_basedir}" "rename"
#
# Ensure that the specified file types all have valid values.
#
valid_vals_file_types=( "ANL" "FCST" )
num_file_types="${#file_types[@]}"
for (( j=0; j<${num_file_types}; j++ )); do
#  file_types[$j]="${file_types[$j]}"
  tmp="${file_types[$j]}"
  check_var_valid_value "file_types[$j]" "valid_vals_file_types" 
done
#
#-----------------------------------------------------------------------
#
# Set variables that fall into one of the following categories:
#
# 1) The functions called below assume exist in the environment (they
#    would normally be available via the experiment's variable definitions
#    file).  These variables are usually upper-case.
#
# 2) Are needed as input arguments in the functions called below.  These
#    are usually lower-case.
#
#-----------------------------------------------------------------------
#
data_src="nomads"
#
# As of 20210819, only FV3GFS files of grib2 format can be fetched from
# NOMADS.  Set the following variables accordingly.  This may be changed
# in the future, in which case the variables below will have to be 
# converted to arguments.
#
extrn_mdl_name="FV3GFS"
FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"
#
# The following are variables that must exist but are not actually used
# in obtaining files from NOMADS.
#
EXTRN_MDL_DIR_FILE_LAYOUT=""
EXTRN_MDL_FNS_ICS=("")
EXTRN_MDL_FNS_LBCS_PREFIX=""
EXTRN_MDL_FNS_LBCS_SUFFIX=""
#
#-----------------------------------------------------------------------
#
# Loop over all specified cycle dates/hours and try to get the external
# model files for each.
#
#-----------------------------------------------------------------------
#
lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${lbc_spec_fhrs[@]}" )")"

for (( i=0; i<${num_cdates}; i++ )); do

  for (( j=0; j<${num_file_types}; j++ )); do

    file_type="${file_types[$j]}"
    if [ "${file_type}" = "ANL" ]; then
      ics_or_lbcs="ICS"
    elif [ "${file_type}" = "FCST" ]; then
      ics_or_lbcs="LBCS"
    fi

    cdate="${all_cdates[$i]}"
    print_info_msg "
Attempting to obtain external model files from NOMADS for:
  ics_or_lbcs = \"${ics_or_lbcs}\"
  cdate = \"$cdate\"
"
#
# Create the directory in which the external model files for this cycle
# will be saved.
#
    staging_dir="${data_basedir}/$cdate"
    mkdir_vrfy -p "${staging_dir}"
#
# Get the names of the external modle files on NOMADS (in __fns).
#
    set_extrn_mdl_filenames \
      data_src="${data_src}" \
      extrn_mdl_name="${extrn_mdl_name}" \
      ics_or_lbcs="${ics_or_lbcs}" \
      cdate="$cdate" \
      lbc_spec_fhrs="${lbc_spec_fhrs_str}" \
      outvarname_fns="__fns"
  
    fns_str="( "$( printf "\"%s\" " "${__fns[@]}" )")"
#
# Get the relative (cycle-dependent) path (in __arcvrel_dir) that will
# be used to form the full URL to the external model files on NOMADS.
#
    set_extrn_mdl_arcv_file_dir_names \
      extrn_mdl_name="${extrn_mdl_name}" \
      ics_or_lbcs="${ics_or_lbcs}" \
      cdate="$cdate" \
      outvarname_arcvrel_dir="__arcvrel_dir"
#
# Get the files from NOMADS.  If this is unsuccessful, exit the loop
# over the cycle dates because we assume it failed because the NOMADS
# is host is not accessible from the current platform.
#
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
