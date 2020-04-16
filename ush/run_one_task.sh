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
# Source the bash utility functions.  Also, source the default workflow
# configuration file (in order to have access to default values of certain
# workflow variables) and the file that defines sets of valid values for
# various workflow variables.
#
#-----------------------------------------------------------------------
#
ushdir="${scrfunc_dir}"
. $ushdir/source_util_funcs.sh
. $ushdir/config_defaults.sh
. $ushdir/valid_param_vals.sh
#
#-----------------------------------------------------------------------
#
# Set string containing list of valid (default) task names.
#
#-----------------------------------------------------------------------
#
default_task_names=( \
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
default_task_names_str=$( printf "\"%s\" " ${default_task_names[@]} )
#
#-----------------------------------------------------------------------
#
# Set string containing list of default cycle-dependent task names.
#
#-----------------------------------------------------------------------
#
default_cycle_dep_task_names=( \
"${GET_EXTRN_ICS_TN}" \
"${GET_EXTRN_LBCS_TN}" \
"${MAKE_ICS_TN}" \
"${MAKE_LBCS_TN}" \
"${RUN_FCST_TN}" \
"${RUN_POST_TN}" \
)
default_cycle_dep_task_names_str=$( printf "\"%s\" " ${default_cycle_dep_task_names[@]} )
#
#-----------------------------------------------------------------------
#
# Set string containing list of valid job schedulers.
#
#-----------------------------------------------------------------------
#
valid_vals_sched_str=$( printf "\"%s\" " ${valid_vals_SCHED[@]} )
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
like rocoto).  To obtain help for this script, issue one of the following
commands:

  ${scrfunc_fn} -h
  ${scrfunc_fn} --help

The syntax for calling this script is as follows:

  [/path/to/experiment/dir/]${scrfunc_fn} \\
    exptdir=\"absolute_or_relative_path_to_experiment_directory\" \\
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

  exptdir:
  The absolute or relative path to the experiment directory.  If not
  specified, it is set to the current working directory.

  task_name:
  The name of the workflow task to run.  This must be specified.  The
  default set of valid task names is:
    ${default_task_names_str}
  (These default values can be changed in the workflow's user-specified
  configuration file at ush/config.sh.)

  cdate:
  The date and hour-of-day of the start time of the cycle for which to
  run the task.  This must be a string consisting of exactly 10 digits
  of the form \"YYYYMMDDHH\", where YYYY is the 4-digit year, MM is the
  2-digit month, DD is the 2-digit day-of- month, and HH is the 2-digit
  hour-of-day.  This must be specified if the task to run (task_name) is
  cycle-dependent.  The default names of the cycle-dependent tasks are:
    ${default_cycle_dep_task_names_str}
  (These default values can be changed in ush/config.sh.)  For cycle-
  independent tasks, any value of cdate specified on the command line is
  ignored.

  fhr:
  The forecast hour for which to run the task.  This must be specified
  only if running the post-processing task (named by default ${RUN_POST_TN}).
  For any other tasks, any value of fhr specified on the command line is
  ignored.

  sched:
  The job scheduler to use to submit the specified workflow task to the
  job queue.  Valid job schedulers are:
    ${valid_vals_sched_str}
  If not specified, the value (out of this list of valid values) that it
  defaults to depends on the machine.

  acct:
  The account to charge the core hours to of the job that will run the
  task.  If not specified, it is set to the workflow variable ACCOUNT
  defined in the experiment directory's global variable definitions file
  (named by default ${GLOBAL_VAR_DEFNS_FN}).

  part:
  The slurm partition in which to run the job.  If not specified, it is
  set to the default partition that slurm uses on the current machine
  (which is obtained using the sinfo utility).

  qos:
  The slurm quality-of-service to which to submit the job.  If not specified,
  it is set to the default qos that slurm uses on the current machine
  (which is obtained using the sacctmgr utility).

  nnodes, ppn, wtime:
  These are, respectively, the number of nodes to request from the job
  scheduler, the number of MPI processes per node to use, and the maximum
  walltime allowed for the job.  If one or more of these is not specified,
  they are set, respectively, to the workflow variables NNODES_\${TASK_NAME},
  PPN_\${TASK_NAME}, and WTIME_\${TASK_NAME} defined in the experiment
  directory's global variable definitions file (named by default ${GLOBAL_VAR_DEFNS_FN}),
  where \${TASK_NAME} is the name of the task to run converted to uppercase.

