#!/bin/bash

#
#-----------------------------------------------------------------------
#
# For a description of how to use this script, see the usage message 
# below.
#
#-----------------------------------------------------------------------
#
set -u +x
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
# Source the bash utility functions.
#
#-----------------------------------------------------------------------
#
ushdir="${scrfunc_dir}"
. $ushdir/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Set the full path to the experiment directory.  We assume that this
# script is located at the top level of an experiment directory.  Thus, 
# the experiment directory must be the directory in which this script is
# located.
#
#-----------------------------------------------------------------------
#
exptdir=$( dirname "$0" )
exptdir=$( readlink -f "$exptdir" )
#
#-----------------------------------------------------------------------
#
# Set the full path to the workflow global variable defintions file.
# Then source it in order to have access to those variables in this
# script.
#
#-----------------------------------------------------------------------
#
global_var_defns_fn="var_defns.sh"
global_var_defns_fp=$( readlink -f "$exptdir/${global_var_defns_fn}" )
if [ -f "${global_var_defns_fp}" ]; then
  . ${global_var_defns_fp}
else
  print_err_msg_exit "\
This script (or a link to it) must be located at the top level of an 
experiment directory.  The directory in which this script is located 
(exptdir) does not seem to be an experiment directory because it does
not contain a workflow variable definitions file (global_var_defns_fn):
  exptdir = \"${exptdir}\"
  global_var_defns_fn = \"${global_var_defns_fn}\"
Please copy this script to a valid experiment directory (or link to it
from such a directory) and rerun."
fi
#
#-----------------------------------------------------------------------
#
# As a sanity check, make sure that local variables and their counterparts
# defined in the global workflow variable definitions file specified by
# global_var_defns_fp are equal.
#
#-----------------------------------------------------------------------
#
if [ "${global_var_defns_fp}" != "${GLOBAL_VAR_DEFNS_FP}" ]; then
  print_err_msg_exit "\
The local variable global_var_defns_fp specifying the full path to the
file containing the global workflow variable definitions must be equal
to the global workflow variable GLOBAL_VAR_DEFNS_FP that also specifies
this path (and which is defined in the file specified by global_var_defns_fp):
  global_var_defns_fp = \"${global_var_defns_fp}\"
  GLOBAL_VAR_DEFNS_FP = \"${GLOBAL_VAR_DEFNS_FP}\""
fi

if [ "${ushdir}" != "${USHDIR}" ]; then
  print_err_msg_exit "\
The local variable ushdir specifying the full path to the utility shell
scripts directory must be equal to the global workflow variable USHDIR 
that also specifies this path [and which is defined in the global workflow
variable defintions file specified by global_var_defns_fp]: 
  ushdir = \"${ushdir}\"
  USHDIR = \"${USHDIR}\"
  global_var_defns_fp = \"${global_var_defns_fp}\""
fi

if [ "${exptdir}" != "${EXPTDIR}" ]; then
  print_err_msg_exit "\
The local variable exptdir specifying the full path to the experiment 
directory must be equal to the global workflow variable EXPTDIR that also
specifies this path [and which is defined in the global workflow variable
defintions file specified by global_var_defns_fp]: 
  exptdir = \"${exptdir}\"
  EXPTDIR = \"${EXPTDIR}\"
  global_var_defns_fp = \"${global_var_defns_fp}\""
