#
#-----------------------------------------------------------------------
#
# This file defines a function that checks (using the "ping" utility) 
# whether the machine on which it is running has access to NOAA's NOMADS
# (NOAA Operational Model Archive and Distribution System) host.  The 
# input arguments are as follows:
#
# host:
# The host to check access to.  If this is not specified, it gets set 
# to "nomads.ncep.noaa.gov".
#
# num_pings:
# The number of times to ping to successfully ping to verify access to
# the host.  If this is not specified, it gets set to "4".
#
# wait_time_secs:
# The wait time (in units of seconds) before quitting the ping utility.
# If this is not specified, it gets set to "30".
#
# The "ping" utility called below will consider access successful if it
# can ping the host successfully num_ping times within wait_time_secs
# seconds.  Otherwise, it will exit and consider access unsuccessful.  
# In the latter case, this function will return with a non-zero return
# code.
#
#-----------------------------------------------------------------------
#
function check_nomads_access() {
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
    "host" \
    "num_pings" \
    "wait_time_secs" \
    )
  process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script or function.  Note that these will be printed out only if an
# environment variable named VERBOSE exists and is set to TRUE.
#
#-----------------------------------------------------------------------
#
  print_input_args "valid_args"
#
#-----------------------------------------------------------------------
#
# Set input arguments to default values if they are not specified in the
# call to this function.
#
#-----------------------------------------------------------------------
#
  host="${host:-nomads.ncep.noaa.gov}"
  num_pings="${num_pings:-4}"
  wait_time_secs="${wait_time_secs:-30}"
#
#-----------------------------------------------------------------------
#
# Try pinging the host.
#
#-----------------------------------------------------------------------
#
  print_info_msg "
Attempting to ping host ${num_pings} times for at most ${wait_time_secs} seconds:
  host = \"$host\"
..."

  ping -c "${num_pings}" -w ${wait_time_secs} "$host" || { \
    print_info_msg "
Unable to ping the host after ${wait_time_secs} seconds:
  host = \"$host\"
Returning with a nonzero return code.
";
    return 1;
  }
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script or 
# function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}
