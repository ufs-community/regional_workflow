#
#-----------------------------------------------------------------------
#
# This file defines a function that parses a given cycle date (cdate) and
# returns its various parts.  It assumes that cdate is a string that 
# consists of either 10 or 12 digits.  If cdate is 10 digits long, this
# function assumes that it is a string of the form "yyyymmddhh" where 
# yyyy is the four-digit year, mm is the two-digit month, dd is the two-
# digit day of the month, and hh is the two-digit hour of the day.  In 
# this case, the two-digit minutes (mn) are assumed to be "00".  If cdate 
# is 12 characters long, this function assumes it is a string of the form 
# "yyyymmddhhmn" where yyyy, mm, dd, and hh are as defined above and mn 
# is the two-digit minute.
# 
#-----------------------------------------------------------------------
#
function parse_cdate() { 
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
    "cdate" \
    "outvarname_yyyymmdd" \
    "outvarname_yyyy" \
    "outvarname_mm" \
    "outvarname_dd" \
    "outvarname_hh" \
    "outvarname_mn" \
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
  local __dd \
        __hh \
        __mm \
        __mn \
        nchars_cdate \
        __yyyy \
        __yyyymmdd
#
#-----------------------------------------------------------------------
#
# Run the following checks on cdate:
#
# 1) Check that it is not empty.
# 2) Check that it only contains digits.
# 3) Check that it is either 10 or 12 characters long. 
#
#-----------------------------------------------------------------------
#
  if [ -z "${cdate}" ]; then
    print_err_msg_exit "\
The input argument \"cdate\" cannot be empty:
  cdate = \"$cdate\""
  fi

  if ! [[ "${cdate}" =~ ^[0-9]+$ ]]; then
    print_err_msg_exit "\
The input argument \"cdate\" must contain only digits:
  cdate = \"$cdate\""
  fi

  nchars_cdate=${#cdate}
  if [ "${nchars_cdate}" -ne "10" ] && [ "${nchars_cdate}" -ne "12" ]; then
    print_err_msg_exit "\
The number of digits in the input argument \"cdate\" must be either 10 
(in which case it is assumed to have the form \"yyyymmddhh\") or 12 (in
which case it is assumed to have the form \"yyyymmddhhmn\" where mn is 
the two-digit minute):
  cdate = \"$cdate\"
  nchars_cdate = ${nchars_cdate}"
  fi
#
#-----------------------------------------------------------------------
#
# Extract the various parts of cdate.
#
#-----------------------------------------------------------------------
#
  __yyyymmdd=${cdate:0:8}
  __yyyy=${cdate:0:4}
  __mm=${cdate:4:2}
  __dd=${cdate:6:2}
  __hh=${cdate:8:2}
  if [ "${nchars_cdate}" -eq "10" ]; then
    __mn="00"
  elif [ "${nchars_cdate}" -eq "12" ]; then
    __mn="${cdate:10:2}"
  fi
#
#-----------------------------------------------------------------------
#
# Check the extracted values to make sure they're in range.
#
#-----------------------------------------------------------------------
#
  mm_min="01"
  mm_max="12"
  if [ "$__mm" -lt "${mm_min}" ] || [ "$__mm" -gt "${mm_max}" ]; then
    print_err_msg_exit "\
The two-digit month (mm) extracted from cdate must be between \"${mm_min}\" and \"${mm_max}\", 
inclusive:
  cdate = \"$cdate\"
  mm = \"$__mm\""
  fi

  dd_min="01"
  dd_max="31"  # Don't worry about some months having less than 31 days.
  if [ "$__dd" -lt "${dd_min}" ] || [ "$__dd" -gt "${dd_max}" ]; then
    print_err_msg_exit "\
The two-digit day (dd) extracted from cdate must be between \"${dd_min}\" and \"${dd_max}\", 
inclusive:
  cdate = \"$cdate\"
  dd = \"$__dd\""
  fi

  hh_min="00"
  hh_max="23"
  if [ "$__hh" -lt "${hh_min}" ] || [ "$__hh" -gt "${hh_max}" ]; then
    print_err_msg_exit "\
The two-digit hour (hh) extracted from cdate must be between \"${hh_min}\" and 
\"${hh_max}\", inclusive:
  cdate = \"$cdate\"
  hh = \"$__hh\""
  fi

  mn_min="00"
  mn_max="59"
  if [ "$__mn" -lt "${mn_min}" ] || [ "$__mn" -gt "${mn_max}" ]; then
    print_err_msg_exit "\
The two-digit minute (mn) extracted from cdate must be between \"${mn_min}\" and 
\"${mn_max}\", inclusive:
  cdate = \"$cdate\"
  mn = \"$__mn\""
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
  if [ ! -z "${outvarname_yyyymmdd}" ]; then
    eval ${outvarname_yyyymmdd}=$__yyyymmdd
  fi

  if [ ! -z "${outvarname_yyyy}" ]; then
    eval ${outvarname_yyyy}=$__yyyy
  fi

  if [ ! -z "${outvarname_mm}" ]; then
    eval ${outvarname_mm}=$__mm
  fi

  if [ ! -z "${outvarname_dd}" ]; then
    eval ${outvarname_dd}=$__dd
  fi

  if [ ! -z "${outvarname_hh}" ]; then
    eval ${outvarname_hh}=$__hh
  fi

  if [ ! -z "${outvarname_mn}" ]; then
    eval ${outvarname_mn}=$__mn
  fi
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}