fi
#
#-----------------------------------------------------------------------
#
# Set list of valid task names.
#
#-----------------------------------------------------------------------
#
valid_vals_task_name=( \
"${MAKE_GRID_TN}" \
"${MAKE_OROG_TN}" \
"${MAKE_SFC_CLIMO_TN}" \
"${GET_EXTRN_ICS_TN}" \
"${GET_EXTRN_LBCS_TN}" \
"${MAKE_ICS_TN}" \
"${MAKE_LBCS_TN}" \
"${RUN_FCST_TN}" \
"${RUN_POST_TN}" \
)
valid_vals_task_name_str=$( printf "\"%s\" " ${valid_vals_task_name[@]} )
#
#-----------------------------------------------------------------------
#
# Set list of cycle-dependent tasks.
#
#-----------------------------------------------------------------------
#
cycle_dep_task_names=( \
"${GET_EXTRN_ICS_TN}" \
"${GET_EXTRN_LBCS_TN}" \
"${MAKE_ICS_TN}" \
"${MAKE_LBCS_TN}" \
"${RUN_FCST_TN}" \
"${RUN_POST_TN}" \
)
cycle_dep_task_names_str=$( printf "\"%s\" " ${cycle_dep_task_names[@]} )
#
#-----------------------------------------------------------------------
#
# Set list of valid job schedulers.
#
#-----------------------------------------------------------------------
#
valid_vals_sched=( \
"slurm" \
"moab" \
"pbs" \
)
valid_vals_sched_str=$( printf "\"%s\" " ${valid_vals_sched[@]} )
#
#-----------------------------------------------------------------------
#
# Set the usage message for this script.
#
#-----------------------------------------------------------------------
#
usage_msg="\
This script (${scrfunc_fn}) runs the specified workflow task from the
command line (as opposed to running the task using a workflow manager
like rocoto).  It (or a link to it) should be located at the top level
of an experiment directory.  To obtain help for this script, issue one
of the following commands from the experiment directory:

  ${scrfunc_fn} -h
  ${scrfunc_fn} --help

The syntax for calling this script is as follows:

  [/path/to/experiment/dir/]${scrfunc_fn} \\
    task_name=\"name_of_workflow_task_to_run\" \\
    cdate=\"date_and_hour_string_of_cycle_for_which_to_run_task\" \\
    fhr=\"forecast_hour_for_which_to_run_task\" \\
    sched=\"scheduler_to_use_to_submit_job_that_will_run_task\" \\
    acct=\"account_to_charge_job_resources_to\" \\
    part=\"slurm_partition_in_which_to_run_job\" \\
    qos=\"slurm_quality_of_service_to_submit_job_to\" \\
    nnodes=\"number_of_nodes_to_use_to_run_job\" \\
    ppn=\"number_of_mpi_processes_per_node_to_use_for_job\" \\
    wtime=\"maximum_walltime_to_allow_for_job\"

The arguments are defined as follows:

  task_name:
  The name of the workflow task to run.  Valid task names are:
    ${valid_vals_task_name_str}
  This must be specified.

  cdate:
  The date and hour-of-day of the start time of the cycle for which to
  run the task.  This must be a string consisting of exactly 10 digits
  of the form \"YYYYMMDDHH\", where YYYY is the 4-digit year, MM is the
  2-digit month, DD is the 2-digit day-of- month, and HH is the 2-digit
  hour-of-day.  This must be specified if the task to run (task_name) is
  cycle-dependent.  The cycle-dependent tasks are:
    ${cycle_dep_task_names_str}
  For cycle-independent tasks, any value of cdate specified on the command
  line is ignored.

  fhr:
  The forecast hour for which to run the task.  This must be specified
  only if running the ${RUN_POST_TN} task.  For any other tasks, any value
  of fhr specified on the command line is ignored.

  sched:
  The job scheduler to use to submit the specified workflow task to the
  job queue.  Valid job schedulers are:
    ${valid_vals_sched_str}
  If not specified, the value (out of this list of valid values) that it
  defaults to depends on the current machine. 

  acct:
  The account to charge the core hours to of the job that will run the
  task.  If not specified, it is set to the workflow variable ACCOUNT
  defined in the experiment directory's global variable definitions file
  (${GLOBAL_VAR_DEFNS_FN}).

  part:
  The slurm partition in which to run the job.  If not specified, it is
  set to the default partition that slurm uses on the current machine
  (which can be obtained using the sinfo utility).

  qos:
  The slurm quality-of-service to which to submit the job.  If not specified,
  it is set to the default qos that slurm uses on the current machine
  (which can be obtained using the sacctmgr utility).

  nnodes, ppn, wtime:
  These are, respectively, the number of nodes to request from the job
  scheduler, the number of MPI processes per node to use, and the maximum
  walltime allowed for the job.  If one or more of these is not specified,
  they are set, respectively, to the workflow variables NNODES_\${TASK_NAME},
  PPN_\${TASK_NAME}, and WTIME_\${TASK_NAME} defined in the experiment
  directory's global variable definitions file (${GLOBAL_VAR_DEFNS_FN}), where
  \${TASK_NAME} is the name of the task to run converted to uppercase.
