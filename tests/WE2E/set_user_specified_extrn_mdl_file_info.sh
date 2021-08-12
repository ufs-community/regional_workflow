#
#-----------------------------------------------------------------------
#
# This file defines a function that, for a given external model for ICs
# (initial conditions) and a given external model for LBCs (lateral
# boundary conditions), sets the parameters needed to construct the 
# external model file names.  The parameters that are set are:
#
# extrn_mdl_fns_ics:
# This is an array that specifies the set of files needed for generating
# ICs and surface fields on the native FV3LAM grid.  This has to be an 
# array because some external models store all the necessary information 
# in a single file while other models store this information in multiple 
# files, e.g. atmospheric fields in one file and surface fields in another.
#
# extrn_mdl_fns_lbcs_prefix, extrn_mdl_fns_lbcs_suffix:
# These two variables are the prefix and suffix that must be added to
# each 3-digit output forecast hour to construct the file names in which
# the information needed for generating LBCs are stored.  For example, 
# the file containing the information for forecast hour "003" would be
# given (in bash syntax) by
#
#   ${extrn_mdl_fns_lbcs_prefix}003${extrn_mdl_fns_lbcs_suffix}
#
# The actual construction of the file names is not performed by this
# function.  This function simply sets the prefix and suffix for the 
# specified external model for LBCs.
#
#-----------------------------------------------------------------------
#
function set_user_specified_extrn_mdl_file_info() {
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
    "extrn_mdl_name_ics" \
    "extrn_mdl_name_lbcs" \
    "fv3gfs_file_fmt_ics" \
    "fv3gfs_file_fmt_lbcs" \
    "outvarname_extrn_mdl_fns_ics" \
    "outvarname_extrn_mdl_fns_lbcs_prefix" \
    "outvarname_extrn_mdl_fns_lbcs_suffix" \
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
  local extrn_mdl_fns_lbcs_prefix \
        extrn_mdl_fns_lbcs_suffix \
        extrn_mdl_fns_ics \
        extrn_mdl_fns_ics_str
#
#-----------------------------------------------------------------------
#
# Set extrn_mdl_fns_ics according to the external model used for ICs.
#
#-----------------------------------------------------------------------
#
  if [ "${extrn_mdl_name_ics}" = "FV3GFS" ] || \
     [ "${extrn_mdl_name_ics}" = "GSMGFS" ]; then
    if [ "${fv3gfs_file_fmt_ics}" = "nemsio" ]; then
      extrn_mdl_fns_ics=( "gfs.atmanl.nemsio" "gfs.sfcanl.nemsio" )
    elif [ "${fv3gfs_file_fmt_ics}" = "grib2" ]; then
      extrn_mdl_fns_ics=( "gfs.pgrb2.0p25.f000" )
    elif [ "${fv3gfs_file_fmt_ics}" = "netcdf" ]; then
      extrn_mdl_fns_ics=( "gfs.atmanl.nc" "gfs.sfcanl.nc" )
    fi
  elif [ "${extrn_mdl_name_ics}" = "HRRR" ] || \
       [ "${extrn_mdl_name_ics}" = "RAP" ]; then
    extrn_mdl_fns_ics=( "${extrn_mdl_name_ics,,}.out.for_f000" )
  elif [ "${extrn_mdl_name_ics}" = "NAM" ]; then
    extrn_mdl_fns_ics=( "${extrn_mdl_name_ics,,}.out.for_f000" )
  fi
#
#-----------------------------------------------------------------------
#
# Set extrn_mdl_fns_lbcs_prefix and extrn_mdl_fns_lbcs_suffix according
# to the external model used for LBCs.
#
#-----------------------------------------------------------------------
#
  if [ "${extrn_mdl_name_lbcs}" = "FV3GFS" ] || \
     [ "${extrn_mdl_name_lbcs}" = "GSMGFS" ]; then
    if [ "${fv3gfs_file_fmt_lbcs}" = "nemsio" ]; then
      extrn_mdl_fns_lbcs_prefix="gfs.atmf"
      extrn_mdl_fns_lbcs_suffix=".nemsio"
    elif [ "${fv3gfs_file_fmt_lbcs}" = "grib2" ]; then
      extrn_mdl_fns_lbcs_prefix="gfs.pgrb2.0p25.f"
      extrn_mdl_fns_lbcs_suffix=""
    elif [ "${fv3gfs_file_fmt_lbcs}" = "netcdf" ]; then
      extrn_mdl_fns_lbcs_prefix="gfs.atmf"
      extrn_mdl_fns_lbcs_suffix=".nc"
    fi
  elif [ "${extrn_mdl_name_lbcs}" = "HRRR" ] || \
       [ "${extrn_mdl_name_lbcs}" = "RAP" ]; then
    extrn_mdl_fns_lbcs_prefix=""
    extrn_mdl_fns_lbcs_suffix=".nc"
  elif [ "${extrn_mdl_name_lbcs}" = "NAM" ]; then
    extrn_mdl_fns_lbcs_prefix=""
    extrn_mdl_fns_lbcs_suffix=""
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
  if [ ! -z "${outvarname_extrn_mdl_fns_ics}" ]; then
    extrn_mdl_fns_ics_str="( "$( printf "\"%s\" " "${extrn_mdl_fns_ics[@]}" )")"                     
    eval ${outvarname_extrn_mdl_fns_ics}="${extrn_mdl_fns_ics_str}"
  fi

  if [ ! -z "${outvarname_extrn_mdl_fns_lbcs_prefix}" ]; then
    eval ${outvarname_extrn_mdl_fns_lbcs_prefix}="${extrn_mdl_fns_lbcs_prefix}"
  fi

  if [ ! -z "${outvarname_extrn_mdl_fns_lbcs_suffix}" ]; then
    eval ${outvarname_extrn_mdl_fns_lbcs_suffix}="${extrn_mdl_fns_lbcs_suffix}"
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