Note that when an experiment is generated, a symlink is created in the
top level of the experiment directory that points to this script in the
workflow's directory structure.  This allows this script to be run from
the experiment directory.

Examples:

* From the experiment directory, run the \"make_grid\" task:

  > cd /path/to/expt/directory
  > ${scrfunc_fn} task_name=\"make_grid\"

  In this case, all unspecified input parameters default to those in the
  experiment's variable defintions file.  This is usually all you need
  to do to run the task.

* Run the \"make_grid\" task from outside the experiment directory:

  > /path/to/expt/directory/${scrfunc_fn} \\
    exptdir=\"/path/to/expt/directory\" task_name=\"make_grid\"

* From the experiment directory, run the \"make_grid\" task under the
  \"gsd-fv3\" account in slurm's \"debug\" qos:

  > cd /path/to/expt/directory
  > ${scrfunc_fn} \\
    task_name=\"make_grid\" sched=\"slurm\" acct=\"gsd-fv3\" qos=\"debug\"

* Same as above but now explicitly specify the number of nodes, processes
  per node, and walltime to use for the job:

  > cd /path/to/expt/directory
  > ${scrfunc_fn} \\
    task_name=\"make_grid\" sched=\"slurm\" acct=\"gsd-fv3\" qos=\"debug\" \\
    nnodes=\"1\" ppn=\"6\" wtime=\"00:05:00\"

* From the experiment directory, run the \"make_ics\" task for a specified
  cdate with all script arguments except fhr specified:

  > cd /path/to/expt/directory
  > ${scrfunc_fn} \\
    task_name=\"make_ics\" cdate=\"2019052000\" \\
    sched=\"slurm\" acct=\"gsd-fv3\" part=\"hera\" qos=\"debug\" \\
    nnodes=\"2\" ppn=\"24\" wtime=\"00:10:00\"

* From the experiment directory, run the \"run_post\" task for a specified
  cdate and fhr with all script arguments specified:

  > cd /path/to/expt/directory
  > ${scrfunc_fn} \\
    task_name=\"run_post\" cdate=\"2019052000\" fhr=\"01\" \\
    sched=\"slurm\" acct=\"gsd-fv3\" part=\"hera\" qos=\"debug\" \\
    nnodes=\"2\" ppn=\"24\" wtime=\"00:10:00\"
"
#
#-----------------------------------------------------------------------
#
# Check whether this script is called with no arguments or with one
# argument that has a value of either "-h" or "--help".  In the first
# case (no arguments), print out an error message followed by the usage
# usage message and exit with a nonzero exit code.  In the second case
# (one argument that is set to either "-h" or "--help"), print out the
# usage message and exit with a zero exit code.
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
"exptdir" \
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
# If the experiment directory is not explicitly specified as an argument,
# set to the full path to the current working directory.  Then make sure
# that it exists.  Finally, reset it to a full path.
#
#-----------------------------------------------------------------------
#
if [ -z "$exptdir" ]; then
  exptdir=$( dirname "$0" )
fi

if [ ! -d "$exptdir" ]; then
  print_err_msg_exit "\
The path specified in exptdir does not exist or is not a directory:
  exptdir = \"${exptdir}\"
Please make sure that exptdir is an actual directory and rerun."
fi

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
The specified experiment directory (exptdir) does not contain a workflow
variable definitions file (global_var_defns_fn):
  exptdir = \"${exptdir}\"
  global_var_defns_fn = \"${global_var_defns_fn}\"