"
#
#-----------------------------------------------------------------------
#
# Set the flag that determines whether the help/usage message will be 
# printed to screen (after which the script exists with a zero exit code).  
# The help message will be printed if no arguments are specified or if
# one argument is specified that is either "-h" or "--help".
#
# Note that if more than one argument is specified, 
#
#-----------------------------------------------------------------------
#
if [ "$#" -eq 0 ]; then

  print_err_msg_exit "\
At least one argument must be provided to this script.  Please see usage
message below.

${usage_msg}"
  
elif [ "$#" -eq 1 -a "$1" = "-h" ] || \
     [ "$#" -eq 1 -a "$1" = "--help" ]; then

  printf "\n%s\n" "${usage_msg}"
  exit

fi
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names that this script/function can
# accept.  Then process the arguments provided to it (which should con-
# sist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
valid_args=( \
"task_name" \
"cdate" \
"fhr" \
"sched" \
"acct" \
"part" \
"qos" \
"nnodes" \
"ppn" \
"wtime" \
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
# Ensure that the specified task name is valid.
#
#-----------------------------------------------------------------------
#
err_msg="\
The specified task name (task_name) is not valid:
  task_name = \"${task_name}\""
check_var_valid_value "task_name" "valid_vals_task_name" "${err_msg}"
#
#-----------------------------------------------------------------------
#
# If we will be running one of the cycle-dependent tasks, then cdate must
# be set to a valid value.  A valid value consists of a string consisting
# of exactly 10 digits.  Check for this.
#
#-----------------------------------------------------------------------
#
is_element_of "cycle_dep_task_names" "${task_name}" && { \
  tmp=$( printf "%s" "${cdate}" | sed -n -r -e "s/^([0-9]{10})$/\1/p" );
  if [ -z "$tmp" ]; then
    print_err_msg_exit "\
The cycle start date and time (cdate) input argument must be a string
consisting of exactly 10 digits of the form \"YYYYMMDDHH\", where YYYY
is the 4-digit year, MM is the 2-digit month, DD is the 2-digit day-of-
month, and HH is the 2-digit hour-of-day:
  cdate = \"${cdate}\""
  fi;
}
#
#-----------------------------------------------------------------------
#
# If running the RUN_POST_TN task, make sure that fhr is set on the
# command line to a non-empty string that consists only of digits.
#
#-----------------------------------------------------------------------
#
if [ "${task_name}" = "${RUN_POST_TN}" ] && [ -z "$fhr" ]; then
  print_err_msg_exit "\
When the task to run (task_name) is set to \"${RUN_POST_TN}\", the forecast hour
(fhr) must be set to a non-empty string (that consists only of digits):
  fhr = \"${fhr}\"
Please rerun with a non-empty value of fhr specified on the command line."
fi
#
#-----------------------------------------------------------------------
#
# If sched is not specified, set it to a default value.  Then convert it
# to lowercase and ensure that it has a valid value.
#
#-----------------------------------------------------------------------
#
if [ -z "$sched" ]; then

  case "$MACHINE" in
#
  "HERA" | "JET")
    sched="slurm"
    ;;
#
  *)
    print_err_msg_exit "\
The job scheduler (sched) has not been specified for this machine:
  MACHINE = \"$MACHINE\"
  sched = \"$sched\"
Please specify a scheduler on the command line (or change the script by
specifying a default scheduler for the machine) and rerun."
    ;;
