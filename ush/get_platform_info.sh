#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions. 
#
#-----------------------------------------------------------------------
#
# . ${GLOBAL_VAR_DEFNS_FP}
# . $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# This file defines a function that is used to obtain information (e.g.
# output file names, system and mass store file and/or directory names)
# for a specified external model, analysis or forecast, and cycle date.
# See the usage statement below for this function should be called and
# the definitions of the input parameters.
# 
#-----------------------------------------------------------------------
#
function get_platform_info() {
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
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
    "num_pes" \
    "num_threads" \
    "varname_res_mgr" \
    "varname_run_cmd" \
    "varname_stack_size" \
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
# Check arguments.
#
#-----------------------------------------------------------------------
#
if [ 0 = 1 ]; then

  if [ "$#" -eq "0" ]; then

    print_err_msg_exit "
Incorrect number of arguments specified:

  Function name:  \"${func_name}\"
  Number of arguments specified:  $#

Usage:

  ${func_name} \
    num_pes  \
    num_threads  \
    varname_res_mgr \
    varname_run_cmd

where the arguments (all optional) are defined as follows:
 
  num_pes:
  Total number of MPI tasks for the parallel application.

  num_threads:
  Number of OpenMP threads.

  varname_res_mgr:
  Name of the global variable that will contain the name of the
  resource manager on the selected platform.

  varname_run_cmd:
  Name of the global variable that will contain the command required
  to run a parallel application on the selected platform.
"

  fi

fi
#
#-----------------------------------------------------------------------
#
# Step through the arguments list and set each to a local variable.
#
#-----------------------------------------------------------------------
#
#
#-----------------------------------------------------------------------
#
# Declare additional local variables.  Note that all variables in this 
# function should be local.  The variables set by this function are not
# directly passed back to the calling script because that is not easily
# feasable in bash.  Instead, the calling script specifies a file in 
# which to store the output variables and their values.  The name of 
# of this file
#
#-----------------------------------------------------------------------
#
  local plaunch scheduler
#
#-----------------------------------------------------------------------
#
# Determine the resource manager for each supported platform.
#
#-----------------------------------------------------------------------
#
  scheduler="unknown"
  set_stack_size=
  case "$MACHINE" in
    "WCOSS")
      scheduler="lsf"
      set_stack_size="unlimited"
      ;;
    "WCOSS_C")
      scheduler="lsf_cray"
      set_stack_size="unlimited"
      ;;
    "WCOSS_DELL_P3")
      scheduler="lsf_dell"
      set_stack_size="unlimited"
      ;;
    "HERA")
      scheduler="slurm"
      set_stack_size="unlimited"
      ;;
    "JET")
      scheduler="slurm"
      set_stack_size="unlimited"
      ;;
    "CHEYENNE")
      scheduler="pbs"
      ;;
    *)
      print_err_msg_exit "\
Unsupported platform:
  MACHINE = \"$MACHINE\""
      ;;
  esac
#
#-----------------------------------------------------------------------
#
# Set default number of PES and threads.
#
#-----------------------------------------------------------------------
#
  num_pes=${num_pes:-${NCORES_PER_NODE}}
  num_threads=${num_threads:-1}
  local pes_per_node=$(( NCORES_PER_NODE / num_threads ))
#
#-----------------------------------------------------------------------
#
# Determine the name and syntax of the resource manager's application
# launcher for each supported platform.
#
#-----------------------------------------------------------------------
#
  case "${scheduler}" in
    "lsf" | "lsf_cray")
      plaunch="aprun -n ${num_pes} -N ${pes_per_node} -d ${num_threads:-1}"
      ;;
    "lsf_dell")
      plaunch="mpirun -n ${num_pes}"
      ;;
    "slurm")
      plaunch="srun -l"
      ;;
    "pbs")
      plaunch="mpiexec_mpt -np ${num_pes}"
      ;;
    *)
      print_err_msg_exit "\
Unsupported resource manager:
  MACHINE = \"$MACHINE\"
  scheduler = \"${scheduler}\""
      ;;
  esac
#
#-----------------------------------------------------------------------
#
# Use the eval function to set values of output variables.
#
#-----------------------------------------------------------------------
#
  if [ ! -z "${varname_run_cmd}" ] ; then
    eval ${varname_run_cmd}=\"${plaunch}\"
  fi
  if [ ! -z "${varname_res_mgr}" ] ; then
    eval ${varname_res_mgr}=\"${scheduler%%_*}\"
  fi
  if [ ! -z "${varname_stack_size}" ] ; then
    eval ${varname_stack_size}=\"${set_stack_size}\"
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