Please make sure that exptdir contains a valid experiment directory
containing a variable definitions file and rerun."
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
# Ensure that the specified task name is valid.
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
cycle_dep_task_names=( \
"${GET_EXTRN_ICS_TN}" \
"${GET_EXTRN_LBCS_TN}" \
"${MAKE_ICS_TN}" \
"${MAKE_LBCS_TN}" \
"${RUN_FCST_TN}" \
"${RUN_POST_TN}" \
)

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
# to uppercase and ensure that it has a valid value.
#
#-----------------------------------------------------------------------
#
sched="${sched:-$SCHED}"
sched="${sched^^}"
check_var_valid_value "sched" "valid_vals_SCHED"
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

if [ "$sched" = "SLURM" ]; then

  part_default=$( sinfo --format=%P | sed -r -n -e "s/^([^\*]+)\*$/\1/p" )

# The following works on hera.  It may have to be modified/generalized
# for other machines.
#  qos_default="batch"
  qos_default=$( sacctmgr --noheader show user \
                          user=$USER account=$acct format=defaultqos withassoc | \
                 sed -n -r -e "s/^[ ]*([^ ]*)[ ]*$/\1/p" )

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
# Set the name of the log file.  To mimic rocoto's log file naming 
# convention, for the post-processing task add the forecast hour to the
# name of the log file, and for all cycle-dependent tasks, add the cdate
# to the name of the log file.
#
#-----------------------------------------------------------------------
#
LOG_FN="no_wflow_${task_name}"
if [ "${task_name}" = "${RUN_POST_TN}" ]; then
  LOG_FN="${LOG_FN}_${fhr}"
fi
is_element_of "cycle_dep_task_names" "${task_name}" && LOG_FN="${LOG_FN}_${cdate}"
LOG_FN="${LOG_FN}.log"
#
#-----------------------------------------------------------------------
#
# Create the experiment's log directory if it doesn't already exist.  This
# will have to be done if this is the first time any tasks are being run
# in the experiment directory.  Then create the full path to the log file.
#
#-----------------------------------------------------------------------
#
if [ ! -d "$LOGDIR" ]; then
  mkdir_vrfy "$LOGDIR"
fi
LOG_FP="$LOGDIR/${LOG_FN}"
#
#-----------------------------------------------------------------------
#
# If a log file already exists, rename it.  Note that the second argument
# in the call below can be changed to "delete" to instead overwrite the
# existing log file.
#
#-----------------------------------------------------------------------
#
check_for_preexist_dir_file "${LOG_FP}" "rename"
#
#-----------------------------------------------------------------------
#
# Submit the job using the specified scheduler.
#
#-----------------------------------------------------------------------
#
jjob_fn="$JOBSDIR/JREGIONAL_${task_name_upper}"
job_cmd_line="${LOAD_MODULES_RUN_TASK_FP} \"${task_name}\" \"${jjob_fn}\""
#
# Job scheduler is slurm.
#
if [ "$sched" = "SLURM" ]; then

  sbatch_cmd="
  sbatch --job-name=\"${task_name}\" \\
         --account=\"$acct\" \\
         --partition=\"$part\" \\
         --qos=\"$qos\" \\
         --nodes=\"${nnodes}\" \\
         --ntasks-per-node=\"${ppn}\" \\
         --time=\"$wtime\" \\
         --output=\"${LOG_FP}\" \\
         --open-mode=\"truncate\" \\
         ${job_cmd_line}"

  print_info_msg "$VERBOSE" "
Scheduling job using $sched's sbatch utility:
  ${sbatch_cmd}
"

  eval "${sbatch_cmd}"
#
# Do not use a job scheduler.
#
elif [ "$sched" = "NONE" ]; then

  eval "${job_cmd_line}" >& ${LOG_FP}
#
# Job schedulers for which the submit command is not yet set.
#
else

  print_err_msg_exit "\
This script does not yet support the specified job scheduler (sched):
  sched = \"${sched}\""

fi