#
  esac

fi
#
# Make sure that the job scheduler set above is valid.
#
sched=${sched,,}
err_msg="\
The specified job scheduler (sched) is not valid:
  sched = \"${sched}\""
check_var_valid_value "sched" "valid_vals_sched" "${err_msg}"
#
#-----------------------------------------------------------------------
#
# If using slurm as the job scheduler, set the default values of the
# partition and qos (quality-of-service) for the current machine, i.e.
# the values that slurm would use if these parameters are not explicitly
# specified in the sbatch command.  Then, if part and qos are not specified
# on the command line, set their values.  Note that whether these get set
# to the default values for the machine depends on the task.
#
#-----------------------------------------------------------------------
#
part_default=""
qos_default=""

if [ "$sched" = "slurm" ]; then

# Would "grep -o" work instead of sed?  Still would need a regular expression, I think...
  part_default=$( sinfo --format=%P | sed -r -n -e "s/^([^\*]+)\*$/\1/p" )

# Is there a way to get this automatically using a slurm command?  The
# sacctmgr utility gives a list of qos's, but which is the default?  The
# first one?
#  qos_default="batch"
  qos_default=$( sacctmgr --noheader --parsable show qos | \
                 head --lines=1 | \
                 sed -n -r -e "s/^([^|]+).*/\1/p" )

  case "${task_name}" in
#
  "${GET_EXTRN_ICS_TN}" | \
  "${GET_EXTRN_LBCS_TN}")
    part="${part:-${QUEUE_HPSS}}"
    qos="${qos:-${qos_default}}"
    ;;
#
  "${RUN_FCST_TN}")
    part="${part:-${part_default}}"
    qos="${qos:-${QUEUE_FCST}}"
    ;;
#
  *)
    part="${part:-${part_default}}"
    qos="${qos:-${QUEUE_DEFAULT}}"
    ;;
#
  esac

fi
#
#-----------------------------------------------------------------------
#
# If the input argument acct is not specified, set it to the value of the
# workflow variable ACCOUNT.
#
#-----------------------------------------------------------------------
#
acct=${acct:-$ACCOUNT}
#
#-----------------------------------------------------------------------
#
# The GET_EXTRN_ICS_TN and GET_EXTRN_LBCS_TN in fact use the same j-job,
# called JREGIONAL_GET_EXTRN_MDL_FILES (as well as the same ex-script,
# called exregional_get_extrn_mdl_files).  They also use the same global
# workflow variables for the number of nodes (NNODES_GET_EXTRN_MDL_FILES),
# the number of MPI processes per node (PPN_GET_EXTRN_MDL_FILES), and the
# walltime (WTIME_GET_EXTRN_MDL_FILES).  To be able to use the general
# code below for setting these parameters for any task, we now define a
# new local variable named task_name_upper that is equal to the task name
# converted to uppercase for all tasks except GET_EXTRN_ICS_TN and
# GET_EXTRN_LBCS_TN; for these two, it gets set to "GET_EXTRN_MDL_FILES".
#
#-----------------------------------------------------------------------
#
task_name_upper="${task_name}"
if [ "${task_name_upper}" = "${GET_EXTRN_ICS_TN}" ] || \
   [ "${task_name_upper}" = "${GET_EXTRN_LBCS_TN}" ]; then
  task_name_upper="get_extrn_mdl_files"
fi
task_name_upper="${task_name_upper^^}"
#
#-----------------------------------------------------------------------
#
# If not specified as input arguments, set the number of nodes, the MPI
# processes per node, and the walltime for the job to values specified
# in the workflow variables.
#
#-----------------------------------------------------------------------
#
var_name="NNODES_${task_name_upper}"
nnodes=${nnodes:-${!var_name}}

var_name="PPN_${task_name_upper}"
ppn=${ppn:-${!var_name}}

