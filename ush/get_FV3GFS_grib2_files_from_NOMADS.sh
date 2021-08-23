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
. $ushdir/extrn_mdl/check_nomads_access.sh
. $ushdir/extrn_mdl/get_extrn_mdl_files_from_nomads.sh
. $ushdir/extrn_mdl/set_extrn_mdl_filenames.sh
. $ushdir/extrn_mdl/set_extrn_mdl_arcv_file_dir_names.sh
. $ushdir/valid_param_vals.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script or function.
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
    [file_types=...] \\
    lbc_spec_fhrs=... \\
    [data_basedir=...] \\
    [data_relsubdir=...] \\
    [preexisting_dir_method=...]

The arguments in brackets are optional.  Examples:

1) On Cheyenne, to fetch from NOMADS the external model analysis file(s)
   and the forecast files for hours 1, 2, and 5 of the external model 
   cycle starting at 2021081500, use

   ./${scrfunc_fn} \\
     machine=\"cheyenne\" \\
     all_cdates=\"2021081500\" \\
     lbc_spec_fhrs='( \"1\" \"2\" \"5\" )'

   This will place the files needed for generating both ICs and LBCs in
   the subdirectory \"nomads_data/2021081500\" under the directory in 
   which this script is located.

2) On Cheyenne, to fetch just the analysis files for the cycles starting 
   at 2021081500 and 2021081600 and place them in the subdirectories 
   \"./my_data/2021081500/analysis\" and \"./my_data/2021081600/analysis\", 
   respectively, under the directory in which this script is located, 
   use

  ./${scrfunc_fn} \\
    machine=\"cheyenne\" \\
    all_cdates='( \"2021081500\" \"2021081600\" )' \\
    file_types=\"ANL\" \\
    data_basedir=\"./my_data\" \\
    data_relsubir=\"analysis\" 

The arguments are defined as follows:

machine:
Machine (platform) on which the script is running.

all_cdates:
Array containing a set of cycle starting times (i.e. dates and hours) 
for which to fetch files.  Note that:
* The script will try to fetch from NOMADS the external model files 
  for each of the cycle times in all_cdates.  If fetching fails for a 
  given cycle, the script exits without attempting to fetch files for 
  any of the remaining cycles in all_cdates.
* Each element of all_cdates must have the form \"YYYYMMDDHH\", where 
  YYYYY is the four-digit year, MM is the two-digit month, DD is the 
  two-digit day, and HH is the two-digit hour of the cycle's starting 
  date and time.  
* Normally, in the call to this script, all_cdates should be specified 
  as an array as follows:
    all_cdates='( \"cdate1\" \"cdate2\" ... )'
  However, if the file(s) for only one cycle time are to be fetched, 
  it may be specified as a scalar, i.e.
    all_cdates=\"cdate1\"
* By default, for each cycle time, both the analysis files [needed to
  generate initial conditions (ICs) for the FV3LAM] and the forecast 
  files [needed to generate lateral boundary conditions (LBCs)] are
  fetched, but that can be changed via the argument file_types (see 
  below).

