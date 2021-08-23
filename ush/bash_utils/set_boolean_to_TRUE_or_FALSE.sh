#
#-----------------------------------------------------------------------
#
# This file defines a function that sets the value of a boolean variable
# to either "TRUE" (if it is set to other valid values that are equivalent
# to "TRUE", e.g. "true", "YES", "yes", etc) or "FALSE" (if it is set to
# other valid values that are equivalent to "FALSE", e.g. "false", "NO",
# "no", etc).
# 
#-----------------------------------------------------------------------
#
function set_boolean_to_TRUE_or_FALSE() { 
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
    "boolean_value" \
    "outvarname_boolean" \
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
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local b
#
#-----------------------------------------------------------------------
#
# Make sure that boolean_value is set to a valid value.
#
#-----------------------------------------------------------------------
#
  valid_vals_boolean=( "TRUE" "true" "YES" "yes" "FALSE" "false" "NO" "no" )
  check_var_valid_value "boolean_value" "valid_vals_BOOLEAN"
#
#-----------------------------------------------------------------------
#
# Set b to either "TRUE" or "FALSE" depending on the value of the input
# argument "boolean_value".
#
#-----------------------------------------------------------------------
#
  b="${boolean_value}"
  if [ "$b" = "true" ] || [ "$b" = "YES" ] || [ "$b" = "yes" ]; then
    b="TRUE"
  elif [ "$b" = "false" ] || [ "$b" = "NO" ] || [ "$b" = "no" ]; then
    b="FALSE"
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
  if [ ! -z "${outvarname_boolean}" ]; then
    eval ${outvarname_boolean}="$b"
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