var_name="WTIME_${task_name_upper}"
wtime=${wtime:-${!var_name}}
#
#-----------------------------------------------------------------------
#
# Make sure that the walltime (wtime) is specified in the correct format.
#
#-----------------------------------------------------------------------
#
tmp=$( printf "%s" "${wtime}" | \
       sed -n -r -e "s/^([0-9]{2}:[0-9]{2}:[0-9]{2})$/\1/p" );
if [ -z "$tmp" ]; then
  print_err_msg_exit "\
The wall time (wtime) input argument must be a string of the form \"hh:mm:ss\",
where hh, mm, and ss are 2-digit strings specifying the number of hours,
minutes, and seconds, respectively, in the maximum wall time allowed for
the job:
  wtime = \"${wtime}\""
fi
#
#-----------------------------------------------------------------------
#
# Export variables needed in the j-job for the task.  In the rocoto XML
# file, these variables are passed to the task using the <envvar> tag.  
# Here, we have to export them to the environment so that they are then
# available to the j-job that will be run.
#
#-----------------------------------------------------------------------
#
export GLOBAL_VAR_DEFNS_FP

case "${task_name}" in
#
  "${MAKE_GRID_TN}" | \
  "${MAKE_OROG_TN}" | \
  "${MAKE_SFC_CLIMO_TN}")
    ;;
#
  "${GET_EXTRN_ICS_TN}" | \
  "${GET_EXTRN_LBCS_TN}" | \
  "${MAKE_ICS_TN}" | \
  "${MAKE_LBCS_TN}" | \
  "${RUN_FCST_TN}" | \
  "${RUN_POST_TN}")
    export CDATE="$cdate"
    export PDY=${CDATE:0:8}
    export CYCLE_DIR="${CYCLE_BASEDIR}/$CDATE"
    if [ "${task_name}" = "${GET_EXTRN_ICS_TN}" ]; then
      export EXTRN_MDL_NAME="${EXTRN_MDL_NAME_ICS}"
      export ICS_OR_LBCS="ICS"
    elif [ "${task_name}" = "${GET_EXTRN_LBCS_TN}" ]; then
      export EXTRN_MDL_NAME="${EXTRN_MDL_NAME_LBCS}"
      export ICS_OR_LBCS="LBCS"
    elif [ "${task_name}" = "${RUN_POST_TN}" ]; then
      export cyc=${CDATE:8:2}
      export fhr
    fi
    ;;
#
  esac
#
#-----------------------------------------------------------------------
#
# Create the experiment's log directory if it doesn't already exist.  This
# will have to be done if this is the first time any workflow tasks are
# being run in the experiment directory.
#
#-----------------------------------------------------------------------
#
if [ ! -d "$LOGDIR" ]; then
  mkdir_vrfy "$LOGDIR"
fi
#
#-----------------------------------------------------------------------
#
# Submit the job using the specified scheduler.
#
#-----------------------------------------------------------------------
#
if [ "$sched" = "slurm" ]; then
#
# Use slurm's sbatch command to submit the job to the slurm job scheduler.
#
  sbatch_cmd="
  sbatch --job-name=\"${task_name}\" \\
         --account=\"$acct\" \\
         --partition=\"$part\" \\
         --qos=\"$qos\" \\
         --nodes=\"${nnodes}\" \\
         --ntasks-per-node=\"${ppn}\" \\
         --time=\"$wtime\" \\
         --output=\"$LOGDIR/no_wflow_${task_name}.log\" \\
         --open-mode=\"truncate\" \\
         ${LOAD_MODULES_RUN_TASK_FP} \"${task_name}\" \"$JOBSDIR/JREGIONAL_${task_name_upper}\""

  print_info_msg "$VERBOSE" "                                                                                                                                                
Scheduling job using $sched's sbatch utility:
  ${sbatch_cmd}
"

  eval "${sbatch_cmd}"
#
# Job submit commands for other job schedulers have not yet been specified.
#
else

  print_err_msg_exit "\
This script does not yet support the specified job scheduler (sched):
  sched = \"${sched}\""

fi


