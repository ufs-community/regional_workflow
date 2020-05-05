#
#-----------------------------------------------------------------------
#
# This function checks whether the specified variable contains a valid 
# value (where the set of valid values is also specified).
#
#-----------------------------------------------------------------------
#
function check_var_valid_value() {
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
  local scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
  local scrfunc_fn=$( basename "${scrfunc_fp}" )
  local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
  local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
# Check arguments.
#
#-----------------------------------------------------------------------
#
  if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then

    print_info_msg "
Incorrect number of arguments specified:

  Function name:  \"${func_name}\"
  Number of arguments specified:  $#"

    usage
  fi
#
#-----------------------------------------------------------------------
#
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local var_name \
        valid_var_values_array_name \
        var_value \
        valid_var_values_at \
        valid_var_values \
        err_msg \
        valid_var_values_str
#
#-----------------------------------------------------------------------
#
# Set local variable values.
#
#-----------------------------------------------------------------------
#
  var_name="$1"
  valid_var_values_array_name="$2"

  var_value=${!var_name}
  valid_var_values_at="$valid_var_values_array_name[@]"
  valid_var_values=("${!valid_var_values_at}")
  err_msg="\
The value specified in ${var_name} is not supported:
  ${var_name} = \"${var_value}\""
  machine=''

  while [ "$#" -gt 2 ]; do
    # Don't be scared of the scary bash variable manipulations! Quick tutorial:
    # ${abc%:*}  Represents everything BEFORE the FIRST "=" character from the string variable abc
    # ${def%%:*} Represents everything BEFORE the LAST ":" character from the string variable def
    # ${ghij#*=} Represents everything AFTER the FIRST "=" character from the string variable ghij
    # ${klm##*!} Represents everything AFTER the LAST "!" character from the string variable klm
    if [ "${3%%=*}" == "msg" ]; then
      err_msg="${3#*=}"
    elif [ "${3%%=*}" == "mach" ]; then
      machine="${3#*=}"
    else
      print_info_msg "
ERROR: Unknown argument specified:

  Function name:  \"${func_name}\"
  Unknown argument:  $3"

    fi
    # "shift" removes the first argument from the list, so if there is a 4th argument, 
    # it will become the 3rd, and the while loop restarts. If the "shift" results in 
    # only two arguments remaining, then the while loop will exit.
    shift
  done

  if [ ! -z "$machine" ]; then
    # Machine has been specified as an argument, so first check if
    # there are machine-specific valid values for this variable
    valid_var_values_array_name_mach=${machine}_${valid_var_values_array_name}

    valid_var_values_mach_at="$valid_var_values_array_name_mach[@]"
    valid_var_values_mach=("${!valid_var_values_mach_at}")

    # Check to see if this array (valid values for this specific machine) exists
    # by seeing if the array has more than zero elements; otherwise this check will
    # be skipped and this function will fall back to the non-machine-specific values
    if [ ${#valid_var_values_mach[@]} -eq 0 ]; then
      print_info_msg "
No machine-specific valid_vals for this machine ($valid_var_values_array_name_mach). 
Will check for a generic valid_vals (${valid_var_values_array_name})"

        check_var_valid_value $var_name $valid_var_values_array_name

    else
            print_info_msg "$VERBOSE" "
This machine ($machine) has machine-specific valid_vals ($valid_var_values_array_name_mach). 
Will check $var_name against those values"

      # Let's get recursive!
      check_var_valid_value $var_name $valid_var_values_array_name_mach "msg=$err_msg"

    fi

  else

#
#-----------------------------------------------------------------------
#
# Check whether var_value is equal to one of the elements of the array
# valid_var_values.  If not, print out an error message and exit the 
# calling script.
#
#-----------------------------------------------------------------------
#
    is_element_of "valid_var_values" "${var_value}" || { \
      valid_var_values_str=$(printf "\"%s\" " "${valid_var_values[@]}");
      print_err_msg_exit "\
${err_msg}
${var_name} must be set to one of the following:
  ${valid_var_values_str}"; \
    }
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

usage () {
    print_err_msg_exit "

Usage:

  ${func_name}  var_name  valid_var_values_array_name  [mach=machine]  [msg=message]

where the arguments are defined as follows:

  var_name:
  The name of the variable whose value we want to check for validity.

  valid_var_values_array_name:
  The name of the array containing a list of valid values that var_name can take on.

  mach
  Optional argument specifying the machine; if there are no machine-specific
  settings for this combination of variable and machine, this value will be ignored

  msg
  Optional argument specifying the first portion of the error message to print out 
  if var_name does not have a valid value.
"

}