file_types:
Array specifying which types of files (analysis and/or forecast) to 
fetch for each cycle time.  Note that:
* file_types may have at most two elements.  Each element may be either
  \"ANL\" or \"FCST\".  If it contains only one element, then if that
  element is set to \"ANL\", only the analysis files will be fetched 
  for each cycle, and if it is set to \"FCST\", only the forecast files
  will be fetched.  If it is set to the array
    ( \"ANL\" \"FCST\" )
  or to the array
    ( \"FCST\" \"ANL\" )
  then both analysis and forecast files will be fetched.
* This is an optional argument.  If it is not specified in the call to
  this script, it will get set to the array ( \"ANL\" \"FCST\" ), i.e. 
  both analysis and forecast files will be fetched.
* Normally, in the call to this script, file_types should be specified 
  as an array line, e.g.
    file_types='( \"ANL\" )'
  or
    file_types='( \"FCST\" \"ANL\" )'
  However, if only one type of file is to be fetched, it may be specified
  as a scalar, e.g.
    file_types=\"FCST\"

lbc_spec_fhrs:
Array containing the forecat hours for which to fetch external model 
forecast files.  Note that:
* lbc_spec_fhrs must be specified if file_types contains the element 
  \"FCST\" or if file_types is not specified in the call to this script
  (because in that case, file_types will get set to a default value that 
  includes \"FCST\").
* lbc_spec_fhrs does not need to be specified if file_types is set in
  the call to this script to a value that does not contain the element 
  \"FCST\", i.e. if file_types is set as
    file_types='( \"ANL\" )' 
  or
    file_types=\"ANL\" 
* Normally, in the call to this script, lbc_spec_fhrs should be specified 
  as an array, e.g.
    lbc_spec_fhrs='( \"1\" \"2\" ... )'
  However, if the forecast file(s) are to be fetched for only a single 
  hour, it may be specified as a scalar, e.g.
    lbc_spec_fhrs=\"2\"

data_basedir:
The base directory under which the external model files will be stored.
Note that:
* This is an optional argument.  If it is not specified in the call to
  this script (or if it is set to a null string), it will get set to 
  \"nomads_data\".
* data_basedir may be set to an absolute or a relative directory.  If 
  relative, it is with respect to the directory in which this script is 
  located.
* A subdirectory with a relative path of
    \$cdate/\${data_relbasedir}\"
  will be created under this base directory for each cycle time (cdate) 
  specified in all_cdates, and the external model files for the cycle
  will be placed in this subdirectory.  Here, cdate is the starting date 
  and time of the cycle (in the form \"YYYYMMDDHH\" described above), 
  and data_relsubdir is a cycle-independent relative path specified as 
  an argument to this script.  Thus, the full path to the external model
  files for the cycle will be
    \${data_basedir}/\$cdate/\${data_relbasedir}\"

data_relsubdir:
The relative path to append to each cycle date and time to obtain the 
relative directory (with respect to data_basedir) in which to place the
external model files.  Note that:
* The full path to the external model files for a given cycle date and
  time of the form \"YYYYMMDDHH\" (cdate) is given by
    \${data_basedir}/\$cdate/\${data_relbasedir}\"
* If data_relsubdir is not specified in the call to this script (or if 
  it is set to a null string), it will get set to an empty string.

preexisting_dir_method:
Method to use to deal with preexisting data directories.  For a given
cycle, the absolute path to the directory in which the external files
will be saved is
    \${data_basedir}/\$cdate/\${data_relbasedir}\"
Note that:
* If preexisting_dir_method is not specified in the call to this script
  (or if it set to a null string), it will get set to \"none\".  
* Valid (and non-empty) values for preexisting_dir_method are:
    $( printf "\"%s\" " "${valid_vals_PREEXISTING_DIR_METHOD[@]}" )
  The behavior each of these elicits is:
  * \"delete\":
    Delete the preexisting directory.
  * \"rename\":
    Rename the preexisting directory by appending to its name the string 
    \"_oldNNN\", where NNN is a 3-digit integer, e.g. \"_old003\".
  * \"quit\":
    Exit the script.
  * \"none\":
    Do nothing." || \
print_err_msg_exit "\
Something went wrong while setting the variable \"usage_str\"."
#
#-----------------------------------------------------------------------
#
# If this script is being called without arguments, print out the usage
# message and exit with a nonzero code (failure).  If it is being called 
# with the appropriate help flag, print out the usage message and exit 
# with a 0 code (success).
#
#-----------------------------------------------------------------------
#
help_flag="--help"
how_to_see_usage_str="\
Type
  ./${scrfunc_fn} ${help_flag}
to get help on usage."
if [ "$#" -eq "0" ]; then
  print_info_msg "${how_to_see_usage_str}"
  exit 1
fi

if [ "$#" -eq "1" -a "$1" = "${help_flag}" ]; then
  print_info_msg "${usage_str}"
  exit 0
fi
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script or function.  
# Then process the arguments provided to this script or function (which 
# should consist of a set of name-value pairs of the form arg1="value1", 
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( \
  "machine" \
  "all_cdates" \
  "file_types" \
  "lbc_spec_fhrs" \
  "data_basedir" \
  "data_relsubdir" \
  "preexisting_dir_method" \
  )
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script or function.  Note that these will be printed out only if VERBOSE
# is set to TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args "valid_args"
#
#-----------------------------------------------------------------------
#
# Set string to print out in case of error to direct users to help.
#
#-----------------------------------------------------------------------
#
how_to_see_usage_str="\
Type
  ./${scrfunc_fn} ${help_flag}
to get help on usage."
#
#-----------------------------------------------------------------------
#
# Process input arguments.
#
#-----------------------------------------------------------------------
#
# Certain arguments that are assumed to be arrays in the code below are
# (for convenience) allowed to be specified as scalars in the call to 
# this script if they consist of a single element.  If necessary, convert 
# any such arguments to arrays.
#
is_array "all_cdates" || all_cdates=( "${all_cdates}" )
is_array "file_types" || file_types=( "${file_types}" )
is_array "lbc_spec_fhrs" || lbc_spec_fhrs=( "${lbc_spec_fhrs}" )
#
# Ensure that the specified machine is valid.
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
digits (of the form \"YYYYMMDDHH\"), but the element with index $i does
not:
  all_cdates = ${all_cdates_str}
  all_cdates[$i] = \"$cdate\"
${how_to_see_usage_str}"
  fi

  nchars_cdate=${#cdate}
  if [ "${nchars_cdate}" -ne "10" ]; then
    print_err_msg_exit "\
Each cycle time specified in the array all_cdates must consist of exactly 
10 digits (of the form \"YYYYMMDDHH\"), but the element with index $i does
not:
  all_cdates = ${all_cdates_str}
  all_cdates[$i] = \"$cdate\"
${how_to_see_usage_str}"
  fi

done
#
# If file_types is not set (or if its first element is set to an empty
# string), set it to its default value.  This default value will cause 
# both analysis and forecast files to be fetched for each cycle.
#
if [ -z "${file_types}" ]; then
  file_types=( "ANL" "FCST" )
fi
#
# Ensure that file_types has at most two elements and that all are set
# to distinct, valid values.
#
valid_vals_file_types=( "ANL" "FCST" )
file_types_str="( "$( printf "\"%s\" " "${file_types[@]}" )")"
valid_vals_file_types_str=$( printf "\"%s\" " "${valid_vals_file_types[@]}" )

num_file_types="${#file_types[@]}"
for (( j=0; j<${num_file_types}; j++ )); do
  check_var_valid_value "file_types[$j]" "valid_vals_file_types" 
done

if [ "${num_file_types}" -gt "2" ]; then
  print_err_msg_exit "\
At most two file types may be specified in the argument file_types but
there are ${num_file_types}:
  file_types = ${file_types_str} 
Valid values that the elements of file_types may take on are:
  ${valid_vals_file_types_str} 
${how_to_see_usage_str}"
fi

if [ "${num_file_types}" -eq "2" ] && \
   [ "${file_types[0]}" = "${file_types[1]}" ]; then
  print_err_msg_exit "\
The two elements of file_types must be distinct but aren't:
  file_types = ${file_types_str} 
${how_to_see_usage_str}"
fi
#
# If data_basedir is not (or if it is set to a null string), reset it to 
# its default value.
#
data_basedir=${data_basedir:-"nomads_data"}
#
# If preexisting_dir_method is not set (or if is set to a null string), 
# reset it to its default value.  Then ensure that it is set to a valid 
# value.
#
preexisting_dir_method=${preexisting_dir_method:-"none"}
check_var_valid_value "preexisting_dir_method" "valid_vals_PREEXISTING_DIR_METHOD" 
#
# If forecast files are to be fetched, make sure that lbc_spec_fhrs is 
# specified.
# 
if is_element_of "file_types" "FCST"; then
  if [ -z "${lbc_spec_fhrs}" ]; then
    print_err_msg_exit "\
The set of forecast hours (lbc_spec_fhrs) for which to fetch forecast 
files cannot be empty when the array argument file_types contains the
element \"FCST\" or when file_types is not specified in the call to 
this script (in which case both analysis and forecast files will be 
fetched):
  file_types = ${file_types_str} 
${how_to_see_usage_str}"
  fi
fi
#
# If lbc_spec_fhrs is specified in the call to this script (to a non-
# empty value), make sure that each of its elements consists of only 
# digits.
# 
lbc_spec_fhrs_str="( "$( printf "\"%s\" " "${lbc_spec_fhrs[@]}" )")"
num_lbc_spec_fhrs="${#lbc_spec_fhrs[@]}"
if [ ! -z "${lbc_spec_fhrs}" ]; then
  for (( i=0; i<${num_lbc_spec_fhrs}; i++ )); do
    lbc_spec_fhr="${lbc_spec_fhrs[$i]}"
    if ! [[ "${lbc_spec_fhr}" =~ ^[0-9]+$ ]]; then
      print_err_msg_exit "\
Each forecast hour in lbc_spec_fhrs must consist of only digits, but the 
element with index $i contains non-digit characters:
  lbc_spec_fhrs = ${lbc_spec_fhrs_str}
  lbc_spec_fhrs[$i] = \"${lbc_spec_fhr}\"
${how_to_see_usage_str}"
    fi
  done
fi
#
#-----------------------------------------------------------------------
#
# Set variables that fall into one of the following categories:
#
# 1) Are needed as input arguments in the functions called below.  These
#    are usually lower-case.
#
# 2) The functions called below assume exist in the environment (they
#    would normally be available via the experiment's variable definitions
#    file).  These variables are usually upper-case.
#
#-----------------------------------------------------------------------
#
# The following are variables that must exist but are not actually used
# in fetching files from NOMADS.
#
EXTRN_MDL_DIR_FILE_LAYOUT=""
EXTRN_MDL_FNS_ICS=("")
EXTRN_MDL_FNS_LBCS_PREFIX=""
EXTRN_MDL_FNS_LBCS_SUFFIX=""
#
# This script considers only NOMADS as a data source.
#
data_src="nomads"
#
# As of 20210819, this script and the functions called below support 
# fetching of only FV3GFS files of grib2 format (from NOMADS).  Set the 
# following variables accordingly.  This may be changed in the future, 
# in which case the variables below will have to be converted to arguments.
#
extrn_mdl_name="FV3GFS"
FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"
#
#-----------------------------------------------------------------------
#
# Check whether the NOMADS host is accessible from the current machine.
#
#-----------------------------------------------------------------------
#
print_info_msg "
Checking access to NOMADS..."

check_nomads_access || print_err_msg_exit "\
NOMADS is not accessible from this machine (MACHINE):
  MACHINE = \"$MACHINE\""

print_info_msg "
NOMADS is accessible from the this machine (MACHINE):
  MACHINE = \"$MACHINE\""
#
#-----------------------------------------------------------------------
#
# Loop over all specified cycle times and try to get the external model 
# files for each.
#
#-----------------------------------------------------------------------
#
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
Attempting to fetch external model ${file_type} file(s) from NOMADS for:
  cdate = \"$cdate\"
"
#
# Create the full path to the directory in which the external model files 
# for this cycle will be placed.  Then, if preexisting_dir_method is not
# set to a null string, check if an identically named directory already 
# exists and if so, deal with it as specified by preexisting_dir_method.  
# Finally, create the directory.
#
# Note that the bash parameter expansion
#
#   ${data_relsubdir:+/${data_relsubdir}}
#
# evaluates to a null string if data_relsubdir is null or unset, and it
# evaluates to the string "/${data_relsubdir}" if data_relsubdir is set.
#
    staging_dir="${data_basedir}/$cdate${data_relsubdir:+/${data_relsubdir}}"
    if [ ! -z "${preexisting_dir_method}" ]; then
      check_for_preexist_dir_file "${data_basedir}" "${preexisting_dir_method}"
    fi
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
# host is not accessible from the current machine.  Note that we do 
# not check access to NOMADS within the get_extrn_mdl_files_from_nomads
# function called below (check_access="FALSE") because we have already
# checked for access up above before entering this loop.
#
    get_extrn_mdl_files_from_nomads \
      check_access="FALSE" \
      extrn_mdl_name="${extrn_mdl_name}" \
      ics_or_lbcs="${ics_or_lbcs}" \
      staging_dir="${staging_dir}" \
      arcvrel_dir="${__arcvrel_dir}" \
      fns="${fns_str}" || \
    print_err_msg_exit "\
Attempt to fetch external model files from NOMADS for the current cycle
time (cdate) was unsuccessful:
  cdate = \"$cdate\"
Exiting loop over cycle times since this is probably due to inaccessiblity
of the NOMADS host from the current machine (MACHINE):
  MACHINE = \"$MACHINE\"
${how_to_see_usage_str}"

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
